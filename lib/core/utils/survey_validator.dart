import '../models/survey/question_model.dart';

class SurveyValidator {
  /// Validates a question value against its validation rules.
  /// Returns a list of error messages. If empty, validation passed.
  static List<String> validateQuestion({
    required Question question,
    required dynamic value,
    required String locale,
    bool isRequired = false,
  }) {
    final List<String> errors = [];

    // Normalize value to string for checks
    final valueStr = _normalizeValue(value);

    // If the field is empty and not required, skip other validations
    if (!isRequired && valueStr.isEmpty) {
      return errors;
    }

    if (question.questionValidations != null) {
      for (final qv in question.questionValidations!) {
        final validation = qv.validation;
        if (validation == null || validation.isActive == false) continue;

        final enTitle = (validation.enTitle ?? '').toLowerCase();
        final arTitle = (validation.arTitle ?? '');
        final values = qv.values ?? {};

        // 1. Manual Logical Validation (Safer than pure Regex for ranges)
        bool handledLogically = false;

        // Length Checks
        if (enTitle.contains('length') ||
            enTitle.contains('letters') ||
            arTitle.contains('أحرف') ||
            arTitle.contains('حروف') ||
            arTitle.contains('طول')) {
          final min = _toInt(values['min']);
          final max = _toInt(values['max']);

          if (min != null && valueStr.length < min) {
            errors.add(
              locale == 'ar'
                  ? (validation.arContent ??
                        'يجب أن يكون الطول $min أحرف على الأقل')
                  : (validation.enContent ??
                        'Minimum length is $min characters'),
            );
            handledLogically = true;
          }
          if (max != null && valueStr.length > max) {
            errors.add(
              locale == 'ar'
                  ? (validation.arContent ?? 'يجب ألا يتجاوز الطول $max أحرف')
                  : (validation.enContent ??
                        'Maximum length is $max characters'),
            );
            handledLogically = true;
          }
        }
        // Numeric Value Checks
        else if (enTitle.contains('value') ||
            enTitle.contains('number') ||
            arTitle.contains('قيمة') ||
            arTitle.contains('رقم')) {
          final numValue = double.tryParse(valueStr);
          if (numValue != null) {
            final min = _toDouble(values['min']);
            final max = _toDouble(values['max']);

            if (min != null && numValue < min) {
              errors.add(
                locale == 'ar'
                    ? (validation.arContent ??
                          'يجب أن تكون القيمة $min على الأقل')
                    : (validation.enContent ?? 'Minimum value is $min'),
              );
              handledLogically = true;
            }
            if (max != null && numValue > max) {
              errors.add(
                locale == 'ar'
                    ? (validation.arContent ?? 'يجب ألا تتجاوز القيمة $max')
                    : (validation.enContent ?? 'Maximum value is $max'),
              );
              handledLogically = true;
            }
          }
        }

        // 2. Regex Validation (Either as primary or secondary check)
        // If not already handled by logic or if we want to enforce the specific pattern (like "Letters Only")
        if (!handledLogically ||
            (validation.validation != null &&
                !validation.validation!.contains('{min'))) {
          String pattern = validation.validation ?? '';
          if (pattern.isNotEmpty) {
            // Clean pattern from JS-style slashes
            if (pattern.startsWith('/') && pattern.lastIndexOf('/') > 0) {
              pattern = pattern.substring(1, pattern.lastIndexOf('/'));
            }

            // Replace placeholders
            pattern = _replacePlaceholders(pattern, values);

            try {
              // dotAll: true is critical for multi-line text length checks
              final regex = RegExp(pattern, dotAll: true, unicode: true);
              if (!regex.hasMatch(valueStr)) {
                // Only add regex error if logic didn't already catch a length/value issue
                // to avoid duplicate error messages
                if (!handledLogically) {
                  final error = locale == 'ar'
                      ? (validation.arContent ??
                            validation.arTitle ??
                            'خطأ في التحقق')
                      : (validation.enContent ??
                            validation.enTitle ??
                            'Validation error');
                  errors.add(error);
                }
              }
            } catch (e) {
              // Fallback for complex regex
              try {
                final regex = RegExp(pattern);
                if (!regex.hasMatch(valueStr) && !handledLogically) {
                  final error = locale == 'ar'
                      ? (validation.arContent ??
                            validation.arTitle ??
                            'خطأ في التحقق')
                      : (validation.enContent ??
                            validation.enTitle ??
                            'Validation error');
                  errors.add(error);
                }
              } catch (_) {}
            }
          }
        }
      }
    }

    return errors;
  }

  static int? _toInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is String) return int.tryParse(val);
    if (val is double) return val.toInt();
    return null;
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
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
      return value.isEmpty;
    }
    return false;
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

  static String _replacePlaceholders(
    String pattern,
    Map<String, dynamic>? values,
  ) {
    if (values == null || values.isEmpty) return pattern;

    String result = pattern;
    values.forEach((key, val) {
      final valStr = val.toString();
      // Most common patterns use {min} or {max} or min, max as words
      result = result.replaceAll(RegExp('\\b$key\\b'), valStr);
      result = result.replaceAll(key, valStr);
    });

    return result;
  }
}
