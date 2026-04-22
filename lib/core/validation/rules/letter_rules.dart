import 'package:flutter/services.dart';

import '../../models/survey/validation_model.dart';
import '../input_formatters/char_whitelist_formatter.dart';
import '../param_helpers.dart';
import '../rule.dart';

// Matches a single Arabic letter (excluding ٠-٩ Arabic-Indic digits,
// which live in ٠-ٯ) or Latin letter.
final RegExp _letter = RegExp('[؀-ٰٟ-ۿa-zA-Z]');
final RegExp _letterOrSpace = RegExp('[؀-ٰٟ-ۿa-zA-Z ]');

String _base(Validation v, String locale) =>
    (locale == 'ar' ? v.arContent : v.enContent) ?? '';

String _withBound(Validation v, String locale, int bound) =>
    '${_base(v, locale)} ($bound)'.trim();

bool _match(String pattern, String value) {
  try {
    return RegExp(pattern, unicode: true).hasMatch(value);
  } catch (_) {
    return false;
  }
}

class MinLettersRule extends Rule {
  @override
  int get id => 9;
  @override
  String get debugName => 'Minimum Letters';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final min = paramInt(params, 'min');
    if (min == null) return const RuleResult.valid();
    final pattern = (validation.validation ?? '').replaceAll('min', '$min');
    final ok = _match(pattern, value);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(_withBound(validation, locale, min));
  }
}

class MaxLettersRule extends Rule {
  @override
  int get id => 10;
  @override
  String get debugName => 'Maximum Letters';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final max = paramInt(params, 'max');
    if (max == null) return const RuleResult.valid();
    final pattern = (validation.validation ?? '').replaceAll('max', '$max');
    final ok = _match(pattern, value);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(_withBound(validation, locale, max));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) {
    final max = paramInt(params, 'max');
    return [
      if (max != null) LengthLimitingTextInputFormatter(max),
      CharWhitelistFormatter(_letter),
    ];
  }
}

class LettersOnlyRule extends Rule {
  @override
  int get id => 11;
  @override
  String get debugName => 'Letters Only';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_base(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [CharWhitelistFormatter(_letter)];
}

class LettersAndSpacesRule extends Rule {
  @override
  int get id => 12;
  @override
  String get debugName => 'Letters and Spaces Only';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_base(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [CharWhitelistFormatter(_letterOrSpace)];
}
