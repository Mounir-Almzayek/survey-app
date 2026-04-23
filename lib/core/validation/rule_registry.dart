import 'package:flutter/services.dart';

import '../models/survey/question_model.dart';
import '../models/survey/validation_model.dart';
import 'rule.dart';
import 'rule_lookup.dart';
import 'rules/alphanumeric_rules.dart';
import 'rules/date_rules.dart';
import 'rules/file_rules.dart';
import 'rules/format_rules.dart';
import 'rules/length_rules.dart';
import 'rules/letter_rules.dart';
import 'rules/number_rules.dart';
import 'rules/password_rules.dart';
import 'rules/phone_rule.dart';
import 'rules/script_rules.dart';
import 'rules/selection_rules.dart';
import 'rules/value_range_rules.dart';

class RuleRegistry {
  static final Map<int, Rule> _byId = {
    1: NumberRule(),
    2: PositiveNumberRule(),
    3: IntegerRule(),
    4: DecimalNumberRule(),
    5: Decimal2PlacesRule(),
    6: MinLengthRule(),
    7: MaxLengthRule(),
    8: LengthRangeRule(),
    9: MinLettersRule(),
    10: MaxLettersRule(),
    11: LettersOnlyRule(),
    12: LettersAndSpacesRule(),
    13: AlphanumericRule(),
    14: AlphanumericWithSpacesRule(),
    15: EmailRule(),
    16: UrlRule(),
    17: NoSpacesRule(),
    18: NoSpecialCharsRule(),
    19: MinValueRule(),
    20: MaxValueRule(),
    21: ValueRangeRule(),
    22: ArabicOnlyRule(),
    23: EnglishOnlyRule(),
    24: MinEightCharsRule(),
    25: StrongPasswordRule(),
    26: MinSelectedRule(),
    27: MaxSelectedRule(),
    28: MinDateRule(),
    29: MaxDateRule(),
    30: BetweenDatesRule(),
    34: EqualDateRule(),
    31: FileSizeRule(),
    32: FileExtensionRule(),
    33: PhoneNumberRule(),
  };

  /// Exposed for tests; production code should go through [lookup].
  static Map<int, Rule> get rulesForTest => _byId;

  static Rule? lookup(Validation v) => RuleLookup.resolve(v, _byId);

  static List<String> validateAll({
    required Question question,
    required dynamic value,
    required String locale,
  }) {
    final errors = <String>[];
    final qvs = question.questionValidations ?? const [];
    for (final qv in qvs) {
      final v = qv.validation;
      if (v == null || v.isActive == false) continue;
      final rule = RuleLookup.resolve(v, _byId, params: qv.values);
      if (rule == null) continue;
      final r = rule.validate(
        value: value,
        params: qv.values,
        validation: v,
        locale: locale,
      );
      if (!r.isValid && r.message != null) errors.add(r.message!);
    }
    return errors;
  }

  static List<TextInputFormatter> formattersFor(Question q) {
    final out = <TextInputFormatter>[];
    final qvs = q.questionValidations ?? const [];
    for (final qv in qvs) {
      final v = qv.validation;
      if (v == null || v.isActive == false) continue;
      final rule = lookup(v);
      if (rule != null && rule.appliesToTextInput) {
        out.addAll(rule.formatters(qv.values));
      }
    }
    return _dedupe(out);
  }

  /// Collapses multiple `LengthLimitingTextInputFormatter`s into one (smallest
  /// cap wins). Other formatter types pass through unchanged.
  static List<TextInputFormatter> _dedupe(List<TextInputFormatter> input) {
    LengthLimitingTextInputFormatter? smallest;
    final others = <TextInputFormatter>[];
    for (final f in input) {
      if (f is LengthLimitingTextInputFormatter) {
        if (smallest == null ||
            (f.maxLength != null &&
                smallest.maxLength != null &&
                f.maxLength! < smallest.maxLength!)) {
          smallest = f;
        }
      } else {
        others.add(f);
      }
    }
    return [...others, if (smallest != null) smallest];
  }
}
