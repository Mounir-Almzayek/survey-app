// New policy: text rules do NOT block typing at the keystroke level. The
// user types whatever they want; the live-validation message tells them
// what's wrong. This avoids "the keyboard ate my keystroke with no
// explanation" UX, which the field tester ran into repeatedly.
//
// Length limiters (MaxLetters, MaxLength, LengthRange) keep their
// LengthLimitingTextInputFormatter — that's a hard cap, not a per-char
// content filter, and Flutter's text editing pipeline already treats it
// as a width-of-the-input concern.

import 'package:flutter/services.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';

import '_fixtures/seeded_validations.dart';

Question questionWith(Validation v, {Map<String, dynamic> values = const {}}) =>
    Question(
      id: 1,
      type: QuestionType.textShort,
      label: 'q',
      questionValidations: [
        QuestionValidation(
          id: 1,
          questionId: 1,
          validationId: v.id,
          values: values,
          validation: v,
        ),
      ],
    );

bool hasContentBlocker(List<TextInputFormatter> fmts) =>
    fmts.any((f) => f is! LengthLimitingTextInputFormatter);

void main() {
  group('Text rules expose no keystroke-level content blockers', () {
    test('Letters Only (id 11) — no content blocker', () {
      final fmts = RuleRegistry.formattersFor(questionWith(vLettersOnly));
      expect(hasContentBlocker(fmts), isFalse,
          reason: 'rule must let the user type any character; '
              'live validation will surface the error');
    });

    test('Letters and Spaces (id 12) — no content blocker', () {
      final fmts = RuleRegistry.formattersFor(questionWith(vLettersAndSpaces));
      expect(hasContentBlocker(fmts), isFalse);
    });

    test('Max Letters (id 10) — only the length limiter survives', () {
      final fmts = RuleRegistry.formattersFor(
          questionWith(vMaxLetters, values: {'max': 10}));
      // Length limiter is allowed (it's a hard cap, not a content filter).
      expect(fmts.whereType<LengthLimitingTextInputFormatter>(), hasLength(1));
      // Anything else would be a content blocker.
      expect(hasContentBlocker(fmts), isFalse);
    });

    test('Arabic Only (id 22) — no content blocker', () {
      final fmts = RuleRegistry.formattersFor(questionWith(vArabicOnly));
      expect(hasContentBlocker(fmts), isFalse);
    });

    test('English Only (id 23) — no content blocker', () {
      final fmts = RuleRegistry.formattersFor(questionWith(vEnglishOnly));
      expect(hasContentBlocker(fmts), isFalse);
    });

    test('No Spaces (id 17) — no content blocker', () {
      final fmts = RuleRegistry.formattersFor(questionWith(vNoSpaces));
      expect(hasContentBlocker(fmts), isFalse);
    });

    test('Number (id 1) — no content blocker', () {
      final fmts = RuleRegistry.formattersFor(questionWith(vNumber));
      expect(hasContentBlocker(fmts), isFalse,
          reason: 'consistent rule: rely on live validation, not keystroke '
              'filtering, so paste is also surfaced as an error message');
    });

    test('Decimal-2 (id 5) — no content blocker', () {
      final fmts = RuleRegistry.formattersFor(questionWith(vDecimal2));
      expect(hasContentBlocker(fmts), isFalse);
    });
  });
}
