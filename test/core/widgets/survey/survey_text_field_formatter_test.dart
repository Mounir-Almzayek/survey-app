import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  testWidgets('inputFormatters wire through to underlying TextField', (tester) async {
    // Use LengthLimitingTextInputFormatter because it filters (truncates) rather
    // than reject-and-revert: enterText sets the entire string in one update,
    // so reject-style formatters (like CharWhitelistFormatter) leave the field
    // empty and onChanged never fires. The wiring being verified is the same.
    String? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: ScreenUtilInit(
          designSize: const Size(375, 812),
          child: Scaffold(
            body: SurveyTextField(
              question: Question(id: 1, type: QuestionType.textShort, label: 'q'),
              inputFormatters: [LengthLimitingTextInputFormatter(3)],
              onChanged: (v) => captured = v,
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'abcdef');
    expect(captured, 'abc');
  });
}
