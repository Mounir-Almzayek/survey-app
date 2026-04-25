import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
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

  group('SurveyValidator.validatePhone (Saudi-only)', () {
    test('valid SA mobile passes', () {
      final err = SurveyValidator.validatePhone('+966501234567', locale: 'en');
      expect(err, isNull);
    });

    test('SA national without leading 0 passes', () {
      final err = SurveyValidator.validatePhone('501234567', locale: 'en');
      expect(err, isNull);
    });

    test('SA national with leading 0 passes', () {
      final err = SurveyValidator.validatePhone('0501234567', locale: 'en');
      expect(err, isNull);
    });

    test('too-short SA value returns error', () {
      final err = SurveyValidator.validatePhone('+96612', locale: 'en');
      expect(err, isNotNull);
    });

    test('non-Saudi country code returns error', () {
      final err = SurveyValidator.validatePhone('+971501234567', locale: 'en');
      expect(err, isNotNull);
    });

    test('empty value returns null (required-check handled elsewhere)', () {
      expect(SurveyValidator.validatePhone(null, locale: 'en'), isNull);
      expect(SurveyValidator.validatePhone('', locale: 'en'), isNull);
    });
  });

  group('SurveyValidator.validateQuestion (phoneNumber type implicit check)', () {
    Question phoneQ({bool required = true}) => Question(
          id: 1,
          type: QuestionType.phoneNumber,
          label: 'Phone',
          isRequired: required,
        );

    test('rejects non-Saudi number even without explicit validation row', () {
      // Phone questions don't get a `questionValidations` row from the
      // backend (phone is its own question type, not a generic text+rule).
      // The validator must still reject non-Saudi numbers.
      final errs = SurveyValidator.validateQuestion(
        question: phoneQ(),
        value: '+971501234567',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });

    test('accepts valid SA mobile', () {
      final errs = SurveyValidator.validateQuestion(
        question: phoneQ(),
        value: '+966501234567',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isEmpty);
    });

    test('empty optional phone passes', () {
      final errs = SurveyValidator.validateQuestion(
        question: phoneQ(required: false),
        value: null,
        locale: 'en',
        isRequired: false,
      );
      expect(errs, isEmpty);
    });

    test('empty required phone returns required error, not phone error', () {
      final errs = SurveyValidator.validateQuestion(
        question: phoneQ(),
        value: null,
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
      // Required-check runs first; phone-format check shouldn't double-fire.
      expect(errs.length, 1);
    });
  });
}
