import '../enums/survey_enums.dart';
import '../l10n/generated/l10n.dart';
import '../models/survey/question_model.dart';
import '../models/survey/validation_model.dart';
import '../validation/rule_registry.dart';
import '../validation/rules/phone_rule.dart';

class SurveyValidator {
  /// Validates a question value against its validation rules.
  /// Returns a list of error messages. If empty, validation passed.
  static List<String> validateQuestion({
    required Question question,
    required dynamic value,
    required String locale,
    bool isRequired = false,
  }) {
    if (isRequired && isValueEmpty(value)) {
      return [S.current.field_required];
    }
    if (!isRequired && isValueEmpty(value)) return const [];

    // Phone questions don't get a `questionValidations` row from the backend
    // — phone format is implied by the question type. Run the Saudi check
    // here so it fires regardless of survey configuration.
    if (question.type == QuestionType.phoneNumber) {
      final phoneError = validatePhone(value, locale: locale);
      if (phoneError != null) return [phoneError];
    }

    final errors = RuleRegistry.validateAll(
      question: question,
      value: value,
      locale: locale,
    );

    return errors;
  }

  /// Standalone phone validator. Returns null when the value is a valid Saudi
  /// mobile (or empty); returns the localized error message otherwise.
  static String? validatePhone(dynamic value, {required String locale}) {
    final result = PhoneNumberRule().validate(
      value: value,
      params: const {},
      validation: _phoneSyntheticValidation,
      locale: locale,
    );
    return result.isValid ? null : result.message;
  }

  /// Public version of empty check for UI use
  static bool isValueEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) {
      if (value.containsKey('latitude') && value.containsKey('longitude')) {
        var lat = value['latitude'];
        var lng = value['longitude'];

        if (lat is List && lat.isNotEmpty) lat = lat.first;
        if (lng is List && lng.isNotEmpty) lng = lng.first;

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

  /// Sanitizes value: Returns null if string is empty
  static dynamic sanitizeValue(dynamic value) {
    if (value is String && value.trim().isEmpty) return null;
    return value;
  }
}

/// PhoneNumberRule needs a Validation object purely to satisfy its signature
/// — for type-implied phone checks the rule does its own work and ignores the
/// regex/title fields.
final Validation _phoneSyntheticValidation = Validation(
  id: 33,
  type: ValidationType.questions,
  validation: null,
  enTitle: 'Phone Number',
  arTitle: 'رقم هاتف',
  isActive: true,
);
