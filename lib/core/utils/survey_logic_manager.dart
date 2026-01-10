import '../enums/survey_enums.dart';

class SurveyLogicManager {
  /// Evaluates a single rule against a given value.
  static bool evaluateRule(
    ConditionOperator operator,
    dynamic ruleValue,
    dynamic actualValue,
  ) {
    if (actualValue == null) {
      if (operator == ConditionOperator.isEmpty) return true;
      if (operator == ConditionOperator.notEmpty) return false;
      return false;
    }

    switch (operator) {
      case ConditionOperator.eq:
        return actualValue.toString() == ruleValue?.toString();
      case ConditionOperator.neq:
        return actualValue.toString() != ruleValue?.toString();
      case ConditionOperator.inList:
        if (ruleValue is List) return ruleValue.contains(actualValue);
        return false;
      case ConditionOperator.notIn:
        if (ruleValue is List) return !ruleValue.contains(actualValue);
        return true;
      case ConditionOperator.gt:
        return _compare(actualValue, ruleValue) > 0;
      case ConditionOperator.lt:
        return _compare(actualValue, ruleValue) < 0;
      case ConditionOperator.gte:
        return _compare(actualValue, ruleValue) >= 0;
      case ConditionOperator.lte:
        return _compare(actualValue, ruleValue) <= 0;
      case ConditionOperator.contains:
        return actualValue.toString().contains(ruleValue?.toString() ?? '');
      case ConditionOperator.isEmpty:
        return actualValue.toString().isEmpty;
      case ConditionOperator.notEmpty:
        return actualValue.toString().isNotEmpty;
    }
  }

  static int _compare(dynamic actual, dynamic rule) {
    try {
      final a = double.parse(actual.toString());
      final r = double.parse(rule.toString());
      return a.compareTo(r);
    } catch (_) {
      return 0;
    }
  }

  /// Evaluates multiple rules with a join type (AND/OR).
  static bool evaluateRules(List<bool> results, ConditionJoinType? joinType) {
    if (results.isEmpty) return true;
    if (joinType == ConditionJoinType.or) {
      return results.any((r) => r);
    }
    return results.every((r) => r);
  }
}
