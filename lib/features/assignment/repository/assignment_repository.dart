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
import 'assignment_local_repository.dart';

class AssignmentRepository {
  static Future<ListAssignmentsResponse> listAssignments() async {
    final request = APIRequest(
      path: '/researcher/assignment/',
      method: HTTPMethod.get,
    );

    final response = await request.send();
    return ListAssignmentsResponse.fromJson(
      response.data as Map<String, dynamic>,
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
    return GetSurveyAssignmentResponse.fromJson(
      response.data as Map<String, dynamic>,
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
        gender: request.gender,
        ageGroup: request.ageGroup,
        startedAt: DateTime.now(),
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

  /// Updates the cached survey's researcher quotas when a response is completed:
  /// finds the response's demographic from metadata and increments the matching quota locally.
  static Future<void> _incrementLocalQuotaForCompletedResponse(
    int responseId,
  ) async {
    final meta = await AssignmentLocalRepository.getResponseMetadata(responseId);
    if (meta == null) return;

    final survey = await AssignmentLocalRepository.getSurveyById(meta.surveyId);
    if (survey == null ||
        survey.assignments == null ||
        survey.assignments!.isEmpty) {
      return;
    }

    for (var a = 0; a < survey.assignments!.length; a++) {
      final assignment = survey.assignments![a];
      final quotas = assignment.researcherQuotas;
      if (quotas == null || quotas.isEmpty) continue;

      final matchIndex = quotas.indexWhere(
        (q) => q.gender == meta.gender && q.ageGroup == meta.ageGroup,
      );
      if (matchIndex == -1) continue;

      // Verify the category exists in the researcher's profile for this survey
      final profile = await ProfileLocalRepository.getResearcherProfile();
      ResearcherAssignmentModel? profileAssignmentForSurvey;
      int? profileQuotaIndex;
      if (profile != null) {
        final list = profile.assignments
            .where((a) => a.surveyId == meta.surveyId)
            .toList();
        if (list.isEmpty) return;
        profileAssignmentForSurvey = list.first;
        final genderStr = meta.gender.toJson().toUpperCase();
        final ageGroupStr = meta.ageGroup.toJson().toUpperCase();
        profileQuotaIndex = profileAssignmentForSurvey.quotas.indexWhere((q) =>
            q.gender.toUpperCase() == genderStr &&
            q.ageGroup.toUpperCase() == ageGroupStr);
        if (profileQuotaIndex == -1) return;
      }

      final quota = quotas[matchIndex];
      final newProgress = quota.progress + 1;
      final newCollected = quota.collected + 1;
      final newPercent = quota.target > 0
          ? (newProgress / quota.target * 100).round().clamp(0, 100)
          : 0;

      final updatedQuota = quota.copyWith(
        progress: newProgress,
        collected: newCollected,
        progressPercent: newPercent,
        clearServerRemaining: true,
      );
      final newQuotas = List<ResearcherQuota>.from(quotas)
        ..[matchIndex] = updatedQuota;
      final updatedAssignment = assignment.copyWith(researcherQuotas: newQuotas);
      final newAssignments = List<Assignment>.from(survey.assignments!)
        ..[a] = updatedAssignment;
      final updatedSurvey = survey.copyWith(assignments: newAssignments);
      await AssignmentLocalRepository.updateSurvey(updatedSurvey);

      // Increment progress (collected) in the profile model locally when category matches
      if (profile != null &&
          profileAssignmentForSurvey != null &&
          profileQuotaIndex != null) {
        final pq = profileAssignmentForSurvey.quotas[profileQuotaIndex];
        final newProfileCollected = pq.collected + 1;
        final newProfileProgressPercent = pq.target > 0
            ? (newProfileCollected / pq.target * 100).round().clamp(0, 100)
            : 0;
        final updatedProfileQuota = ResearcherQuotaModel(
          gender: pq.gender,
          ageGroup: pq.ageGroup,
          target: pq.target,
          collected: newProfileCollected,
          progressPercent: newProfileProgressPercent,
          remaining: pq.remaining != null ? pq.remaining! - 1 : null,
          responsesCount: pq.responsesCount,
        );
        final newProfileQuotas =
            List<ResearcherQuotaModel>.from(profileAssignmentForSurvey.quotas)
              ..[profileQuotaIndex] = updatedProfileQuota;
        final updatedProfileAssignment = ResearcherAssignmentModel(
          id: profileAssignmentForSurvey.id,
          surveyId: profileAssignmentForSurvey.surveyId,
          surveyTitle: profileAssignmentForSurvey.surveyTitle,
          status: profileAssignmentForSurvey.status,
          type: profileAssignmentForSurvey.type,
          quotas: newProfileQuotas,
        );
        final newProfileAssignments = profile.assignments
            .map((a) =>
                a.surveyId == meta.surveyId
                    ? updatedProfileAssignment
                    : a)
            .toList();
        final updatedProfile = ResearcherProfileResponseModel(
          user: profile.user,
          researcher: profile.researcher,
          supervisor: profile.supervisor,
          assignments: newProfileAssignments,
        );
        await ProfileLocalRepository.saveResearcherProfile(updatedProfile);
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
        await _incrementLocalQuotaForCompletedResponse(responseId);
        final meta = await AssignmentLocalRepository.getResponseMetadata(
          responseId,
        );
        if (meta != null) {
          await refreshCachedSurveyFromApi(meta.surveyId);
        }
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

    // 2. If this save completes the survey offline, increment local quota now (optimistic)
    if (isCompletingSurvey) {
      await _incrementLocalQuotaForCompletedResponse(responseId);
      await AssignmentLocalRepository.markOptimisticQuotaIncremented(responseId);
    }

    // 3. Add to queue manager
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
                await _incrementLocalQuotaForCompletedResponse(responseId);
              }
              final meta = await AssignmentLocalRepository.getResponseMetadata(
                responseId,
              );
              if (meta != null) {
                await refreshCachedSurveyFromApi(meta.surveyId);
              }
            }
          }
        } catch (_) {}
      },
    );
  }
}
