import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_rating_field.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('defaults to 5 stars when no validation specifies max',
      (tester) async {
    await tester.pumpWidget(_wrap(SurveyRatingField(
      question: const Question(id: 1, type: QuestionType.rating, label: 'Rate'),
      onChanged: (_) {},
    )));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
  });

  testWidgets('uses max from validation values when present', (tester) async {
    final q = Question(
      id: 1,
      type: QuestionType.rating,
      label: 'Rate',
      questionValidations: [
        QuestionValidation(
          id: 1,
          values: const {'max': 10},
          validation: const Validation(
            id: 1,
            type: ValidationType.questions,
            enTitle: 'Maximum Value',
          ),
        ),
      ],
    );
    await tester.pumpWidget(_wrap(SurveyRatingField(
      question: q,
      onChanged: (_) {},
    )));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(10));
  });
}
