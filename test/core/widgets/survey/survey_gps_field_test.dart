import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_gps_field.dart';

import '../../../helpers/test_env.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: child),
      ),
    );

void main() {
  setUpAll(loadTestEnv);

  testWidgets('renders with preset lat/lng map value', (tester) async {
    await tester.pumpWidget(_wrap(SurveyGpsField(
      question: const Question(id: 1, type: QuestionType.gps, label: 'Loc'),
      value: const {'latitude': 24.72169, 'longitude': 46.75702},
      onChanged: (_) {},
    )));
    await tester.pump();
    expect(find.textContaining('24.72169'), findsOneWidget);
  });
}
