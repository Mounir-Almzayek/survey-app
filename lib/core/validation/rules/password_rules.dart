import '../../models/survey/validation_model.dart';
import '../rule.dart';

String _msg(Validation v, String locale) =>
    (locale == 'ar' ? v.arContent : v.enContent) ?? '';

bool _match(String pattern, String value) {
  try {
    return RegExp(pattern, unicode: true).hasMatch(value);
  } catch (_) {
    return false;
  }
}

class StrongPasswordRule extends Rule {
  @override
  int get id => 25;
  @override
  String get debugName => 'Strong Password';

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
}
