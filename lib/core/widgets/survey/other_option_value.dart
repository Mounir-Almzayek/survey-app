import '../../models/survey/question_option_model.dart';

/// Helpers for handling the "Other" (أخرى) free-text choice on radio,
/// dropdown, and checkbox questions.
///
/// **Wire format:** matches the web frontend's normalized payload — the free
/// text is stored directly in the answer value, with no marker:
///   * **Radio/Dropdown:** value is the user's text string (or the regular
///     option's value if a non-Other choice was made).
///   * **Checkbox:** value is the array of selected regular option values
///     with the user's free text appended as the last element.
///
/// Detection on the receive side: any value that doesn't match a regular
/// (non-`is_other`) option's `value` is the Other text.
class OtherOptionValue {
  OtherOptionValue._();

  /// True when the question's option list contains an `is_other` entry.
  static bool hasOtherOption(List<QuestionOption>? options) =>
      options?.any((o) => o.isOther) ?? false;

  /// For radio/dropdown answers: returns true when [value] is the Other
  /// free-text — i.e. not null/empty AND not the literal value of any option
  /// (regular OR the is_other marker itself). Returns false when the
  /// question has no Other slot, so a stale unknown value isn't accidentally
  /// rendered as Other input.
  static bool isOtherRadioValue(
    String? value,
    List<QuestionOption>? options,
  ) {
    if (value == null || value.isEmpty) return false;
    if (!hasOtherOption(options)) return false;
    return !_allOptionValues(options).contains(value);
  }

  /// For checkbox answers: splits a flat value list into (regular values,
  /// other text). The Other text — if present — is any value that doesn't
  /// match an option literal.
  static (List<String>, String?) splitCheckboxValue(
    List<String> values,
    List<QuestionOption>? options,
  ) {
    if (!hasOtherOption(options)) return (List<String>.from(values), null);
    final known = _allOptionValues(options);
    final regularSelected = <String>[];
    String? other;
    for (final v in values) {
      if (known.contains(v)) {
        regularSelected.add(v);
      } else {
        other = v; // last unknown wins — checkbox UI only allows one Other
      }
    }
    return (regularSelected, other);
  }

  /// For checkbox answers: appends [otherText] to [regularValues] when the
  /// text is non-empty (after trim). Empty/null text is dropped so the
  /// payload doesn't carry a stray empty string.
  static List<String> mergeCheckboxValue(
    List<String> regularValues,
    String? otherText,
  ) {
    final trimmed = otherText?.trim() ?? '';
    if (trimmed.isEmpty) return List<String>.from(regularValues);
    return [...regularValues, trimmed];
  }

  static Set<String> _allOptionValues(List<QuestionOption>? options) =>
      (options ?? const [])
          .map((o) => o.value ?? '')
          .where((v) => v.isNotEmpty)
          .toSet();
}
