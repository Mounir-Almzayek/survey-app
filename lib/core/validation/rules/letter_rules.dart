import 'package:flutter/services.dart';

import '../../l10n/generated/l10n.dart';
import '../../models/survey/validation_model.dart';
import '../param_helpers.dart';
import '../rule.dart';

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
  String get defaultRegex => r'^(?!.*[٠-٩])(?!.*[0-9])[؀-ٰٟ-ۿa-zA-Z]{min,}$';

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
    final pattern = resolveRegex(validation).replaceAll('min', '$min');
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
  String get defaultRegex => r'^(?!.*[٠-٩])(?!.*[0-9])[؀-ٰٟ-ۿa-zA-Z]{0,max}$';

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
    final pattern = resolveRegex(validation).replaceAll('max', '$max');
    final ok = _match(pattern, s);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_max_letters(max.toString()));
  }

  // Length cap is a hard width-of-the-input concern, not a content filter,
  // so keep it as a keystroke-level guard. Per-character whitelisting moved
  // to live validation — the user types whatever they want and the message
  // tells them why it's wrong.
  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) {
    final max = paramInt(params, 'max');
    return [
      if (max != null) LengthLimitingTextInputFormatter(max),
    ];
  }
}

class LettersOnlyRule extends Rule {
  @override
  int get id => 11;
  @override
  String get debugName => 'Letters Only';

  @override
  String get defaultRegex => r'^(?!.*[٠-٩])[؀-ٰٟ-ۿa-zA-Z]+$';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    final ok = _match(resolveRegex(validation), s);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_letters_only);
  }
}

class LettersAndSpacesRule extends Rule {
  @override
  int get id => 12;
  @override
  String get debugName => 'Letters and Spaces Only';

  @override
  String get defaultRegex => r'^(?!.*[٠-٩])[؀-ٰٟ-ۿa-zA-Z ]+$';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    final ok = _match(resolveRegex(validation), s);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_letters_and_spaces);
  }
}
