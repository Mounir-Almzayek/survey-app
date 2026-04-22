import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/utils/survey_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  group('SurveyValidator.isValueEmpty (grid)', () {
    test('empty map is empty', () {
      expect(SurveyValidator.isValueEmpty(<String, String>{}), isTrue);
    });
    test('map with only empty-list values is empty', () {
      expect(
        SurveyValidator.isValueEmpty(<String, List<String>>{'a': []}),
        isTrue,
      );
    });
    test('map with non-empty list is not empty', () {
      expect(
        SurveyValidator.isValueEmpty(<String, List<String>>{'a': ['yes']}),
        isFalse,
      );
    });
    test('map with string value is not empty', () {
      expect(
        SurveyValidator.isValueEmpty(<String, String>{'a': 'yes'}),
        isFalse,
      );
    });
  });

  group('SurveyValidator.validatePhone', () {
    test('valid SA mobile passes', () {
      final err = SurveyValidator.validatePhone('+966501234567', locale: 'en');
      expect(err, isNull);
    });

    test('invalid number returns an English message for en locale', () {
      final err = SurveyValidator.validatePhone('+96612', locale: 'en');
      expect(err, isNotNull);
    });

    test('empty value returns null (required-check handled elsewhere)', () {
      final err = SurveyValidator.validatePhone(null, locale: 'en');
      expect(err, isNull);
    });
  });
}
