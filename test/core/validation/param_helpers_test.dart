import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/param_helpers.dart';

void main() {
  group('paramInt', () {
    test('returns int for int value', () {
      expect(paramInt({'min': 5}, 'min'), 5);
    });

    test('returns int for double value (truncated)', () {
      expect(paramInt({'min': 5.9}, 'min'), 5);
    });

    test('returns int for string value', () {
      expect(paramInt({'min': '10'}, 'min'), 10);
    });

    test('returns null for missing key', () {
      expect(paramInt({}, 'min'), null);
    });

    test('returns null for null value', () {
      expect(paramInt({'min': null}, 'min'), null);
    });

    test('returns null for unparseable string', () {
      expect(paramInt({'min': 'abc'}, 'min'), null);
    });
  });

  group('paramDouble', () {
    test('returns double for double', () {
      expect(paramDouble({'max': 3.14}, 'max'), 3.14);
    });

    test('returns double for int', () {
      expect(paramDouble({'max': 7}, 'max'), 7.0);
    });

    test('returns double for numeric string', () {
      expect(paramDouble({'max': '2.5'}, 'max'), 2.5);
    });

    test('returns null for missing key', () {
      expect(paramDouble({}, 'max'), null);
    });
  });
}
