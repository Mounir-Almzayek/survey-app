import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/length_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  group('MinLengthRule (id 6)', () {
    final r = MinLengthRule();
    test('accepts when length >= min', () {
      expect(r.validate(value: 'abc', params: {'min': 3}, validation: vMinLength, locale: 'ar').isValid, true);
    });
    test('rejects when length < min; message includes min', () {
      final res = r.validate(value: 'ab', params: {'min': 3}, validation: vMinLength, locale: 'ar');
      expect(res.isValid, false);
      expect(res.message, contains('3'));
      expect(res.message, contains(vMinLength.arContent!));
    });
    test('no-op when min missing from params', () {
      expect(r.validate(value: '', params: {}, validation: vMinLength, locale: 'en').isValid, true);
    });
    test('no formatters', () {
      expect(r.formatters({}), isEmpty);
    });
  });

  group('MaxLengthRule (id 7)', () {
    final r = MaxLengthRule();
    test('accepts when length <= max', () {
      expect(r.validate(value: 'abcd', params: {'max': 5}, validation: vMaxLength, locale: 'en').isValid, true);
    });
    test('rejects when length > max; message includes max', () {
      final res = r.validate(value: 'abcdef', params: {'max': 5}, validation: vMaxLength, locale: 'en');
      expect(res.isValid, false);
      expect(res.message, contains('5'));
    });
    test('formatters: LengthLimitingTextInputFormatter(max)', () {
      expect(r.formatters({'max': 5}).length, 1);
    });
    test('no formatter when max missing', () {
      expect(r.formatters({}), isEmpty);
    });
  });

  group('LengthRangeRule (id 8)', () {
    final r = LengthRangeRule();
    test('accepts when min <= length <= max', () {
      expect(r.validate(value: 'abc', params: {'min': 2, 'max': 5}, validation: vLengthRange, locale: 'en').isValid, true);
    });
    test('rejects when length < min', () {
      final res = r.validate(value: 'a', params: {'min': 2, 'max': 5}, validation: vLengthRange, locale: 'en');
      expect(res.isValid, false);
    });
    test('rejects when length > max', () {
      final res = r.validate(value: 'abcdef', params: {'min': 2, 'max': 5}, validation: vLengthRange, locale: 'en');
      expect(res.isValid, false);
    });
    test('formatters: length-limiting at max', () {
      expect(r.formatters({'min': 2, 'max': 5}).length, 1);
    });
  });

  group('MinEightCharsRule (id 24)', () {
    final r = MinEightCharsRule();
    test('accepts 8+ chars', () {
      expect(r.validate(value: '12345678', params: {}, validation: vMinEight, locale: 'en').isValid, true);
    });
    test('rejects 7 chars', () {
      expect(r.validate(value: '1234567', params: {}, validation: vMinEight, locale: 'en').isValid, false);
    });
  });
}
