import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../../../data/network/api_request.dart';
import '../../../core/enums/survey_enums.dart';
import '../../../core/queue/services/request_queue_manager.dart';
import '../../../core/queue/services/request_queue_service.dart';
import '../../../core/models/survey/assignment_model.dart';
import '../../../core/models/survey/response_model.dart' as survey_models;
import '../../../core/models/survey/researcher_quota_model.dart';
import '../../profile/models/researcher_profile_response_model.dart';
import '../../profile/repository/profile_local_repository.dart';
import '../models/assignment_response_model.dart';
import '../models/save_section_models.dart';
import '../models/start_response_model.dart';
import '../models/start_response_request_model.dart';
import '../services/binding_inferer.dart';
import '../services/quota_matcher.dart';
import '../../../core/models/survey/survey_model.dart';
import 'assignment_local_repository.dart';

class AssignmentRepository {
  /// Run the binding inferer on a single Survey + its first Assignment, and
  /// return a copy with `bindings` populated. Used by [listAssignments] and
  /// [getSurveyDetails] before caching, so the offline matcher always has
  /// the inferred binding data even on cold starts.
  static Survey _attachInferredBindings(Survey survey) {
    final assignments = survey.assignments;
    if (assignments == null || assignments.isEmpty) return survey;
    final inferred = BindingInferer.infer(
      survey: survey,
      assignment: assignments.first,
    );
    return survey.copyWith(bindings: inferred);
  }

  static Future<ListAssignmentsResponse> listAssignments() async {
    final request = APIRequest(
      path: '/researcher/assignment/',
      method: HTTPMethod.get,
    );

    final response = await request.send();
    final parsed = ListAssignmentsResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
    // Attach inferred bindings so cached surveys carry them on cold start.
    final enriched = parsed.surveys.map(_attachInferredBindings).toList();
    return ListAssignmentsResponse(
      success: parsed.success,
      message: parsed.message,
      surveys: enriched,
    );
  }

  static Future<GetSurveyAssignmentResponse> getSurveyDetails(
    int surveyId,
  ) async {
    final request = APIRequest(
      path: '/researcher/assignment/survey/$surveyId',
      method: HTTPMethod.get,
    );

    final response = await request.send();
    final parsed = GetSurveyAssignmentResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
    return GetSurveyAssignmentResponse(
      success: parsed.success,
      survey: _attachInferredBindings(parsed.survey),
    );
  }

  /// Fetches latest survey (including `researcher_quotas`) from the API and updates cache.
  /// Preserves [Survey.localResponseIds] via [AssignmentLocalRepository.updateSurvey].
  static Future<void> refreshCachedSurveyFromApi(int surveyId) async {
    try {
      final r = await getSurveyDetails(surveyId);
      if (r.success) {
        await AssignmentLocalRepository.updateSurvey(r.survey);
      }
    } catch (_) {}
  }

  /// Refetch all surveys + assignments and replace the local cache.
  /// Called after the offline queue drains so the local quota counts get
  /// reconciled against server-truth (which has just processed the
  /// queued submissions and matched their quota_target_ids
  /// authoritatively at FINAL_SUBMIT).
  static Future<void> refreshAllAssignments() async {
    try {
      final r = await listAssignments();
      if (r.success) {
        await AssignmentLocalRepository.saveSurveys(r.surveys);
      }
    } catch (_) {
      // Tolerate transient failures; next foreground refresh retries.
    }
  }

