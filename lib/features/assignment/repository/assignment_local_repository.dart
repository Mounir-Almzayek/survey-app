import 'dart:convert';

import '../../../core/enums/survey_enums.dart';
import '../../../core/models/survey/survey_model.dart';
import '../models/response_metadata.dart';
import '../models/save_section_models.dart';
import 'local/assignment_storage.dart';
import 'local/completed_responses_store.dart';
import 'local/response_draft_store.dart';
import 'local/response_metadata_store.dart';
import 'local/survey_cache_store.dart';
import 'local/sync_and_id_store.dart';

/// Facade for assignment local storage. Delegates to dedicated stores.
class AssignmentLocalRepository {
  /// Get the next available negative ID for offline responses
  static Future<int> getNextNegativeId() async {
    return SyncAndIdStore.getNextNegativeId();
  }

  /// Remap an old ID (usually negative) to a new real ID across local storage
  static Future<void> remapIds(int oldId, int newId) async {
    await ResponseDraftStore.remap(oldId, newId);
    await SurveyCacheStore.remapLocalResponseIds(oldId, newId);
    final surveys = await SurveyCacheStore.getSurveys();
    await CompletedResponsesStore.remap(
      surveys.map((s) => s.id).toList(),
      oldId,
      newId,
    );
    await ResponseMetadataStore.remap(oldId, newId);
  }

  /// Save demographic metadata for a response (links responseId to who we're collecting for).
  static Future<void> saveResponseMetadata(
    int responseId,
    int surveyId,
    Gender gender,
    AgeGroup ageGroup,
  ) async {
    await ResponseMetadataStore.save(responseId, surveyId, gender, ageGroup);
  }

  /// Get demographic metadata for a response, or null if not found.
  static Future<ResponseMetadata?> getResponseMetadata(int responseId) async {
    return ResponseMetadataStore.get(responseId);
  }

  /// Remove response metadata (e.g. when response is discarded).
  static Future<void> removeResponseMetadata(int responseId) async {
    await ResponseMetadataStore.remove(responseId);
  }

  /// Get the persistent count of total synced responses
  static Future<int> getSyncedResponsesCount() async {
    return SyncAndIdStore.getSyncedResponsesCount();
  }

  /// Increment the persistent count of total synced responses
  static Future<void> incrementSyncedResponsesCount() async {
    return SyncAndIdStore.incrementSyncedResponsesCount();
  }

  /// Save a draft of the response (answers for a section)
  static Future<void> saveResponseDraft(
    int responseId,
    SaveSectionRequest request,
  ) async {
    await ResponseDraftStore.save(responseId, request);
  }

  /// Get a cached response draft by responseId
  static Future<SaveSectionRequest?> getResponseDraft(int responseId) async {
    return ResponseDraftStore.get(responseId);
  }

  /// Remove a response draft from cache
  static Future<void> removeResponseDraft(int responseId) async {
    await ResponseDraftStore.remove(responseId);
  }

  /// Add a response ID to the completed list for a survey
  static Future<void> addCompletedResponse(int surveyId, int responseId) async {
    await CompletedResponsesStore.add(surveyId, responseId);
  }

  /// Get the list of completed response IDs for a survey
  static Future<List<int>> getCompletedResponses(int surveyId) async {
    return CompletedResponsesStore.get(surveyId);
  }

  /// Save the entire list of surveys (Preserves localResponseIds)
  static Future<void> saveSurveys(List<Survey> newSurveys) async {
    final existingSurveys = await SurveyCacheStore.getSurveys();
    final localIdsMap = <int, List<int>>{
      for (var s in existingSurveys)
        if (s.localResponseIds != null && s.localResponseIds!.isNotEmpty)
          s.id: s.localResponseIds!,
    };
    final mergedSurveys = newSurveys.map((survey) {
      if (localIdsMap.containsKey(survey.id)) {
        return survey.copyWith(localResponseIds: localIdsMap[survey.id]);
      }
      return survey;
    }).toList();
    await SurveyCacheStore.saveRawSurveys(mergedSurveys);
  }

  /// Get the entire list of cached surveys
  static Future<List<Survey>> getSurveys() async {
    return SurveyCacheStore.getSurveys();
  }

  /// Get a single survey by its ID from the cached list
  static Future<Survey?> getSurveyById(int id) async {
    return SurveyCacheStore.getSurveyById(id);
  }

  /// Update a single survey (Preserves localResponseIds)
  static Future<void> updateSurvey(Survey updatedSurvey) async {
    await SurveyCacheStore.updateSurvey(updatedSurvey);
  }

  /// Link a response ID to a specific survey in the cached list
  static Future<void> linkResponseToSurvey(int surveyId, int responseId) async {
    await SurveyCacheStore.linkResponseToSurvey(surveyId, responseId);
  }

