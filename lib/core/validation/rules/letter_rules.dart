import 'package:flutter/services.dart';

import '../../l10n/generated/l10n.dart';
import '../../models/survey/validation_model.dart';
import '../input_formatters/char_whitelist_formatter.dart';
import '../param_helpers.dart';
import '../rule.dart';

// Matches a single Arabic letter (excluding ٠-٩ Arabic-Indic digits,
// which live in ٠-ٯ) or Latin letter.
final RegExp _letter = RegExp('[؀-ٰٟ-ۿa-zA-Z]');
final RegExp _letterOrSpace = RegExp('[؀-ٰٟ-ۿa-zA-Z ]');

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
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    final min = paramInt(params, 'min');
    if (min == null) return const RuleResult.valid();
    final pattern = (validation.validation ?? '').replaceAll('min', '$min');
    final ok = _match(pattern, s);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_min_letters(min.toString()));
  }
}

class MaxLettersRule extends Rule {
  @override
  int get id => 10;
  @override
  String get debugName => 'Maximum Letters';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    final max = paramInt(params, 'max');
    if (max == null) return const RuleResult.valid();
    final pattern = (validation.validation ?? '').replaceAll('max', '$max');
    final ok = _match(pattern, s);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_max_letters(max.toString()));
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
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    final ok = _match(validation.validation ?? '', s);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_letters_only);
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) => [
    CharWhitelistFormatter(_letter),
  ];
}

class LettersAndSpacesRule extends Rule {
  @override
  int get id => 12;
  @override
  String get debugName => 'Letters and Spaces Only';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    final ok = _match(validation.validation ?? '', s);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_letters_and_spaces);
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) => [
    CharWhitelistFormatter(_letterOrSpace),
  ];
}
