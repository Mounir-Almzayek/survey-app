import '../../l10n/generated/l10n.dart';
import '../../models/survey/validation_model.dart';
import '../param_helpers.dart';
import '../rule.dart';

class MinSelectedRule extends Rule {
  @override
  int get id => 26;
  @override
  String get debugName => 'Minimum Selection';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final min = paramInt(params, 'min');
    if (min == null) return const RuleResult.valid();

    final count = value is List ? value.length : 0;
    return count >= min
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_min_selection(min.toString()));
  }
}

class MaxSelectedRule extends Rule {
  @override
  int get id => 27;
  @override
  String get debugName => 'Maximum Selection';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final max = paramInt(params, 'max');
    if (max == null) return const RuleResult.valid();

    final count = value is List ? value.length : 0;
    return count <= max
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_max_selection(max.toString()));
  }
}
