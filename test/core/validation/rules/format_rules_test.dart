import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/format_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await S.load(const Locale('en')));

  group('EmailRule (id 15)', () {
    final r = EmailRule();
    test('accepts valid email', () {
      expect(r.validate(value: 'a@b.co', params: {}, validation: vEmail, locale: 'en').isValid, true);
    });
    test('rejects missing @', () {
      expect(r.validate(value: 'a.com', params: {}, validation: vEmail, locale: 'en').isValid, false);
    });
    test('rejects missing TLD', () {
      expect(r.validate(value: 'a@b', params: {}, validation: vEmail, locale: 'en').isValid, false);
    });
    test('no formatters', () {
      expect(r.formatters({}), isEmpty);
    });
  });

  group('UrlRule (id 16)', () {
    final r = UrlRule();
    test('accepts http URL', () {
      expect(r.validate(value: 'http://a.com', params: {}, validation: vUrl, locale: 'en').isValid, true);
    });
    test('accepts without scheme', () {
      expect(r.validate(value: 'a.com', params: {}, validation: vUrl, locale: 'en').isValid, true);
    });
    test('rejects empty', () {
      expect(r.validate(value: '', params: {}, validation: vUrl, locale: 'en').isValid, false);
    });
  });

  group('NoSpacesRule (id 17)', () {
    final r = NoSpacesRule();
    test('accepts no-space input', () {
      expect(r.validate(value: 'abc123', params: {}, validation: vNoSpaces, locale: 'en').isValid, true);
    });
    test('rejects input with space', () {
      expect(r.validate(value: 'abc 123', params: {}, validation: vNoSpaces, locale: 'en').isValid, false);
    });
    test('formatters: none — warn via live validation, do not block', () {
      expect(r.formatters({}), isEmpty);
    });
  });
}
