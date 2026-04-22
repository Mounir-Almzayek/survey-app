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

class AlphanumericRule extends Rule {
  @override
  int get id => 13;
  @override
  String get debugName => 'Alphanumeric';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_alphanumeric);
  }
}

class AlphanumericWithSpacesRule extends Rule {
  @override
  int get id => 14;
  @override
  String get debugName => 'Alphanumeric with Spaces';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_alphanumeric_with_spaces);
  }
}

class NoSpecialCharsRule extends Rule {
  @override
  int get id => 18;
  @override
  String get debugName => 'No Special Characters';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_no_special_chars);
  }
}
