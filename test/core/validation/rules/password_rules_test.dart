import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/password_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  group('StrongPasswordRule (id 25)', () {
    final r = StrongPasswordRule();
    test('accepts strong password', () {
      expect(r.validate(value: 'Aa1!aaaa', params: {}, validation: vStrongPassword, locale: 'en').isValid, true);
    });
    test('rejects without uppercase', () {
      expect(r.validate(value: 'aa1!aaaa', params: {}, validation: vStrongPassword, locale: 'en').isValid, false);
    });
    test('rejects without digit', () {
      expect(r.validate(value: 'Aa!aaaaa', params: {}, validation: vStrongPassword, locale: 'en').isValid, false);
    });
    test('rejects without special char', () {
      expect(r.validate(value: 'Aa1aaaaa', params: {}, validation: vStrongPassword, locale: 'en').isValid, false);
    });
    test('rejects too short', () {
      expect(r.validate(value: 'Aa1!', params: {}, validation: vStrongPassword, locale: 'en').isValid, false);
    });
    test('no formatters — too many AND conditions to block mid-input', () {
      expect(r.formatters({}), isEmpty);
    });
  });
}
