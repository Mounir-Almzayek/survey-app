import 'package:flutter/services.dart';

import '../../l10n/generated/l10n.dart';
import '../../models/survey/validation_model.dart';
import '../input_formatters/char_whitelist_formatter.dart';
import '../rule.dart';


bool _match(String pattern, String value) {
  try {
    return RegExp(pattern, unicode: true).hasMatch(value);
  } catch (_) {
    return false;
  }
}

class ArabicOnlyRule extends Rule {
  @override
  int get id => 22;
  @override
  String get debugName => 'Arabic Text Only';

  // Char whitelist — wider than the validation regex (accepts any
  // Arabic block char, digit, ASCII punctuation) because the formatter
  // can't enforce the "must contain >=1 Arabic letter" lookahead.
  static final RegExp _char =
      RegExp('[؀-ۿ٠-٩\\s‌‍\\x21-\\x7E]');

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    final ok = _match(validation.validation ?? '', s);
    return ok ? const RuleResult.valid() : RuleResult.invalid(S.current.validation_arabic_only);
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [CharWhitelistFormatter(_char)];
}

class EnglishOnlyRule extends Rule {
  @override
  int get id => 23;
  @override
  String get debugName => 'English Text Only';

  static final RegExp _char = RegExp(r'[\x00-\x7F]');

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    final ok = _match(validation.validation ?? '', s);
    return ok ? const RuleResult.valid() : RuleResult.invalid(S.current.validation_english_only);
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [CharWhitelistFormatter(_char)];
}
