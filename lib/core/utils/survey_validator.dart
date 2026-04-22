import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../enums/survey_enums.dart';
import '../l10n/generated/l10n.dart';
import '../models/survey/question_model.dart';
import '../validation/rule_registry.dart';

class SurveyValidator {
  /// Validates a question value against its validation rules.
  /// Returns a list of error messages. If empty, validation passed.
  static List<String> validateQuestion({
    required Question question,
    required dynamic value,
    required String locale,
    bool isRequired = false,
  }) {
    final valueStr = _normalizeValue(value);
    if (!isRequired && valueStr.isEmpty) return const [];

    final errors = RuleRegistry.validateAll(
      question: question,
      normalizedValue: valueStr,
      locale: locale,
    );

    if (question.type == QuestionType.phoneNumber) {
      final phoneErr = validatePhone(valueStr, locale: locale);
      if (phoneErr != null) errors.add(phoneErr);
    }

    return errors;
  }

  /// Public version of empty check for UI use
  static bool isValueEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) {
      if (value.containsKey('latitude') && value.containsKey('longitude')) {
        final lat = value['latitude'];
        final lng = value['longitude'];
        return lat == null ||
            lng == null ||
            (lat is num && lat.isNaN) ||
            (lng is num && lng.isNaN);
      }
      if (value.isEmpty) return true;
      // Grid shape: all entries empty string / empty list means empty.
      return value.values.every((v) {
        if (v == null) return true;
        if (v is String) return v.trim().isEmpty;
        if (v is List) return v.isEmpty;
        return false;
      });
    }
    return false;
  }

  /// Validates an E.164 phone string. Returns a localised error message or
  /// `null` when the value is valid (or empty — required-checks are a
  /// separate concern).
  static String? validatePhone(String? value, {required String locale}) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      final parsed = PhoneNumber.parse(value);
      if (parsed.isValid()) return null;
    } catch (_) {/* fall through */}
    // locale param retained for signature stability; S.current resolves
    // to the active locale at call time.
    return S.current.invalid_phone_number;
  }

  /// Sanitizes value: Returns null if string is empty
  static dynamic sanitizeValue(dynamic value) {
    if (value is String && value.trim().isEmpty) return null;
    return value;
  }

  static String _normalizeValue(dynamic value) {
    if (value == null) return '';
    if (value is List) return value.join(',');
    if (value is Map) {
      if (value.containsKey('latitude') && value.containsKey('longitude')) {
        return '${value['latitude']},${value['longitude']}';
      }
      return value.toString();
    }
    return value.toString();
  }
}
