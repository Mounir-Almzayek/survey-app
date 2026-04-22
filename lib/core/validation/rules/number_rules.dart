import 'package:flutter/services.dart';

import '../../models/survey/validation_model.dart';
import '../input_formatters/decimal_places_formatter.dart';
import '../input_formatters/digits_and_sign_formatter.dart';
import '../input_formatters/digits_only_formatter.dart';
import '../rule.dart';

String _msg(Validation v, String locale) =>
    (locale == 'ar' ? v.arContent : v.enContent) ??
    (locale == 'ar' ? v.arTitle : v.enTitle) ??
    'Validation error';

bool _match(String pattern, String value) {
  try {
    return RegExp(pattern, unicode: true).hasMatch(value);
  } catch (_) {
    return false;
  }
}

class NumberRule extends Rule {
  @override
  int get id => 1;
  @override
  String get debugName => 'Number';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [DigitsAndSignFormatter(allowDecimal: true)];
}

class PositiveNumberRule extends Rule {
  @override
  int get id => 2;
  @override
  String get debugName => 'Positive Number';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [DigitsOnlyFormatter()];
}

class IntegerRule extends Rule {
  @override
  int get id => 3;
  @override
  String get debugName => 'Integer';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [DigitsAndSignFormatter(allowDecimal: false)];
}

class DecimalNumberRule extends Rule {
  @override
  int get id => 4;
  @override
  String get debugName => 'Decimal Number';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [DigitsAndSignFormatter(allowDecimal: true)];
}

class Decimal2PlacesRule extends Rule {
  @override
  int get id => 5;
  @override
  String get debugName => 'Decimal Number (2 Decimal Places)';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) => [
        DigitsAndSignFormatter(allowDecimal: true),
        DecimalPlacesFormatter(2),
      ];
}
