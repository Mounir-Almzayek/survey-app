import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_question_renderer.dart';

import '../../validation/_fixtures/seeded_validations.dart';

/// End-to-end UI verification: when a user types a value that violates a
/// validation rule, the error message MUST appear on screen.
/// Mirrors the QA tester's complaints about #6, #7, #8, #9, #10, #11, #12, #13.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async => await S.load(const Locale('en')));

  Widget harness({
    required Question question,
    required ValueNotifier<dynamic> valueNotifier,
  }) {
    return MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(
          body: SingleChildScrollView(
            child: ValueListenableBuilder<dynamic>(
              valueListenable: valueNotifier,
              builder: (_, val, __) => SurveyQuestionRenderer(
                question: question,
                value: val,
                onAnswerChange: (next) => valueNotifier.value = next,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Question q({
    required QuestionType type,
    required Validation validation,
    Map<String, dynamic> values = const {},
  }) =>
      Question(
        id: 1,
        type: type,
        label: 'q',
        questionValidations: [
          QuestionValidation(
            id: 1,
            questionId: 1,
            validationId: validation.id,
            values: values,
            validation: validation,
          ),
        ],
      );

  /// Pumps long enough for the live-validation debounce (350ms default).
  Future<void> waitForDebounce(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  Future<void> typeInto(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField).first, text);
    await waitForDebounce(tester);
  }

  // ---------------------------------------------------------------------------
  // #6 — Decimal 2 places
  // ---------------------------------------------------------------------------

  testWidgets('#6 Decimal 2 places — entering "5.2" shows error message',
      (tester) async {
    final value = ValueNotifier<dynamic>(null);
    await tester.pumpWidget(harness(
      question: q(type: QuestionType.number, validation: vDecimal2),
      valueNotifier: value,
    ));

    await typeInto(tester, '5.2');
    expect(find.text('Enter a number with exactly 2 decimal places'),
        findsOneWidget);
  });

  testWidgets('#6 Decimal 2 places — entering "5.20" does NOT show error',
      (tester) async {
    final value = ValueNotifier<dynamic>(null);
    await tester.pumpWidget(harness(
      question: q(type: QuestionType.number, validation: vDecimal2),
      valueNotifier: value,
    ));

    await typeInto(tester, '5.20');
    expect(find.text('Enter a number with exactly 2 decimal places'),
        findsNothing);
  });

  // ---------------------------------------------------------------------------
  // #7 — Letters and Spaces (id 12)
  //
  // The formatter blocks digits at the keystroke level, so we test that
  // SPACES are accepted (the user's complaint) and that we still surface
  // an error for any input the formatter does let through.
  // ---------------------------------------------------------------------------

  testWidgets('#7 Letters and spaces — accepts space; no error for "hello world"',
      (tester) async {
    final value = ValueNotifier<dynamic>(null);
    await tester.pumpWidget(harness(
      question: q(type: QuestionType.textShort, validation: vLettersAndSpaces),
      valueNotifier: value,
    ));

    await typeInto(tester, 'hello world');
    // The space should pass through the formatter and validate cleanly.
    expect(find.text('Letters and spaces only'), findsNothing);
    // And the bloc value reflects what the user typed (with the space).
    expect(value.value, 'hello world');
  });

  // ---------------------------------------------------------------------------
  // #8 — Alphanumeric (no formatter — must error on symbols)
  // ---------------------------------------------------------------------------

  testWidgets('#8 Alphanumeric — entering "abc!" shows error message',
      (tester) async {
    final value = ValueNotifier<dynamic>(null);
    await tester.pumpWidget(harness(
      question: q(type: QuestionType.textShort, validation: vAlphanumeric),
      valueNotifier: value,
    ));

    await typeInto(tester, 'abc!');
    expect(find.text('Letters and numbers only'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // #9 — Arabic only: warn-don't-block — typed value is accepted, the live
  // validation message tells the user what's wrong.
  // ---------------------------------------------------------------------------

  testWidgets('#9 Arabic only — entering "Hello" shows error message',
      (tester) async {
    final value = ValueNotifier<dynamic>(null);
    await tester.pumpWidget(harness(
      question: q(type: QuestionType.textShort, validation: vArabicOnly),
      valueNotifier: value,
    ));

    await typeInto(tester, 'Hello');
    expect(find.text('Arabic text only'), findsOneWidget);
  });

  testWidgets('#9 Arabic only — typing Arabic letters is allowed',
      (tester) async {
    final value = ValueNotifier<dynamic>(null);
    await tester.pumpWidget(harness(
      question: q(type: QuestionType.textShort, validation: vArabicOnly),
      valueNotifier: value,
    ));

    await typeInto(tester, 'مرحبا');
    expect(value.value, 'مرحبا');
    expect(find.text('Arabic text only'), findsNothing);
  });

  // ---------------------------------------------------------------------------
  // #10 — No Special Characters
  // ---------------------------------------------------------------------------

  testWidgets('#10 No special chars — entering "abc!" shows error message',
      (tester) async {
    final value = ValueNotifier<dynamic>(null);
    await tester.pumpWidget(harness(
      question: q(type: QuestionType.textShort, validation: vNoSpecialChars),
      valueNotifier: value,
    ));

    await typeInto(tester, 'abc!');
    expect(find.text('Special characters are not allowed'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // #11 — Email
  // ---------------------------------------------------------------------------

  testWidgets('#11 Email — entering "not_email" shows error message',
      (tester) async {
    final value = ValueNotifier<dynamic>(null);
    await tester.pumpWidget(harness(
      question: q(type: QuestionType.textShort, validation: vEmail),
      valueNotifier: value,
    ));

    await typeInto(tester, 'not_email');
    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // #12 — URL
  // ---------------------------------------------------------------------------

  testWidgets('#12 URL — entering "abc!@#" shows error message',
      (tester) async {
    final value = ValueNotifier<dynamic>(null);
    await tester.pumpWidget(harness(
      question: q(type: QuestionType.textShort, validation: vUrl),
      valueNotifier: value,
    ));

    await typeInto(tester, 'abc!@#');
    expect(find.text('Enter a valid URL'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // #13 — Strong Password
  // ---------------------------------------------------------------------------

  testWidgets('#13 Strong password — entering "weak" shows error message',
      (tester) async {
    final value = ValueNotifier<dynamic>(null);
    await tester.pumpWidget(harness(
      question: q(type: QuestionType.textShort, validation: vStrongPassword),
      valueNotifier: value,
    ));

    await typeInto(tester, 'weak');
    expect(
      find.text(
          'Password must be 8+ characters with uppercase, lowercase, digit, and symbol'),
      findsOneWidget,
    );
  });

  // ---------------------------------------------------------------------------
  // #1 (re-check) — Saudi phone error renders
  // ---------------------------------------------------------------------------

  testWidgets('#1 Saudi phone — entering "0401234567" shows error message',
      (tester) async {
    final value = ValueNotifier<dynamic>(null);
    await tester.pumpWidget(harness(
      question: Question(
        id: 1,
        type: QuestionType.phoneNumber,
        label: 'Phone',
        isRequired: true,
        questionValidations: const [],
      ),
      valueNotifier: value,
    ));

    // Phone field uses IntlPhoneField, not a plain TextField. Find the
    // national-number text input and type into it.
    final phoneInput = find.byType(TextField).first;
    await tester.enterText(phoneInput, '0401234567');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('Must be a valid Saudi mobile number'), findsOneWidget);
  });
}
