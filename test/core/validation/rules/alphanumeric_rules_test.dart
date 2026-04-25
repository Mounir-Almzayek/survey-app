import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/alphanumeric_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await S.load(const Locale('en')));

  group('AlphanumericRule (id 13)', () {
    final r = AlphanumericRule();
    test('accepts letters+digits', () {
      expect(r.validate(value: 'abc123', params: {}, validation: vAlphanumeric, locale: 'en').isValid, true);
    });
    test('rejects with space', () {
      expect(r.validate(value: 'abc 1', params: {}, validation: vAlphanumeric, locale: 'en').isValid, false);
    });
    test('rejects with symbol', () {
      expect(r.validate(value: 'abc!', params: {}, validation: vAlphanumeric, locale: 'en').isValid, false);
    });
    test('no formatters', () {
      expect(r.formatters({}), isEmpty);
    });
  });

  group('AlphanumericWithSpacesRule (id 14)', () {
    final r = AlphanumericWithSpacesRule();
    test('accepts with spaces', () {
      expect(r.validate(value: 'abc 123', params: {}, validation: vAlphanumericWithSpaces, locale: 'en').isValid, true);
    });
    test('rejects with symbol', () {
      expect(r.validate(value: 'abc!', params: {}, validation: vAlphanumericWithSpaces, locale: 'en').isValid, false);
    });
  });

  group('NoSpecialCharsRule (id 18)', () {
    final r = NoSpecialCharsRule();
    test('accepts letters+digits+spaces', () {
      expect(r.validate(value: 'hello 123', params: {}, validation: vNoSpecialChars, locale: 'en').isValid, true);
    });
    test('rejects with &', () {
      expect(r.validate(value: 'a&b', params: {}, validation: vNoSpecialChars, locale: 'en').isValid, false);
    });
  });
}
