import '../enums/survey_enums.dart';
import 'survey_validator.dart';

class SurveyLogicManager {
  /// Evaluates a single rule against a given value.
  static bool evaluateRule(
    ConditionOperator operator,
    dynamic ruleValue,
    dynamic actualValue,
  ) {
    // 1. Handle Empty/Not Empty operators
    if (operator == ConditionOperator.isEmpty) {
      return SurveyValidator.isValueEmpty(actualValue);
    }
    if (operator == ConditionOperator.notEmpty) {
      return !SurveyValidator.isValueEmpty(actualValue);
    }

    // 2. If actual value is null, other operators always fail (matches Web logic)
    if (actualValue == null) return false;

    // 3. Normalize values for consistent comparison (JS-like strings)
    final String actualStr = _jsLikeString(actualValue);
    final String ruleStr = _jsLikeString(ruleValue);

    switch (operator) {
      case ConditionOperator.eq:
        return actualStr == ruleStr;
      case ConditionOperator.neq:
        return actualStr != ruleStr;
      case ConditionOperator.inList:
        final List<dynamic> expectedList = ruleValue is List
            ? ruleValue
            : [ruleValue];
        // Check if the actual value (as a single unit) exists in the expected list
        return expectedList.any((e) => _jsLikeString(e) == actualStr);
      case ConditionOperator.notIn:
        final List<dynamic> expectedList = ruleValue is List
            ? ruleValue
            : [ruleValue];
        return !expectedList.any((e) => _jsLikeString(e) == actualStr);
      case ConditionOperator.gt:
        final cmp = _compare(actualValue, ruleValue);
        return cmp != null && cmp > 0;
      case ConditionOperator.lt:
        final cmp = _compare(actualValue, ruleValue);
        return cmp != null && cmp < 0;
      case ConditionOperator.gte:
        final cmp = _compare(actualValue, ruleValue);
        return cmp != null && cmp >= 0;
      case ConditionOperator.lte:
        final cmp = _compare(actualValue, ruleValue);
        return cmp != null && cmp <= 0;
      case ConditionOperator.contains:
        // For lists (Checkboxes), check if any element matches or the string exists
        if (actualValue is List) {
          return actualValue.any(
            (item) => _jsLikeString(
              item,
            ).toLowerCase().contains(ruleStr.toLowerCase()),
          );
        }
        return actualStr.toLowerCase().contains(ruleStr.toLowerCase());
      default:
        return false;
    }
  }

  /// Mimics JavaScript's String() behavior for consistent logic with Web
  static String _jsLikeString(dynamic value) {
    if (value == null) return "";
    if (value is List) return value.join(","); // JS: [1,2].toString() -> "1,2"
    return value.toString();
  }

  static double? _compare(dynamic actual, dynamic rule) {
    try {
      final a = double.tryParse(actual.toString());
      final r = double.tryParse(rule.toString());
      if (a == null || r == null) return null;
      return a - r;
    } catch (_) {
      return null;
    }
  }
}
