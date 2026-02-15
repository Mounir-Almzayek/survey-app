import 'dart:convert';

import '../../../../core/models/survey/survey_model.dart';
import 'assignment_storage.dart';

/// Cached surveys list and per-survey localResponseIds.
class SurveyCacheStore {
  static Future<List<Survey>> getSurveys() async {
    final jsonStr = await AssignmentStorage.getString(AssignmentStorageKeys.surveys);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => Survey.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveRawSurveys(List<Survey> surveys) async {
    final data = surveys.map((s) => s.toJson()).toList();
    await AssignmentStorage.setString(
      AssignmentStorageKeys.surveys,
      jsonEncode(data),
    );
  }

  static Future<Survey?> getSurveyById(int id) async {
    final surveys = await getSurveys();
    try {
      return surveys.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateSurvey(Survey updatedSurvey) async {
    final surveys = await getSurveys();
    final index = surveys.indexWhere((s) => s.id == updatedSurvey.id);
    if (index != -1) {
      final existing = surveys[index];
      final merged = updatedSurvey.copyWith(
        localResponseIds:
            updatedSurvey.localResponseIds ?? existing.localResponseIds,
      );
      surveys[index] = merged;
    } else {
      surveys.add(updatedSurvey);
    }
    await saveRawSurveys(surveys);
  }

  static Future<void> linkResponseToSurvey(int surveyId, int responseId) async {
    final surveys = await getSurveys();
    final index = surveys.indexWhere((s) => s.id == surveyId);
    if (index == -1) return;
    final survey = surveys[index];
    final ids = List<int>.from(survey.localResponseIds ?? []);
    if (ids.contains(responseId)) return;
    ids.add(responseId);
    surveys[index] = survey.copyWith(localResponseIds: ids);
    await saveRawSurveys(surveys);
  }

  static Future<void> unlinkResponseFromSurvey(
    int surveyId,
    int responseId,
  ) async {
    final surveys = await getSurveys();
    final index = surveys.indexWhere((s) => s.id == surveyId);
    if (index == -1) return;
    final survey = surveys[index];
    final ids = List<int>.from(survey.localResponseIds ?? []);
    if (!ids.contains(responseId)) return;
    ids.remove(responseId);
    surveys[index] = survey.copyWith(localResponseIds: ids);
    await saveRawSurveys(surveys);
  }

  /// Remap oldId to newId in localResponseIds across all surveys.
  static Future<void> remapLocalResponseIds(int oldId, int newId) async {
    final surveys = await getSurveys();
    bool changed = false;
    for (var i = 0; i < surveys.length; i++) {
      final survey = surveys[i];
      if (survey.localResponseIds == null ||
          !survey.localResponseIds!.contains(oldId)) continue;
      final updated = survey.localResponseIds!
          .map((id) => id == oldId ? newId : id)
          .toList();
      surveys[i] = survey.copyWith(localResponseIds: updated);
      changed = true;
    }
    if (changed) await saveRawSurveys(surveys);
  }
}
