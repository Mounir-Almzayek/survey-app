import '../../l10n/generated/l10n.dart';
import '../../models/survey/validation_model.dart';
import '../param_helpers.dart';
import '../rule.dart';

/// Parse a string that may contain Arabic-Indic digits into a double.
double? _toNumber(String s) {
  if (s.isEmpty) return null;
  final translated = s.replaceAllMapped(
    RegExp('[٠-٩]'),
    (m) => '${m.group(0)!.codeUnitAt(0) - 0x0660}',
  );
  return double.tryParse(translated);
}

/// Formats a bound for display: 3.0 → "3", 3.5 → "3.5". Keeps whole-number
/// bounds clean (backend often sends them as doubles).
String _fmt(num n) =>
    n == n.truncate() ? n.toInt().toString() : n.toString();

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
    if (parsed == null || parsed < min) {
      return RuleResult.invalid(S.current.validation_min_value(_fmt(min)));
    }
    return const RuleResult.valid();
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
    if (parsed == null || parsed > max) {
      return RuleResult.invalid(S.current.validation_max_value(_fmt(max)));
    }
    return const RuleResult.valid();
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
    // Non-numeric input under a Value Range rule falls back to the
    // narrowest applicable message — range if both bounds, else the
    // single-sided bound message.
    if (parsed == null) {
      if (min != null && max != null) {
        return RuleResult.invalid(
          S.current.validation_value_range(_fmt(min), _fmt(max)),
        );
      }
      if (min != null) {
        return RuleResult.invalid(S.current.validation_min_value(_fmt(min)));
      }
      if (max != null) {
        return RuleResult.invalid(S.current.validation_max_value(_fmt(max)));
      }
      return RuleResult.invalid(S.current.validation_number);
    }
    if (min != null && max != null && (parsed < min || parsed > max)) {
      return RuleResult.invalid(
        S.current.validation_value_range(_fmt(min), _fmt(max)),
      );
    }
    if (min != null && parsed < min) {
      return RuleResult.invalid(S.current.validation_min_value(_fmt(min)));
    }
    if (max != null && parsed > max) {
      return RuleResult.invalid(S.current.validation_max_value(_fmt(max)));
    }
    return const RuleResult.valid();
  }
}
