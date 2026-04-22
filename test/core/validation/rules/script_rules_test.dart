import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/script_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  group('ArabicOnlyRule (id 22)', () {
    final r = ArabicOnlyRule();
    test('accepts Arabic text', () {
      expect(r.validate(value: 'مرحبا', params: {}, validation: vArabicOnly, locale: 'ar').isValid, true);
    });
    test('rejects Latin letters', () {
      expect(r.validate(value: 'hello', params: {}, validation: vArabicOnly, locale: 'ar').isValid, false);
    });
    test('accepts Arabic with Arabic-Indic digits', () {
      expect(r.validate(value: 'مرحبا ١٢٣', params: {}, validation: vArabicOnly, locale: 'ar').isValid, true);
    });
  });

  group('EnglishOnlyRule (id 23)', () {
    final r = EnglishOnlyRule();
    test('accepts ASCII', () {
      expect(r.validate(value: 'hello 123', params: {}, validation: vEnglishOnly, locale: 'en').isValid, true);
    });
    test('rejects Arabic', () {
      expect(r.validate(value: 'مرحبا', params: {}, validation: vEnglishOnly, locale: 'en').isValid, false);
    });
  });
}
