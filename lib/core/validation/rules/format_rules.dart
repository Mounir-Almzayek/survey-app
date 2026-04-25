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

class EmailRule extends Rule {
  @override
  int get id => 15;
  @override
  String get debugName => 'Email';

  @override
  String get defaultRegex =>
      r'^[a-zA-Z0-9٠-٩._%+-]+@[a-zA-Z0-9٠-٩.-]+\.[a-zA-Z]{2,}$';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    final ok = _match(resolveRegex(validation), s);
    return ok ? const RuleResult.valid() : RuleResult.invalid(S.current.validation_email);
  }
}

class UrlRule extends Rule {
  @override
  int get id => 16;
  @override
  String get debugName => 'URL';

  @override
  String get defaultRegex =>
      r'^(https?://)?([\da-z٠-٩.-]+)\.([a-z.]{2,6})([/\w .-]*)*/?$';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    final ok = _match(resolveRegex(validation), s);
    return ok ? const RuleResult.valid() : RuleResult.invalid(S.current.validation_url);
  }
}

class NoSpacesRule extends Rule {
  @override
  int get id => 17;
  @override
  String get debugName => 'No Spaces';

  @override
  String get defaultRegex => r'^\S+$';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final s = coerceString(value);
    final ok = _match(resolveRegex(validation), s);
    return ok ? const RuleResult.valid() : RuleResult.invalid(S.current.validation_no_spaces);
  }
}
