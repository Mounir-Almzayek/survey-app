import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_phone_field.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('SurveyPhoneField', () {
    testWidgets('emits E.164 when a full SA number is typed', (tester) async {
      String? captured;
      await tester.pumpWidget(_wrap(SurveyPhoneField(
        question: const Question(
            id: 1, type: QuestionType.phoneNumber, label: 'Phone'),
        onChanged: (v) => captured = v,
      )));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '501234567');
      await tester.pumpAndSettle();

      expect(captured, '+966501234567');
    });

    testWidgets('pasting +966501234567 into number field strips the prefix',
        (tester) async {
      String? captured;
      await tester.pumpWidget(_wrap(SurveyPhoneField(
        question: const Question(
            id: 1, type: QuestionType.phoneNumber, label: 'Phone'),
        onChanged: (v) => captured = v,
      )));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '+966501234567');
      await tester.pumpAndSettle();

      expect(captured, '+966501234567');
      final widget = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(widget.controller?.text.startsWith('+'), isFalse);
    });
  });
}
