import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_file_field.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: const [S.delegate],
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('SurveyFileField (eager upload)', () {
    testWidgets('success path writes server path via onChanged', (tester) async {
      String? captured;
      Future<String> fakeUploader(XFile f) async =>
          '/uploads/images/mock.jpg';

      final widget = SurveyFileField(
        question: const Question(id: 1, type: QuestionType.file, label: 'Img'),
        uploader: fakeUploader,
        picker: (_) async => XFile('/tmp/mock.jpg'),
        onChanged: (v) => captured = v,
      );

      await tester.pumpWidget(_wrap(widget));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('file-pick-button')));
      await tester.pumpAndSettle();

      expect(captured, '/uploads/images/mock.jpg');
    });

    testWidgets('failure path shows retry and does not update answer',
        (tester) async {
      String? captured;
      Future<String> throwingUploader(XFile f) async =>
          throw Exception('network down');

      final widget = SurveyFileField(
        question: const Question(id: 1, type: QuestionType.file, label: 'Img'),
        uploader: throwingUploader,
        picker: (_) async => XFile('/tmp/mock.jpg'),
        onChanged: (v) => captured = v,
      );

      await tester.pumpWidget(_wrap(widget));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('file-pick-button')));
      await tester.pumpAndSettle();

      expect(captured, isNull);
      expect(find.byKey(const ValueKey('file-retry-button')), findsOneWidget);
    });
  });
}
