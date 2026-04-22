import 'package:flutter/services.dart';

import '../../l10n/generated/l10n.dart';
import '../../models/survey/validation_model.dart';
import '../param_helpers.dart';
import '../rule.dart';

class MinLengthRule extends Rule {
  @override
  int get id => 6;
  @override
  String get debugName => 'Minimum Length';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final min = paramInt(params, 'min');
    if (min == null) return const RuleResult.valid();
    return value.length >= min
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_min_length(min.toString()));
  }
}

class MaxLengthRule extends Rule {
  @override
  int get id => 7;
  @override
  String get debugName => 'Maximum Length';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final max = paramInt(params, 'max');
    if (max == null) return const RuleResult.valid();
    return value.length <= max
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_max_length(max.toString()));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) {
    final max = paramInt(params, 'max');
    return max == null ? const [] : [LengthLimitingTextInputFormatter(max)];
  }
}

class LengthRangeRule extends Rule {
  @override
  int get id => 8;
  @override
  String get debugName => 'Length Range';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final min = paramInt(params, 'min');
    final max = paramInt(params, 'max');
    if (min != null && value.length < min) {
      return RuleResult.invalid(
        S.current.validation_min_length(min.toString()),
      );
    }
    if (max != null && value.length > max) {
      return RuleResult.invalid(
        S.current.validation_max_length(max.toString()),
      );
    }
    return const RuleResult.valid();
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) {
    final max = paramInt(params, 'max');
    return max == null ? const [] : [LengthLimitingTextInputFormatter(max)];
  }
}

class MinEightCharsRule extends Rule {
  @override
  int get id => 24;
  @override
  String get debugName => 'Minimum 8 Characters';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    return value.length >= 8
        ? const RuleResult.valid()
        : RuleResult.invalid(S.current.validation_min_length('8'));
  }
}
