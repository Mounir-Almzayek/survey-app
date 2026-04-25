import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/utils/survey_validator.dart';

import '_fixtures/seeded_validations.dart';

/// End-to-end check of the rules the QA tester reported as broken.
/// Each test mirrors the exact scenario in their bug list, going through
/// `SurveyValidator.validateQuestion` (the same code path the in-app and
/// public-link flows use at submit-time).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  Question questionWith(int validationId) => Question(
        id: 1,
        type: QuestionType.textShort,
        label: 'q',
        questionValidations: [
          QuestionValidation(
            id: 1,
            questionId: 1,
            validationId: validationId,
            values: const {},
            validation: _bySeedId(validationId),
          ),
        ],
      );

  // ---------------------------------------------------------------------------
  // Bug #6 — Decimal Number (2 decimal places): "5.2" must be rejected.
  // ---------------------------------------------------------------------------

  group('Bug #6: Decimal 2 places (id 5)', () {
    test('rejects "5.2" (only 1 decimal)', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(5),
        value: '5.2',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty,
          reason: '"5.2" has 1 decimal but rule requires exactly 2');
    });
    test('accepts "5.20"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(5),
        value: '5.20',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isEmpty);
    });
    test('rejects "5.123" (3 decimals)', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(5),
        value: '5.123',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });

    test(
        'accepts "5.20" stored as string — the renderer must NOT round-trip '
        'through num.tryParse (which would drop the trailing zero and turn '
        'a valid input into a rejected "5.2")', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(5),
        // String: what the bloc should hold after the user types "5.20".
        value: '5.20',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isEmpty);
    });

    test(
        'rejects 5.2 stored as double — proves the trailing-zero loss '
        'pre-fix: a valid "5.20" input rounds to 5.2 and fails validation', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(5),
        // Double: what the bloc holds AFTER `num.tryParse("5.20")` rounds away
        // the trailing zero. coerceString turns it back into "5.2".
        value: 5.2,
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty,
          reason:
              'Confirms why the user could not enter "5.20" pre-fix — the '
              'renderer must keep the value as a string.');
    });
  });

  // ---------------------------------------------------------------------------
  // Bug #7 — Letters and Spaces (id 12): spaces must be accepted.
  // ---------------------------------------------------------------------------

  group('Bug #7: Letters and Spaces (id 12)', () {
    test('accepts "hello world"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(12),
        value: 'hello world',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isEmpty,
          reason: 'space in the middle should be allowed');
    });
    test('accepts Arabic with space "مرحبا بك"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(12),
        value: 'مرحبا بك',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isEmpty);
    });
    test('rejects with digits "hi 1"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(12),
        value: 'hi 1',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Bug #8 — Alphanumeric (id 13): symbols must be rejected.
  // ---------------------------------------------------------------------------

  group('Bug #8: Alphanumeric (id 13)', () {
    test('rejects with symbol "abc!"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(13),
        value: 'abc!',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });
    test('rejects with @ "user@host"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(13),
        value: 'user@host',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });
    test('accepts plain "abc123"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(13),
        value: 'abc123',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Bug #9 — Arabic Text Only (id 22): English letters must be rejected.
  // ---------------------------------------------------------------------------

  group('Bug #9: Arabic-only (id 22)', () {
    test('rejects pure English "Hello"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(22),
        value: 'Hello',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });
    test('rejects mixed "مرحبا Hello"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(22),
        value: 'مرحبا Hello',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });
    test('accepts Arabic only "مرحبا"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(22),
        value: 'مرحبا',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Bug #10 — No Special Characters (id 18): symbols must be rejected.
  // ---------------------------------------------------------------------------

  group('Bug #10: No Special Characters (id 18)', () {
    test('rejects "abc!"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(18),
        value: 'abc!',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });
    test('rejects "a&b"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(18),
        value: 'a&b',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });
    test('accepts plain words and digits "abc 123"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(18),
        value: 'abc 123',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Bug #11 — Email (id 15): non-email must be rejected.
  // ---------------------------------------------------------------------------

  group('Bug #11: Email (id 15)', () {
    test('rejects "not_an_email"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(15),
        value: 'not_an_email',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });
    test('rejects "missing@tld"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(15),
        value: 'missing@tld',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });
    test('accepts "u@example.com"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(15),
        value: 'u@example.com',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Bug #12 — URL (id 16): non-URL must be rejected.
  // ---------------------------------------------------------------------------

  group('Bug #12: URL (id 16)', () {
    test('rejects bare "hello"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(16),
        value: 'hello',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });
    test('rejects "abc!@#"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(16),
        value: 'abc!@#',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });
    test('accepts "https://example.com"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(16),
        value: 'https://example.com',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Bug #13 — Strong Password (id 25): weak password must be rejected.
  // ---------------------------------------------------------------------------

  group('Bug #13: Strong Password (id 25)', () {
    test('rejects "weak"', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(25),
        value: 'weak',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });
    test('rejects "Password1" (no special char)', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(25),
        value: 'Password1',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isNotEmpty);
    });
    test('accepts "Strong1!" — wait, only 8 chars, plus all classes', () {
      final errs = SurveyValidator.validateQuestion(
        question: questionWith(25),
        value: 'Strong1!',
        locale: 'en',
        isRequired: true,
      );
      expect(errs, isEmpty);
    });
  });
}

// ---------------------------------------------------------------------------
// Helper — pull the seeded Validation by id.
// ---------------------------------------------------------------------------

Validation _bySeedId(int id) {
  for (final v in allSeededValidations) {
    if (v.id == id) return v;
  }
  throw StateError('No seeded validation with id=$id');
}
