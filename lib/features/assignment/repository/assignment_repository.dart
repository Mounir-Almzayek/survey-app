import '../../../data/network/api_request.dart';
import '../../../core/queue/services/request_queue_manager.dart';
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
