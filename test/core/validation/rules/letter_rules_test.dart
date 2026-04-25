import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/letter_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await S.load(const Locale('en')));

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
    test('formatters: length cap only — no per-character whitelist', () {
      // Per-character filtering moved to live validation (warn-don't-block).
      // The length limiter survives because it's a hard width-of-input cap.
      expect(r.formatters({'max': 5}).length, 1);
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
    test('formatters: none — warn via live validation, do not block', () {
      expect(r.formatters({}), isEmpty);
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
    test('formatters: none — warn via live validation, do not block', () {
      expect(r.formatters({}), isEmpty);
    });
  });
}
