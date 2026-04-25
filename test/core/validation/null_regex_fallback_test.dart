// Backend may send a Validation row with `validation: null` or `validation: ''`
// (regex column missing or blank in the API payload). Pre-fix every rule used
// `_match(validation.validation ?? '', s)` which became `RegExp('').hasMatch(s)`
// — that returns true for any input, so all 8 rules the QA tester reported
// as broken silently passed. Each rule must fall back to its own canonical
// regex when the backend doesn't supply one.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/utils/survey_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async => await S.load(const Locale('en')));

  /// Builds a Question carrying one validation row with a deliberately empty
  /// regex — mirrors what the app receives when the backend column is null.
  Question questionWithNullRegex({
    required int id,
    required String enTitle,
    required String arTitle,
  }) =>
      Question(
        id: 1,
        type: QuestionType.textShort,
        label: 'q',
        questionValidations: [
          QuestionValidation(
            id: 1,
            questionId: 1,
            validationId: id,
            values: const {},
            validation: Validation(
              id: id,
              type: ValidationType.questions,
              validation: null,
              enTitle: enTitle,
              arTitle: arTitle,
              isActive: true,
            ),
          ),
        ],
      );

  List<String> validate(Question q, dynamic value) =>
      SurveyValidator.validateQuestion(
        question: q,
        value: value,
        locale: 'en',
        isRequired: true,
      );

  group('Null/empty backend regex must fall back to canonical regex', () {
    test('Decimal-2 (id 5) rejects "5.2" even when validation.validation is null',
        () {
      final q = questionWithNullRegex(
        id: 5,
        enTitle: 'Decimal Number (2 Decimal Places)',
        arTitle: 'رقم عشري (منزلتان عشريتان)',
      );
      expect(validate(q, '5.2'), isNotEmpty);
      expect(validate(q, '5.20'), isEmpty);
    });

    test('Letters-and-Spaces (id 12) rejects digits even with null regex', () {
      final q = questionWithNullRegex(
        id: 12,
        enTitle: 'Letters and Spaces Only',
        arTitle: 'أحرف ومسافات فقط',
      );
      expect(validate(q, 'hi 1'), isNotEmpty);
      expect(validate(q, 'hello world'), isEmpty);
    });

    test('Alphanumeric (id 13) rejects symbols even with null regex', () {
      final q = questionWithNullRegex(
        id: 13,
        enTitle: 'Alphanumeric',
        arTitle: 'أحرف وأرقام',
      );
      expect(validate(q, 'abc!'), isNotEmpty);
      expect(validate(q, 'abc123'), isEmpty);
    });

    test('Email (id 15) rejects garbage even with null regex', () {
      final q = questionWithNullRegex(
        id: 15,
        enTitle: 'Email',
        arTitle: 'بريد إلكتروني',
      );
      expect(validate(q, 'not_an_email'), isNotEmpty);
      expect(validate(q, 'u@example.com'), isEmpty);
    });

    test('URL (id 16) rejects bare words even with null regex', () {
      final q = questionWithNullRegex(
        id: 16,
        enTitle: 'URL',
        arTitle: 'رابط',
      );
      expect(validate(q, 'hello'), isNotEmpty);
      expect(validate(q, 'https://example.com'), isEmpty);
    });

    test('No-Special-Chars (id 18) rejects symbols even with null regex', () {
      final q = questionWithNullRegex(
        id: 18,
        enTitle: 'No Special Characters',
        arTitle: 'بدون رموز خاصة',
      );
      expect(validate(q, 'abc!'), isNotEmpty);
      expect(validate(q, 'abc 123'), isEmpty);
    });

    test('Arabic-only (id 22) rejects English even with null regex', () {
      final q = questionWithNullRegex(
        id: 22,
        enTitle: 'Arabic Text Only',
        arTitle: 'نص عربي فقط',
      );
      expect(validate(q, 'Hello'), isNotEmpty);
      expect(validate(q, 'مرحبا'), isEmpty);
    });

    test('Strong-Password (id 25) rejects weak passwords even with null regex',
        () {
      final q = questionWithNullRegex(
        id: 25,
        enTitle: 'Strong Password',
        arTitle: 'كلمة مرور قوية',
      );
      expect(validate(q, 'weak'), isNotEmpty);
      expect(validate(q, 'Strong1!'), isEmpty);
    });

    test('Number (id 1) rejects letters even with null regex', () {
      final q = questionWithNullRegex(
        id: 1,
        enTitle: 'Number',
        arTitle: 'رقم',
      );
      expect(validate(q, 'abc'), isNotEmpty);
      expect(validate(q, '123'), isEmpty);
    });

    test('Integer (id 3) rejects decimals even with null regex', () {
      final q = questionWithNullRegex(
        id: 3,
        enTitle: 'Integer (Positive or Negative)',
        arTitle: 'عدد صحيح',
      );
      expect(validate(q, '1.5'), isNotEmpty);
      expect(validate(q, '15'), isEmpty);
    });

    test('Letters Only (id 11) rejects digits even with null regex', () {
      final q = questionWithNullRegex(
        id: 11,
        enTitle: 'Letters Only',
        arTitle: 'أحرف فقط',
      );
      expect(validate(q, 'abc123'), isNotEmpty);
      expect(validate(q, 'abc'), isEmpty);
    });

    test('English-only (id 23) rejects Arabic even with null regex', () {
      final q = questionWithNullRegex(
        id: 23,
        enTitle: 'English Text Only',
        arTitle: 'نص إنجليزي فقط',
      );
      expect(validate(q, 'مرحبا'), isNotEmpty);
      expect(validate(q, 'hello'), isEmpty);
    });

    test('No-Spaces (id 17) rejects spaces even with null regex', () {
      final q = questionWithNullRegex(
        id: 17,
        enTitle: 'No Spaces',
        arTitle: 'بدون مسافات',
      );
      expect(validate(q, 'a b'), isNotEmpty);
      expect(validate(q, 'abc'), isEmpty);
    });
  });
}
