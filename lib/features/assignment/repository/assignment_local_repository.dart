import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/survey/survey_model.dart';
import '../models/save_section_models.dart';

class AssignmentLocalRepository {
  static const String _surveysKey = 'cached_surveys_list';
  static const String _responseDraftPrefix = 'response_draft_';

  /// Save a draft of the response (answers for a section)
  static Future<void> saveResponseDraft(
    int responseId,
    SaveSectionRequest request,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_responseDraftPrefix$responseId';
      await prefs.setString(key, jsonEncode(request.toJson()));
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
