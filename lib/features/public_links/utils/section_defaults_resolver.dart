import '../../../core/enums/survey_enums.dart';
import '../../../core/models/survey/section_model.dart';

/// Resolves initial answer values for a freshly entered section, based on
/// each question's options that are marked `is_default: true` on the
/// backend.
///
/// Mirrors the web frontend's behavior: when a section is loaded, options
/// flagged as default pre-populate the corresponding question. The user can
/// still override before submitting.
///
/// Strategy per question type:
/// - **CHECKBOX** (multi-select): returns a list of all default option values
/// - **RADIO / DROPDOWN / SINGLE_SELECT_GRID**: returns the first default
///   option's value (single value)
/// - **Grid / text / numeric / date / file / gps types**: skipped — these
///   either don't carry options or have a structure where pre-fill from
///   `is_default` doesn't apply
///
/// Returns an empty map when no defaults apply, so callers can merge it into
/// existing state without conditionals.
class SectionDefaultsResolver {
  const SectionDefaultsResolver._();

  static const _multiSelectTypes = <QuestionType>{
    QuestionType.checkbox,
  };

  /// Builds `{questionId: defaultValue}` for every question in [section]
  /// that has any option flagged as default.
  static Map<int, dynamic> defaultsFor(Section section) {
    final result = <int, dynamic>{};
    final questions = section.questions ?? const [];

    for (final q in questions) {
      final options = q.questionOptions ?? const [];
      if (options.isEmpty) continue;

      final defaults = options.where((o) => o.isDefault == true).toList();
      if (defaults.isEmpty) continue;

      if (_multiSelectTypes.contains(q.type)) {
        final values = defaults
            .map((o) => o.value)
            .whereType<String>()
            .toList(growable: false);
        if (values.isNotEmpty) result[q.id] = values;
      } else {
        final firstValue = defaults.first.value;
        if (firstValue != null) result[q.id] = firstValue;
      }
    }

    return result;
  }
}
