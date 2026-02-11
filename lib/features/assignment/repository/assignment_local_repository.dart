import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/survey/survey_model.dart';
import '../models/save_section_models.dart';

class AssignmentLocalRepository {
  static const String _surveysKey = 'cached_surveys_list';
  static const String _responseDraftPrefix = 'response_draft_';
  static const String _completedResponsesPrefix = 'completed_responses_';
  static const String _syncedCountKey = 'synced_responses_total_count';
  static const String _negativeIdCounterKey = 'negative_response_id_counter';

  /// Get the next available negative ID for offline responses
  static Future<int> getNextNegativeId() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_negativeIdCounterKey) ?? 0;
    final next = current - 1;
    await prefs.setInt(_negativeIdCounterKey, next);
    return next;
  }

  /// Remap an old ID (usually negative) to a new real ID across local storage
  static Future<void> remapIds(int oldId, int newId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Remap response drafts
      final oldKey = '$_responseDraftPrefix$oldId';
      final newKey = '$_responseDraftPrefix$newId';
      final draftData = prefs.getString(oldKey);
      if (draftData != null) {
        await prefs.setString(newKey, draftData);
        await prefs.remove(oldKey);
      }

      // 2. Remap localResponseIds in cached surveys
      final surveys = await getSurveys();
      bool changed = false;
      for (int i = 0; i < surveys.length; i++) {
        final survey = surveys[i];
        if (survey.localResponseIds != null &&
            survey.localResponseIds!.contains(oldId)) {
          final updatedIds = survey.localResponseIds!
              .map((id) => id == oldId ? newId : id)
              .toList();
          surveys[i] = survey.copyWith(localResponseIds: updatedIds);
          changed = true;
        }
      }

      if (changed) {
        await _saveRawSurveys(surveys);
      }

      // 3. Remap completed responses lists
      for (var survey in surveys) {
        final compKey = '$_completedResponsesPrefix${survey.id}';
        final compList = prefs.getStringList(compKey);
        if (compList != null && compList.contains(oldId.toString())) {
          final updatedCompList = compList
              .map((id) => id == oldId.toString() ? newId.toString() : id)
              .toList();
          await prefs.setStringList(compKey, updatedCompList);
        }
      }
    } catch (_) {
      // Ignore errors in remapping
    }
  }

  /// Get the persistent count of total synced responses
  static Future<int> getSyncedResponsesCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_syncedCountKey) ?? 0;
  }

  /// Increment the persistent count of total synced responses
  static Future<void> incrementSyncedResponsesCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_syncedCountKey) ?? 0;
    await prefs.setInt(_syncedCountKey, current + 1);
  }

  /// Save a draft of the response (answers for a section)
  static Future<void> saveResponseDraft(
    int responseId,
    SaveSectionRequest request,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_responseDraftPrefix$responseId';
      await prefs.setString(key, jsonEncode(request.toLocalJson()));
    } catch (_) {
      // Ignore
    }
  }

  /// Get a cached response draft by responseId
  static Future<SaveSectionRequest?> getResponseDraft(int responseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_responseDraftPrefix$responseId';
      final jsonStr = prefs.getString(key);
      if (jsonStr == null) return null;

      return SaveSectionRequest.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  /// Remove a response draft from cache
  static Future<void> removeResponseDraft(int responseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_responseDraftPrefix$responseId';
      await prefs.remove(key);
    } catch (_) {
      // Ignore
    }
  }

  /// Add a response ID to the completed list for a survey
  static Future<void> addCompletedResponse(int surveyId, int responseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_completedResponsesPrefix$surveyId';
      final currentList = prefs.getStringList(key) ?? [];
      if (!currentList.contains(responseId.toString())) {
        currentList.add(responseId.toString());
        await prefs.setStringList(key, currentList);
      }
    } catch (_) {}
  }

  /// Get the list of completed response IDs for a survey
  static Future<List<int>> getCompletedResponses(int surveyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_completedResponsesPrefix$surveyId';
      final list = prefs.getStringList(key) ?? [];
      return list.map((e) => int.parse(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Save the entire list of surveys (Preserves localResponseIds)
  static Future<void> saveSurveys(List<Survey> newSurveys) async {
    try {
      // 1. Get existing surveys to extract their local data
      final existingSurveys = await getSurveys();
      final Map<int, List<int>> localIdsMap = {
        for (var s in existingSurveys)
          if (s.localResponseIds != null && s.localResponseIds!.isNotEmpty)
            s.id: s.localResponseIds!,
      };

      // 2. Merge local IDs into the new surveys list
      final mergedSurveys = newSurveys.map((survey) {
        if (localIdsMap.containsKey(survey.id)) {
          return survey.copyWith(localResponseIds: localIdsMap[survey.id]);
        }
        return survey;
      }).toList();

      // 3. Save the merged list
      await _saveRawSurveys(mergedSurveys);
    } catch (_) {
      // Ignore errors in caching
    }
  }

  /// Get the entire list of cached surveys
  static Future<List<Survey>> getSurveys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_surveysKey);
      if (jsonStr == null) return [];

      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((item) => Survey.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Get a single survey by its ID from the cached list
  static Future<Survey?> getSurveyById(int id) async {
    final surveys = await getSurveys();
    try {
      return surveys.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Update a single survey (Preserves localResponseIds)
  static Future<void> updateSurvey(Survey updatedSurvey) async {
    final surveys = await getSurveys();
    final index = surveys.indexWhere((s) => s.id == updatedSurvey.id);

    if (index != -1) {
      final existing = surveys[index];
      // Merge: Take localResponseIds from existing if not present in updatedSurvey
      final mergedSurvey = updatedSurvey.copyWith(
        localResponseIds:
            updatedSurvey.localResponseIds ?? existing.localResponseIds,
      );
      surveys[index] = mergedSurvey;
      await _saveRawSurveys(surveys);
    } else {
      surveys.add(updatedSurvey);
      await _saveRawSurveys(surveys);
    }
  }

  /// Link a response ID to a specific survey in the cached list
  static Future<void> linkResponseToSurvey(int surveyId, int responseId) async {
    final surveys = await getSurveys();
    final index = surveys.indexWhere((s) => s.id == surveyId);

    if (index != -1) {
      final survey = surveys[index];
      final currentIds = List<int>.from(survey.localResponseIds ?? []);

      if (!currentIds.contains(responseId)) {
        currentIds.add(responseId);
        surveys[index] = survey.copyWith(localResponseIds: currentIds);
        await _saveRawSurveys(surveys);
      }
    }
  }

  /// Unlink a response ID from a specific survey in the cached list
  static Future<void> unlinkResponseFromSurvey(
    int surveyId,
    int responseId,
  ) async {
    final surveys = await getSurveys();
    final index = surveys.indexWhere((s) => s.id == surveyId);

    if (index != -1) {
      final survey = surveys[index];
      final currentIds = List<int>.from(survey.localResponseIds ?? []);

      if (currentIds.contains(responseId)) {
        currentIds.remove(responseId);
        surveys[index] = survey.copyWith(localResponseIds: currentIds);
        await _saveRawSurveys(surveys);
      }
    }
  }

  /// Internal helper to save list exactly as provided (No Merge logic)
  static Future<void> _saveRawSurveys(List<Survey> surveys) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> data = surveys
          .map((s) => s.toJson())
          .toList();
      await prefs.setString(_surveysKey, jsonEncode(data));
    } catch (_) {
      // Ignore
    }
  }

  /// Clear all cached surveys
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_surveysKey);
  }
}
