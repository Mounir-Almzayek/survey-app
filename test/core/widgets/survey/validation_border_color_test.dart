// Verifies the red border on the question card reacts to live-validation
// errors as well as submit-time errors. Pre-fix the border only flipped on
// `errorText` (set after the user pressed Next), so a user who typed an
// invalid value saw only a small text under the field — easy to miss.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/styles/app_colors.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_question_renderer.dart';

import '../../validation/_fixtures/seeded_validations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async => await S.load(const Locale('en')));

  Widget harness(Question question, ValueNotifier<dynamic> v) => MaterialApp(
        home: ScreenUtilInit(
          designSize: const Size(375, 812),
          child: Scaffold(
            body: ValueListenableBuilder<dynamic>(
              valueListenable: v,
              builder: (_, val, __) => SurveyQuestionRenderer(
                question: question,
                value: val,
                onAnswerChange: (next) => v.value = next,
              ),
            ),
          ),
        ),
      );

  /// Pulls the destructive color out of the outer card Container's border.
  /// `find.byType(Container)` matches several wrappers, so look for the one
  /// whose decoration carries a Border.
  Color? cardBorderColor(WidgetTester tester) {
    final containers = tester.widgetList<Container>(find.byType(Container));
    for (final c in containers) {
      final d = c.decoration;
      if (d is BoxDecoration && d.border is Border) {
        return (d.border as Border).top.color;
      }
    }
    return null;
  }

  testWidgets('card border turns red while live validation has an error',
      (tester) async {
    final value = ValueNotifier<dynamic>(null);
    await tester.pumpWidget(harness(
      Question(
        id: 1,
        type: QuestionType.textShort,
        label: 'q',
        questionValidations: [
          QuestionValidation(
            id: 1,
            questionId: 1,
            validationId: vEmail.id,
            values: const {},
            validation: vEmail,
          ),
        ],
      ),
      value,
    ));

    // Pristine — neutral border.
    expect(cardBorderColor(tester), isNot(AppColors.destructive));

    // Type something invalid, wait for the 350ms debounce.
    await tester.enterText(find.byType(TextField).first, 'not_an_email');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(cardBorderColor(tester), AppColors.destructive,
        reason: 'live error must flip the card border red');
  });
}
