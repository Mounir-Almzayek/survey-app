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

class NumberRule extends Rule {
  @override
  int get id => 1;
  @override
  String get debugName => 'Number';

  @override
  String get defaultRegex => r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$';

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
        : RuleResult.invalid(S.current.validation_number);
  }
}

class PositiveNumberRule extends Rule {
  @override
  int get id => 2;
  @override
  String get debugName => 'Positive Number';

  @override
  String get defaultRegex => r'^\+?[1-9١-٩][0-9٠-٩]*$';

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
        : RuleResult.invalid(S.current.validation_positive_number);
  }
}

class IntegerRule extends Rule {
  @override
  int get id => 3;
  @override
  String get debugName => 'Integer';

  @override
  String get defaultRegex => r'^[-+]?[0-9٠-٩]+$';

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
        : RuleResult.invalid(S.current.validation_integer);
  }
}

class DecimalNumberRule extends Rule {
  @override
  int get id => 4;
  @override
  String get debugName => 'Decimal Number';

  @override
  String get defaultRegex => r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$';

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
        : RuleResult.invalid(S.current.validation_decimal);
  }
}

class Decimal2PlacesRule extends Rule {
  @override
  int get id => 5;
  @override
  String get debugName => 'Decimal Number (2 Decimal Places)';

  @override
  String get defaultRegex => r'^[-+]?[0-9٠-٩]+\.[0-9٠-٩]{2}$';

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
        : RuleResult.invalid(S.current.validation_decimal_2places);
  }
}
