import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/live_validation_controller.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_question_card.dart';

import '../../validation/_fixtures/seeded_validations.dart';

Widget _harness(Widget child) => MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  testWidgets('pristine field with controller — no error rendered', (tester) async {
    final q = Question(
      id: 1,
      type: QuestionType.textShort,
      label: 'q',
      isRequired: true,
      questionValidations: [
        QuestionValidation(
          id: 1,
          questionId: 1,
          validationId: 1,
          values: const {},
          validation: vNumber,
        ),
      ],
    );
    final c = LiveValidationController(question: q, locale: 'en');
    addTearDown(c.dispose);

    await tester.pumpWidget(_harness(SurveyQuestionCard(
      label: q.label,
      isRequired: q.isRequired,
      validations: q.questionValidations,
      liveController: c,
      child: const SizedBox(height: 40),
    )));

    expect(find.textContaining('Value must be a number'), findsNothing);
  });

  testWidgets('error renders after onChanged + debounce', (tester) async {
    final q = Question(
      id: 1,
      type: QuestionType.textShort,
      label: 'q',
      questionValidations: [
        QuestionValidation(
          id: 1, questionId: 1, validationId: 1,
          values: const {}, validation: vNumber,
        ),
      ],
    );
    final c = LiveValidationController(
      question: q, locale: 'en',
      debounce: const Duration(milliseconds: 50),
    );
    addTearDown(c.dispose);

    await tester.pumpWidget(_harness(SurveyQuestionCard(
      label: q.label,
      validations: q.questionValidations,
      liveController: c,
      child: const SizedBox(height: 40),
    )));

    c.onChanged('abc');
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    expect(find.textContaining('Value must be a number'), findsOneWidget);
  });

  testWidgets('errorText (from bloc) overrides live error', (tester) async {
    final q = Question(
      id: 1, type: QuestionType.textShort, label: 'q',
      questionValidations: [
        QuestionValidation(
          id: 1, questionId: 1, validationId: 1,
          values: const {}, validation: vNumber,
        ),
      ],
    );
    final c = LiveValidationController(
      question: q, locale: 'en',
      debounce: const Duration(milliseconds: 50),
    );
    addTearDown(c.dispose);

    await tester.pumpWidget(_harness(SurveyQuestionCard(
      label: q.label,
      errorText: 'BLOC-ERROR',
      validations: q.questionValidations,
      liveController: c,
      child: const SizedBox(height: 40),
    )));

    c.onChanged('abc');
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    // Bloc error wins.
    expect(find.text('BLOC-ERROR'), findsOneWidget);
    expect(find.textContaining('Value must be a number'), findsNothing);
  });
}
