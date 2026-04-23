import 'dart:convert';
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

    // 3. Normalize values for comparison
    // We use a serialized version for string comparisons, but keep raw for numeric
    final String aStr = _serialize(actualValue);
    final String rStr = _serialize(ruleValue);

    // 4. Numeric conversion (matches backend logic)
    // Try numeric conversion
    final aNum = double.tryParse(aStr.replaceAll(RegExp(r'[^0-9.]'), ''));
    final rNum = double.tryParse(rStr.replaceAll(RegExp(r'[^0-9.]'), ''));
    final isNumeric = aNum != null && rNum != null;

    // Try date conversion for inequality operators
    DateTime? aDate;
    DateTime? rDate;
    if (!isNumeric) {
      aDate = _tryParseDate(aStr);
      rDate = _tryParseDate(rStr);
    }
    final isDate = aDate != null && rDate != null;

    switch (operator) {
      case ConditionOperator.eq:
        if (isNumeric) return aNum == rNum;
        return aStr == rStr;
      case ConditionOperator.neq:
        if (isNumeric) return aNum != rNum;
        return aStr != rStr;
      case ConditionOperator.gt:
        if (isNumeric) return aNum > rNum;
        if (isDate) return aDate.isAfter(rDate);
        return aStr.compareTo(rStr) > 0;
      case ConditionOperator.lt:
        if (isNumeric) return aNum < rNum;
        if (isDate) return aDate.isBefore(rDate);
        return aStr.compareTo(rStr) < 0;
      case ConditionOperator.gte:
        if (isNumeric) return aNum >= rNum;
        if (isDate) return aDate.isAfter(rDate) || aDate.isAtSameMomentAs(rDate);
        return aStr.compareTo(rStr) >= 0;
      case ConditionOperator.lte:
        if (isNumeric) return aNum <= rNum;
        if (isDate) return aDate.isBefore(rDate) || aDate.isAtSameMomentAs(rDate);
        return aStr.compareTo(rStr) <= 0;
      case ConditionOperator.contains:
        // Case-insensitive string inclusion (matches backend)
        return aStr.toLowerCase().contains(rStr.toLowerCase());
      case ConditionOperator.inList:
        final List<String> inList = ruleValue is List
            ? ruleValue.map((v) => _serialize(v)).toList()
            : rStr.split(',').map((v) => v.trim()).toList();
        return inList.contains(aStr);
      case ConditionOperator.notIn:
        final List<String> notInList = ruleValue is List
            ? ruleValue.map((v) => _serialize(v)).toList()
            : rStr.split(',').map((v) => v.trim()).toList();
        return !notInList.contains(aStr);
      default:
        return false;
    }
  }

  /// Serializes value to match backend storage (Prisma/DB)
  static String _serialize(dynamic value) {
    if (value == null) return "";
    if (value is bool) return value ? "true" : "false";
    if (value is List || value is Map) {
      try {
        return jsonEncode(value);
      } catch (_) {
        return value.toString();
      }
    }
    return value.toString().trim();
  }

  /// Parses date/time strings for comparison logic
  static DateTime? _tryParseDate(String v) {
    final trimmed = v.trim();
    if (trimmed.isEmpty) return null;

    final full = DateTime.tryParse(trimmed);
    if (full != null) return full;

    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) {
      return DateTime.tryParse(trimmed);
    }

    if (RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(trimmed)) {
      return DateTime.tryParse("1970-01-01 $trimmed");
    }

    return null;
  }
}