  /// Unlink a response ID from a specific survey in the cached list
  static Future<void> unlinkResponseFromSurvey(
    int surveyId,
    int responseId,
  ) async {
    await SurveyCacheStore.unlinkResponseFromSurvey(surveyId, responseId);
  }

  /// Clear all cached surveys
  static Future<void> clearCache() async {
    await AssignmentStorage.remove(AssignmentStorageKeys.surveys);
  }

  /// Clear all assignment-related data (surveys, drafts, metadata, completed, sync).
  /// Call on logout so the next account does not see the previous account's data.
  static Future<void> clearAllForLogout() async {
    await AssignmentStorage.clearAllAssignmentKeys();
  }

  /// Mark that we already incremented local quota for this response (optimistic).
  /// When queue later syncs with is_complete, we skip increment to avoid double count.
  static Future<void> markOptimisticQuotaIncremented(int responseId) async {
    final key = AssignmentStorageKeys.optimisticQuotaIncrementedIds;
    final list = await AssignmentStorage.getStringList(key) ?? [];
    final idStr = responseId.toString();
    if (!list.contains(idStr)) {
      list.add(idStr);
      await AssignmentStorage.setStringList(key, list);
    }
  }

  /// Returns true if this response was optimistically incremented (and we remove it).
  /// Call before incrementing on queue success; if true, skip increment.
  static Future<bool> consumeOptimisticQuotaIncrement(int responseId) async {
    final key = AssignmentStorageKeys.optimisticQuotaIncrementedIds;
    final list = await AssignmentStorage.getStringList(key) ?? [];
    final idStr = responseId.toString();
    if (!list.contains(idStr)) return false;
    list.remove(idStr);
    await AssignmentStorage.setStringList(key, list);
    return true;
  }

  /// Get recent search history
  static Future<List<String>> getSearchHistory() async {
    return await AssignmentStorage.getStringList(AssignmentStorageKeys.searchHistory) ?? [];
  }

  /// Add a query to search history (max 10, unique, newest first)
  static Future<void> addToSearchHistory(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final history = await getSearchHistory();
    final updated = [trimmed, ...history.where((q) => q != trimmed)];
    
    if (updated.length > 10) {
      updated.removeRange(10, updated.length);
    }

    await AssignmentStorage.setStringList(AssignmentStorageKeys.searchHistory, updated);
  }

  /// Clear search history
  static Future<void> clearSearchHistory() async {
    await AssignmentStorage.remove(AssignmentStorageKeys.searchHistory);
  }

  /// Append answers from a section save into a per-response map of
  /// `questionId → value.toString()`. Used by `QuotaMatcher` at finalize
  /// to see all answers across all sections without changing the API
  /// payload shape.
  static Future<void> appendAnswersForResponse(
    int responseId,
    List<AnswerRequest> answers,
  ) async {
    final key = AssignmentStorageKeys.accumulatedAnswers(responseId);
    final raw = await AssignmentStorage.getString(key);
    Map<String, dynamic> existing = {};
    if (raw != null && raw.isNotEmpty) {
      try {
        existing = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        existing = {};
      }
    }
    for (final a in answers) {
      final v = a.value;
      if (v == null) continue;
      existing[a.questionId.toString()] = v.toString();
    }
    await AssignmentStorage.setString(key, jsonEncode(existing));
  }

  /// Read the accumulated `questionId → value` map for a response.
  /// Returns an empty map when no answers have been accumulated yet.
  static Future<Map<int, String>> getAccumulatedAnswers(int responseId) async {
    final key = AssignmentStorageKeys.accumulatedAnswers(responseId);
    final raw = await AssignmentStorage.getString(key);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final m = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return {for (final e in m.entries) int.parse(e.key): e.value.toString()};
    } catch (_) {
      return const {};
    }
  }

  /// Clear the accumulated answers for a response (e.g. on completion sync
  /// or discard).
  static Future<void> clearAccumulatedAnswers(int responseId) async {
    await AssignmentStorage.remove(
      AssignmentStorageKeys.accumulatedAnswers(responseId),
    );
  }

  /// Persist the resolved `quotaTargetId` for a response so subsequent
  /// reads (e.g. queue sync callback) can find the same id without
  /// re-running the matcher.
  static Future<void> saveResolvedQuotaTargetId(
    int responseId,
    int quotaTargetId,
  ) async {
    await AssignmentStorage.setInt(
      'response_quota_target_$responseId',
      quotaTargetId,
    );
  }

  /// Read the previously-saved resolved quotaTargetId. Returns null when
  /// nothing was saved (matcher returned null or matcher never ran).
  static Future<int?> getResolvedQuotaTargetId(int responseId) async {
    return AssignmentStorage.getInt('response_quota_target_$responseId');
  }
}
