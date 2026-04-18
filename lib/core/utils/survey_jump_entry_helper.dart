import '../models/survey/survey_model.dart';

/// Derives [sectionId] -> [first visible question id] when a jump targets a
/// question (not a section). Questions before that id in the section order are skipped.
class SurveyJumpEntryHelper {
  SurveyJumpEntryHelper._();

  static bool _isSectionId(Survey survey, int id) =>
      survey.sections?.any((s) => s.id == id) ?? false;

  /// For each section, if [jumpMap] contains a target that is a **question** in
  /// that section (and not a section id), records the latest question index in
  /// section order so the strongest skip wins.
  static Map<int, int> computeJumpEntryMap({
    required Survey survey,
    required Map<int, int> jumpMap,
  }) {
    final result = <int, int>{};
    final sections = survey.sections;
    if (sections == null) return result;

    for (final e in jumpMap.entries) {
      final targetId = e.value;
      if (_isSectionId(survey, targetId)) continue;

      for (final section in sections) {
        final questions = section.questions;
        if (questions == null) continue;

        final newIdx = questions.indexWhere((q) => q.id == targetId);
        if (newIdx == -1) continue;

        final existing = result[section.id];
        if (existing == null) {
          result[section.id] = targetId;
        } else {
          final oldIdx = questions.indexWhere((q) => q.id == existing);
          if (oldIdx != -1 && newIdx > oldIdx) {
            result[section.id] = targetId;
          }
        }
        break;
      }
    }
    return result;
  }
}
