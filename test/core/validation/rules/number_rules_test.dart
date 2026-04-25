import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/number_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await S.load(const Locale('en')));

  group('NumberRule (id 1)', () {
    final r = NumberRule();
    test('accepts integer', () {
      expect(r.validate(value: '42', params: {}, validation: vNumber, locale: 'en').isValid, true);
    });
    test('accepts decimal', () {
      expect(r.validate(value: '-3.14', params: {}, validation: vNumber, locale: 'en').isValid, true);
    });
    test('accepts Arabic-Indic digits', () {
      expect(r.validate(value: '١٢٣', params: {}, validation: vNumber, locale: 'ar').isValid, true);
    });
    test('rejects letters — returns localized error message', () {
      final res = r.validate(value: 'abc', params: {}, validation: vNumber, locale: 'ar');
      expect(res.isValid, false);
      expect(res.message, isNotEmpty);
    });
    test('formatters: none — warn via live validation, do not block', () {
      expect(r.formatters({}), isEmpty);
    });
  });

  group('PositiveNumberRule (id 2)', () {
    final r = PositiveNumberRule();
    test('accepts positive', () {
      expect(r.validate(value: '24', params: {}, validation: vPositiveNumber, locale: 'en').isValid, true);
    });
    test('rejects zero', () {
      expect(r.validate(value: '0', params: {}, validation: vPositiveNumber, locale: 'en').isValid, false);
    });
    test('rejects negative', () {
      expect(r.validate(value: '-5', params: {}, validation: vPositiveNumber, locale: 'en').isValid, false);
    });
    test('formatters: none — warn via live validation, do not block', () {
      expect(r.formatters({}), isEmpty);
    });
  });

  group('IntegerRule (id 3)', () {
    final r = IntegerRule();
    test('accepts negative integer', () {
      expect(r.validate(value: '-7', params: {}, validation: vInteger, locale: 'en').isValid, true);
    });
    test('rejects decimal', () {
      expect(r.validate(value: '1.5', params: {}, validation: vInteger, locale: 'en').isValid, false);
    });
  });

  group('DecimalNumberRule (id 4)', () {
    final r = DecimalNumberRule();
    test('accepts decimal', () {
      expect(r.validate(value: '1.5', params: {}, validation: vDecimal, locale: 'en').isValid, true);
    });
    test('accepts integer (regex allows optional fraction)', () {
      expect(r.validate(value: '42', params: {}, validation: vDecimal, locale: 'en').isValid, true);
    });
  });

  group('Decimal2PlacesRule (id 5)', () {
    final r = Decimal2PlacesRule();
    test('accepts exactly 2 decimal places', () {
      expect(r.validate(value: '12.34', params: {}, validation: vDecimal2, locale: 'en').isValid, true);
    });
    test('rejects 1 decimal place', () {
      expect(r.validate(value: '12.3', params: {}, validation: vDecimal2, locale: 'en').isValid, false);
    });
    test('rejects 3 decimal places', () {
      expect(r.validate(value: '12.345', params: {}, validation: vDecimal2, locale: 'en').isValid, false);
    });
    test('formatters: none — warn via live validation, do not block', () {
      expect(r.formatters({}), isEmpty);
    });
  });
}