  static Future<StartResponseResponse> startResponse(
    StartResponseRequest request,
  ) async {
    final apiRequest = APIRequest(
      path: '/researcher/assignment/survey/${request.surveyId}/start',
      method: HTTPMethod.post,
      body: request.toJson(),
    );

    final response = await apiRequest.send();
    return StartResponseResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Start a survey offline by generating a dummy negative ID and queuing the real request
  static Future<StartResponseResponse> startResponseOffline(
    StartResponseRequest request,
  ) async {
    final dummyId = await AssignmentLocalRepository.getNextNegativeId();

    final apiRequest = APIRequest(
      path: '/researcher/assignment/survey/${request.surveyId}/start',
      method: HTTPMethod.post,
      body: request.toJson(),
    );

    // Queue the real request with metadata for remapping later
    await RequestQueueManager().queueRequest(
      apiRequest,
      metadata: {
        'dummyId': dummyId,
        'type': 'start_response',
        'message': 'Starting survey #${request.surveyId}',
      },
    );

    // Return a dummy response immediately (offline mode)
    return StartResponseResponse(
      success: true,
      message: 'Response started offline',
      response: survey_models.Response(
        id: dummyId,
        surveyId: request.surveyId,
        status: ResponseStatus.draft,
        startedAt: request.createdAt,
      ),
    );
  }

  /// Handles the post-sync logic when an offline "start response" succeeds online.
  /// This remaps dummy IDs to real ones across the queue and local storage.
  static Future<void> handleStartResponseSync(int dummyId, int realId) async {
    if (kDebugMode) {
      debugPrint(
        '[AssignmentRepository] Sync Success: Remapping dummyId=$dummyId to realId=$realId',
      );
    }

    // 1. Remap in Queue (Pending requests like section saves)
    await RequestQueueService.remapIds(dummyId, realId);

    // 2. Remap in Local Storage (Drafts and Survey list)
    await AssignmentLocalRepository.remapIds(dummyId, realId);
  }

  /// Walk cached surveys to find which one owns this response. Used to
  /// pick the right surveyId for refetch + survey lookup. Returns null
  /// when the response isn't linked to any cached survey (e.g. cache
  /// cleared).
  static Future<int?> _findSurveyIdForResponse(int responseId) async {
    final surveys = await AssignmentLocalRepository.getSurveys();
    for (final s in surveys) {
      if (s.localResponseIds?.contains(responseId) == true) {
        return s.id;
      }
    }
    return null;
  }

  /// Resolve and persist the `quotaTargetId` for a finalized response.
  /// Called when a section save reports `isComplete=true`. Idempotent —
  /// if a quotaTargetId is already saved for this response, returns it
  /// without re-running the matcher (mirrors the backend guard).
  static Future<int?> _resolveAndSaveQuotaTargetId(int responseId) async {
    final existing =
        await AssignmentLocalRepository.getResolvedQuotaTargetId(responseId);
    if (existing != null) return existing;

    // Find the survey owning this response.
    final surveys = await AssignmentLocalRepository.getSurveys();
    Survey? owningSurvey;
    for (final s in surveys) {
      if (s.localResponseIds?.contains(responseId) == true) {
        owningSurvey = s;
        break;
      }
    }
    if (owningSurvey == null) return null;

    final assignments = owningSurvey.assignments;
    if (assignments == null || assignments.isEmpty) return null;
    final assignment = assignments.first;

    final answers =
        await AssignmentLocalRepository.getAccumulatedAnswers(responseId);
    final matched = QuotaMatcher.match(
      survey: owningSurvey,
      assignment: assignment,
      answers: answers,
    );
    if (matched == null) return null;

    await AssignmentLocalRepository.saveResolvedQuotaTargetId(
      responseId,
      matched,
    );
    return matched;
  }

  /// Increment the local quota for a completed response, keyed by the
  /// `quotaTargetId` resolved at finalize. Mirrors the backend's per-target
  /// progress count. TEST_MODE surveys never increment locally — the
  /// server returns 0 for those, so refetch will reconcile.
  static Future<void> _incrementLocalQuotaForCompletedResponse(
    int responseId,
  ) async {
    final quotaTargetId =
        await AssignmentLocalRepository.getResolvedQuotaTargetId(responseId);
    if (quotaTargetId == null) return;

    // Find the survey for this response. We rely on the linked surveys
    // cache (the response's surveyId is recorded when the response is
    // started or remapped).
    final surveys = await AssignmentLocalRepository.getSurveys();
    Survey? owningSurvey;
    for (final s in surveys) {
      if (s.localResponseIds?.contains(responseId) == true) {
        owningSurvey = s;
        break;
      }
    }
    if (owningSurvey == null) return;
    if (owningSurvey.status == SurveyStatus.testMode) return;

    final assignments = owningSurvey.assignments;
    if (assignments == null || assignments.isEmpty) return;

    for (var ai = 0; ai < assignments.length; ai++) {
      final assignment = assignments[ai];
      final quotas = assignment.researcherQuotas;
      if (quotas == null || quotas.isEmpty) continue;

      final qi = quotas.indexWhere((q) => q.quotaTargetId == quotaTargetId);
      if (qi == -1) continue;

      final q = quotas[qi];
      final newProgress = q.progress + 1;
      final newCollected = q.collected + 1;
      final newPercent = q.target > 0
          ? (newProgress / q.target * 100).round().clamp(0, 100)
          : 0;
      final newRemaining = q.serverRemaining != null
          ? (q.serverRemaining! - 1).clamp(0, 1 << 30)
          : null;

      final updated = q.copyWith(
        progress: newProgress,
        collected: newCollected,
        progressPercent: newPercent,
        responsesCountInCategory: (q.responsesCountInCategory ?? 0) + 1,
        serverRemaining: newRemaining,
        clearServerRemaining: newRemaining == null,
      );

      final newQuotas = List<ResearcherQuota>.from(quotas)..[qi] = updated;
      final newAssignment =
          assignment.copyWith(researcherQuotas: newQuotas);
      final newAssignments = List<Assignment>.from(assignments)
        ..[ai] = newAssignment;
      final newSurvey = owningSurvey.copyWith(assignments: newAssignments);
      await AssignmentLocalRepository.updateSurvey(newSurvey);

      // Mirror into the profile cache.
      final profile = await ProfileLocalRepository.getResearcherProfile();
      if (profile != null) {
        final pAssignmentIdx = profile.assignments
            .indexWhere((a) => a.surveyId == owningSurvey!.id);
        if (pAssignmentIdx != -1) {
          final pAssignment = profile.assignments[pAssignmentIdx];
          final pqIdx = pAssignment.quotas
              .indexWhere((pq) => pq.quotaTargetId == quotaTargetId);
          if (pqIdx != -1) {
            final pq = pAssignment.quotas[pqIdx];
            final newPCollected = pq.collected + 1;
            final newPProgress = pq.progress + 1;
            final newPPercent = pq.target > 0
                ? (newPCollected / pq.target * 100).round().clamp(0, 100)
                : 0;
            final newPRemaining = pq.serverRemaining != null
                ? (pq.serverRemaining! - 1).clamp(0, 1 << 30)
                : null;

            final updatedPQ = ResearcherQuotaModel(
              id: pq.id,
              quotaId: pq.quotaId,
              assignmentId: pq.assignmentId,
              quotaTargetId: pq.quotaTargetId,
              target: pq.target,
              progress: newPProgress,
              collected: newPCollected,
              serverRemaining: newPRemaining,
              responsesCount: (pq.responsesCount ?? 0) + 1,
              progressPercent: newPPercent,
              displayLabel: pq.displayLabel,
              coordinates: pq.coordinates,
              createdAt: pq.createdAt,
              updatedAt: pq.updatedAt,
            );
            final newPQuotas =
                List<ResearcherQuotaModel>.from(pAssignment.quotas)
                  ..[pqIdx] = updatedPQ;
            final newPAssignment = ResearcherAssignmentModel(
              id: pAssignment.id,
              surveyId: pAssignment.surveyId,
              surveyTitle: pAssignment.surveyTitle,
              status: pAssignment.status,
              type: pAssignment.type,
              quotas: newPQuotas,
            );
            final newPAssignments =
                List<ResearcherAssignmentModel>.from(profile.assignments)
                  ..[pAssignmentIdx] = newPAssignment;
            final updatedProfile = ResearcherProfileResponseModel(
              user: profile.user,
              researcher: profile.researcher,
              supervisor: profile.supervisor,
              assignments: newPAssignments,
            );
            await ProfileLocalRepository.saveResearcherProfile(updatedProfile);
          }
        }
      }
      return;
    }
  }

  /// Get the APIRequest for saving section answers (used for queuing)
  static APIRequest getSaveSectionAnswersRequest({
    required int responseId,
    required SaveSectionRequest saveRequest,
  }) {
    return APIRequest(
      path: '/researcher/assignment/response/$responseId/section',
      method: HTTPMethod.post,
      body: saveRequest.toJson(),
    );
  }

  static Future<SaveSectionResponse> saveSectionAnswers({
    required int responseId,
    required SaveSectionRequest saveRequest,
  }) async {
    // SMART LOGIC: If ID is dummy (negative) or device is offline, enqueue instead
    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (responseId < 0 || !isOnline) {
      if (kDebugMode) {
        debugPrint(
          '[AssignmentRepository] Dummy ID or Offline detected (id=$responseId, online=$isOnline). '
          'Forcing to queue.',
        );
      }
      await enqueueSaveSectionAnswers(
        responseId: responseId,
        saveRequest: saveRequest,
      );
      return SaveSectionResponse(
        success: true,
        message: 'Saved to sync queue',
        isComplete: false,
        isQueued: true,
      );
    }

    // Accumulate this section's answers so the matcher (run at finalize)
    // sees all answers across all sections.
    await AssignmentLocalRepository.appendAnswersForResponse(
      responseId,
      saveRequest.answers,
    );

    final request = getSaveSectionAnswersRequest(
      responseId: responseId,
      saveRequest: saveRequest,
    );

    final response = await request.send();
    final result = SaveSectionResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (result.success) {
      // Mark as synced in local memory after successful online submission
      final syncedRequest = saveRequest.copyWith(isSynced: true);
      await AssignmentLocalRepository.saveResponseDraft(
        responseId,
        syncedRequest,
      );

      // Increment persistent sync counter if this was the final section
      if (result.isComplete) {
        await AssignmentLocalRepository.incrementSyncedResponsesCount();
        await _resolveAndSaveQuotaTargetId(responseId);
        await _incrementLocalQuotaForCompletedResponse(responseId);
        // Refetch from server so any divergence between local prediction and
        // server-side authoritative match resolves.
        final surveyId = await _findSurveyIdForResponse(responseId);
        if (surveyId != null) {
          await refreshCachedSurveyFromApi(surveyId);
        }
        await AssignmentLocalRepository.clearAccumulatedAnswers(responseId);
      }
    }

    return result;
  }

  /// Add save section answers to the offline queue.
  /// When [isCompletingSurvey] is true, local quota is incremented immediately (optimistic update).
  static Future<void> enqueueSaveSectionAnswers({
    required int responseId,
    required SaveSectionRequest saveRequest,
    bool isCompletingSurvey = false,
  }) async {
    // 1. Mark as unsynced locally
    final localRequest = saveRequest.copyWith(isSynced: false);
    await AssignmentLocalRepository.saveResponseDraft(responseId, localRequest);

    // 2. Accumulate this section's answers so the matcher (run at finalize)
    // sees all answers across all sections.
    await AssignmentLocalRepository.appendAnswersForResponse(
      responseId,
      saveRequest.answers,
    );

    // 3. If this save completes the survey offline, resolve quotaTargetId
    // and increment local quota now (optimistic).
    if (isCompletingSurvey) {
      await _resolveAndSaveQuotaTargetId(responseId);
      await _incrementLocalQuotaForCompletedResponse(responseId);
      await AssignmentLocalRepository.markOptimisticQuotaIncremented(responseId);
    }

    // 4. Add to queue manager
    final apiRequest = getSaveSectionAnswersRequest(
      responseId: responseId,
      saveRequest: saveRequest,
    );

    await RequestQueueManager().queueRequest(
      apiRequest,
      metadata: {'type': 'section_save'},
      onSuccess: (response) async {
        // When successfully synced via queue, update local status
        await AssignmentLocalRepository.saveResponseDraft(
          responseId,
          saveRequest.copyWith(isSynced: true),
        );

        // Check if the response indicates completion to increment sync counter and local quotas
        try {
          if (response.data is Map<String, dynamic>) {
            final result = SaveSectionResponse.fromJson(response.data);
            if (result.success && result.isComplete) {
              await AssignmentLocalRepository.incrementSyncedResponsesCount();
              // Skip quota increment if we already did it optimistically when user completed offline
              final alreadyIncremented = await AssignmentLocalRepository
                  .consumeOptimisticQuotaIncrement(responseId);
              if (!alreadyIncremented) {
                await _resolveAndSaveQuotaTargetId(responseId);
                await _incrementLocalQuotaForCompletedResponse(responseId);
              }
              final surveyId = await _findSurveyIdForResponse(responseId);
              if (surveyId != null) {
                await refreshCachedSurveyFromApi(surveyId);
              }
              await AssignmentLocalRepository.clearAccumulatedAnswers(responseId);
            }
          }
        } catch (_) {}
      },
    );
  }
}
