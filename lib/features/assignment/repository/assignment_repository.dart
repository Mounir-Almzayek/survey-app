import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../../../data/network/api_request.dart';
import '../../../core/queue/services/request_queue_manager.dart';
import '../../../core/queue/services/request_queue_service.dart';
import '../../../core/models/survey/response_model.dart' as survey_models;
import '../models/assignment_response_model.dart';
import '../models/save_section_models.dart';
import '../models/start_response_model.dart';
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

  static Future<StartResponseResponse> startResponse(int surveyId) async {
    final request = APIRequest(
      path: '/researcher/assignment/survey/$surveyId/start',
      method: HTTPMethod.post,
      body: {}, // Provide empty body to avoid FST_ERR_CTP_EMPTY_JSON_BODY
    );

    final response = await request.send();
    return StartResponseResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Start a survey offline by generating a dummy negative ID and queuing the real request
  static Future<StartResponseResponse> startResponseOffline(
    int surveyId,
  ) async {
    final dummyId = await AssignmentLocalRepository.getNextNegativeId();

    final request = APIRequest(
      path: '/researcher/assignment/survey/$surveyId/start',
      method: HTTPMethod.post,
      body: {},
    );

    // Queue the real request with metadata for remapping later
    await RequestQueueManager().queueRequest(
      request,
      metadata: {
        'dummyId': dummyId,
        'type': 'start_response',
        'message': 'Starting survey #$surveyId',
      },
      onSuccess: (_) {
        // Success coordination is handled globally in RequestQueueManager
      },
    );

    // Add metadata to the queued item via the manager (Internal update)
    // Actually, queueRequest doesn't return the ID easily here,
    // but we can modify queueRequest to accept metadata.
    // Let's check RequestQueueManager.queueRequest again.

    return StartResponseResponse(
      success: true,
      message: 'Started offline',
      response: survey_models.Response(id: dummyId, surveyId: surveyId),
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
      }
    }

    return result;
  }

  /// Add save section answers to the offline queue
  static Future<void> enqueueSaveSectionAnswers({
    required int responseId,
    required SaveSectionRequest saveRequest,
  }) async {
    // 1. Mark as unsynced locally
    final localRequest = saveRequest.copyWith(isSynced: false);
    await AssignmentLocalRepository.saveResponseDraft(responseId, localRequest);

    // 2. Add to queue manager
    final apiRequest = getSaveSectionAnswersRequest(
      responseId: responseId,
      saveRequest: saveRequest,
    );

    await RequestQueueManager().queueRequest(
      apiRequest,
      onSuccess: (response) async {
        // When successfully synced via queue, update local status
        await AssignmentLocalRepository.saveResponseDraft(
          responseId,
          saveRequest.copyWith(isSynced: true),
        );

        // Check if the response indicates completion to increment sync counter
        try {
          if (response.data is Map<String, dynamic>) {
            final result = SaveSectionResponse.fromJson(response.data);
            if (result.success && result.isComplete) {
              await AssignmentLocalRepository.incrementSyncedResponsesCount();
            }
          }
        } catch (_) {}
      },
    );
  }
}
