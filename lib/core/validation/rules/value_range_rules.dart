import '../../models/survey/validation_model.dart';
import '../param_helpers.dart';
import '../rule.dart';

String _base(Validation v, String locale) =>
    (locale == 'ar' ? v.arContent : v.enContent) ?? '';

String _withBound(Validation v, String locale, num bound) =>
    '${_base(v, locale)} ($bound)'.trim();

/// Parse a string that may contain Arabic-Indic digits into a double.
double? _toNumber(String s) {
  if (s.isEmpty) return null;
  final translated = s.replaceAllMapped(
    RegExp('[٠-٩]'),
    (m) => '${m.group(0)!.codeUnitAt(0) - 0x0660}',
  );
  return double.tryParse(translated);
}

class MinValueRule extends Rule {
  @override
  int get id => 19;
  @override
  String get debugName => 'Minimum Value';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final min = paramDouble(params, 'min');
    if (min == null) return const RuleResult.valid();
    final parsed = _toNumber(value);
    if (parsed == null) return RuleResult.invalid(_base(validation, locale));
    return parsed >= min
        ? const RuleResult.valid()
        : RuleResult.invalid(_withBound(validation, locale, min));
  }
}

class MaxValueRule extends Rule {
  @override
  int get id => 20;
  @override
  String get debugName => 'Maximum Value';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final max = paramDouble(params, 'max');
    if (max == null) return const RuleResult.valid();
    final parsed = _toNumber(value);
    if (parsed == null) return RuleResult.invalid(_base(validation, locale));
    return parsed <= max
        ? const RuleResult.valid()
        : RuleResult.invalid(_withBound(validation, locale, max));
  }
}

class ValueRangeRule extends Rule {
  @override
  int get id => 21;
  @override
  String get debugName => 'Value Range';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final min = paramDouble(params, 'min');
    final max = paramDouble(params, 'max');
    final parsed = _toNumber(value);
    if (parsed == null) return RuleResult.invalid(_base(validation, locale));
    if (min != null && parsed < min) {
      return RuleResult.invalid(_withBound(validation, locale, min));
    }
    if (max != null && parsed > max) {
      return RuleResult.invalid(_withBound(validation, locale, max));
    }
    return const RuleResult.valid();
  }
}
