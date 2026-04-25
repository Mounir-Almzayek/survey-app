import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/value_range_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await S.load(const Locale('en')));

  group('MinValueRule (id 19)', () {
    final r = MinValueRule();
    test('accepts when value >= min', () {
      expect(r.validate(value: '10', params: {'min': 5}, validation: vMinValue, locale: 'en').isValid, true);
    });
    test('rejects when value < min; message embeds min', () {
      final res = r.validate(value: '3', params: {'min': 5}, validation: vMinValue, locale: 'en');
      expect(res.isValid, false);
      expect(res.message, contains('5'));
    });
    test('no-op when min missing from params', () {
      expect(r.validate(value: '3', params: {}, validation: vMinValue, locale: 'en').isValid, true);
    });
    test('rejects non-numeric value', () {
      expect(r.validate(value: 'abc', params: {'min': 5}, validation: vMinValue, locale: 'en').isValid, false);
    });
  });

  group('MaxValueRule (id 20)', () {
    final r = MaxValueRule();
    test('accepts when value <= max', () {
      expect(r.validate(value: '5', params: {'max': 10}, validation: vMaxValue, locale: 'en').isValid, true);
    });
    test('rejects when value > max', () {
      expect(r.validate(value: '15', params: {'max': 10}, validation: vMaxValue, locale: 'en').isValid, false);
    });
  });

  group('ValueRangeRule (id 21)', () {
    final r = ValueRangeRule();
    test('accepts in range', () {
      expect(r.validate(value: '5', params: {'min': 1, 'max': 10}, validation: vValueRange, locale: 'en').isValid, true);
    });
    test('rejects below min', () {
      expect(r.validate(value: '0', params: {'min': 1, 'max': 10}, validation: vValueRange, locale: 'en').isValid, false);
    });
    test('rejects above max', () {
      expect(r.validate(value: '11', params: {'min': 1, 'max': 10}, validation: vValueRange, locale: 'en').isValid, false);
    });
  });
}
