import '../../l10n/generated/l10n.dart';
import '../../models/survey/validation_model.dart';
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

  @override
  String get defaultRegex =>
      '^(?=.*[؀-ۿ])[؀-ۿ٠-٩\\s‌‍\\x21-\\x2F\\x3A-\\x40\\x5B-\\x60\\x7B-\\x7E]+\$';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    final ok = _match(resolveRegex(validation), s);
    return ok ? const RuleResult.valid() : RuleResult.invalid(S.current.validation_arabic_only);
  }
}

class EnglishOnlyRule extends Rule {
  @override
  int get id => 23;
  @override
  String get debugName => 'English Text Only';

  @override
  String get defaultRegex => r'^[\x00-\x7F]+$';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    final ok = _match(resolveRegex(validation), s);
    return ok ? const RuleResult.valid() : RuleResult.invalid(S.current.validation_english_only);
  }
}
