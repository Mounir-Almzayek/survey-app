import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/letter_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  group('MinLettersRule (id 9)', () {
    final r = MinLettersRule();
    test('accepts 3+ Latin letters with min=3', () {
      expect(r.validate(value: 'abc', params: {'min': 3}, validation: vMinLetters, locale: 'en').isValid, true);
    });
    test('accepts 3+ Arabic letters with min=3', () {
      expect(r.validate(value: 'مرحب', params: {'min': 3}, validation: vMinLetters, locale: 'ar').isValid, true);
    });
    test('rejects 2 letters with min=3', () {
      expect(r.validate(value: 'ab', params: {'min': 3}, validation: vMinLetters, locale: 'en').isValid, false);
    });
    test('rejects value containing digits (regex forbids digits)', () {
      expect(r.validate(value: 'ab1', params: {'min': 3}, validation: vMinLetters, locale: 'en').isValid, false);
    });
  });

  group('MaxLettersRule (id 10)', () {
    final r = MaxLettersRule();
    test('accepts 3 letters with max=5', () {
      expect(r.validate(value: 'abc', params: {'max': 5}, validation: vMaxLetters, locale: 'en').isValid, true);
    });
    test('rejects 6 letters with max=5', () {
      expect(r.validate(value: 'abcdef', params: {'max': 5}, validation: vMaxLetters, locale: 'en').isValid, false);
    });
    test('formatters: length-limit AND letter whitelist', () {
      expect(r.formatters({'max': 5}).length, 2);
    });
  });

  group('LettersOnlyRule (id 11)', () {
    final r = LettersOnlyRule();
    test('accepts Arabic only', () {
      expect(r.validate(value: 'مرحبا', params: {}, validation: vLettersOnly, locale: 'ar').isValid, true);
    });
    test('rejects with spaces', () {
      expect(r.validate(value: 'مرحبا بك', params: {}, validation: vLettersOnly, locale: 'ar').isValid, false);
    });
    test('rejects with digits', () {
      expect(r.validate(value: 'abc1', params: {}, validation: vLettersOnly, locale: 'en').isValid, false);
    });
    test('formatters: letter whitelist', () {
      expect(r.formatters({}).length, 1);
    });
  });

  group('LettersAndSpacesRule (id 12)', () {
    final r = LettersAndSpacesRule();
    test('accepts with spaces', () {
      expect(r.validate(value: 'hello world', params: {}, validation: vLettersAndSpaces, locale: 'en').isValid, true);
    });
    test('rejects with digits', () {
      expect(r.validate(value: 'hi 1', params: {}, validation: vLettersAndSpaces, locale: 'en').isValid, false);
    });
    test('formatters: letter-and-space whitelist', () {
      expect(r.formatters({}).length, 1);
    });
  });
}
