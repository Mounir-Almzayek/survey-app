import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_option_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/other_option_value.dart';

QuestionOption _opt(String value, {bool isOther = false, String? label}) =>
    QuestionOption(
      id: value.hashCode,
      questionId: 1,
      label: label ?? value,
      value: value,
      isOther: isOther,
    );

void main() {
  group('OtherOptionValue.hasOtherOption', () {
    test('true when any option is_other', () {
      expect(
        OtherOptionValue.hasOtherOption([
          _opt('a'),
          _opt('other', isOther: true),
        ]),
        isTrue,
      );
    });

    test('false when no option is_other', () {
      expect(
        OtherOptionValue.hasOtherOption([_opt('a'), _opt('b')]),
        isFalse,
      );
    });

    test('false when options list is null or empty', () {
      expect(OtherOptionValue.hasOtherOption(null), isFalse);
      expect(OtherOptionValue.hasOtherOption(const []), isFalse);
    });
  });

  group('OtherOptionValue.isOtherRadioValue', () {
    final options = [
      _opt('yes'),
      _opt('no'),
      _opt('other', isOther: true),
    ];

    test('returns true when value is not a regular option value', () {
      expect(OtherOptionValue.isOtherRadioValue('my custom', options), isTrue);
    });

    test('returns false when value matches a regular option', () {
      expect(OtherOptionValue.isOtherRadioValue('yes', options), isFalse);
    });

    test('returns false for null or empty value', () {
      expect(OtherOptionValue.isOtherRadioValue(null, options), isFalse);
      expect(OtherOptionValue.isOtherRadioValue('', options), isFalse);
    });

    test('returns false when no other option exists, even for unknown value', () {
      // Without an "other" slot, an unknown value is just stale/invalid — don't
      // treat it as Other input.
      expect(
        OtherOptionValue.isOtherRadioValue('mystery', [_opt('a')]),
        isFalse,
      );
    });

    test('matches the option literal "other" against the regular slot', () {
      // The literal value of the is_other option (e.g. "other") should still
      // count as a regular value — entering "other" in the text box would
      // collide with the option marker, which is fine: Other is keyed by the
      // option, not its literal value.
      expect(OtherOptionValue.isOtherRadioValue('other', options), isFalse);
    });
  });

  group('OtherOptionValue.splitCheckboxValue', () {
    final options = [
      _opt('a'),
      _opt('b'),
      _opt('c'),
      _opt('other', isOther: true),
    ];

    test('separates regular values from other text', () {
      final (regular, other) =
          OtherOptionValue.splitCheckboxValue(['a', 'b', 'my note'], options);
      expect(regular, ['a', 'b']);
      expect(other, 'my note');
    });

    test('returns no other text when all values are regular', () {
      final (regular, other) =
          OtherOptionValue.splitCheckboxValue(['a', 'c'], options);
      expect(regular, ['a', 'c']);
      expect(other, isNull);
    });

    test('returns just other text when no regular values selected', () {
      final (regular, other) =
          OtherOptionValue.splitCheckboxValue(['just custom'], options);
      expect(regular, isEmpty);
      expect(other, 'just custom');
    });

    test('handles empty value list', () {
      final (regular, other) =
          OtherOptionValue.splitCheckboxValue(const [], options);
      expect(regular, isEmpty);
      expect(other, isNull);
    });

    test('returns input unchanged when no other option exists', () {
      final regularOnly = [_opt('a'), _opt('b')];
      final (regular, other) =
          OtherOptionValue.splitCheckboxValue(['a', 'unknown'], regularOnly);
      expect(regular, ['a', 'unknown']);
      expect(other, isNull);
    });
  });

  group('OtherOptionValue.mergeCheckboxValue', () {
    test('appends other text when non-empty', () {
      final merged =
          OtherOptionValue.mergeCheckboxValue(['a', 'b'], 'my note');
      expect(merged, ['a', 'b', 'my note']);
    });

    test('drops other text when null or empty', () {
      expect(OtherOptionValue.mergeCheckboxValue(['a'], null), ['a']);
      expect(OtherOptionValue.mergeCheckboxValue(['a'], ''), ['a']);
      expect(OtherOptionValue.mergeCheckboxValue(['a'], '   '), ['a']);
    });

    test('trims other text before appending', () {
      expect(
        OtherOptionValue.mergeCheckboxValue([], '  spaced text  '),
        ['spaced text'],
      );
    });
  });
}
