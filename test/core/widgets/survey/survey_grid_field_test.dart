import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_option_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_row_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_grid_field.dart';

Question _question(QuestionType type) => Question(
      id: 1,
      type: type,
      label: 'Q',
      questionRows: const [
        QuestionRow(id: 10, label: 'Row A', value: 'a', order: 0),
        QuestionRow(id: 11, label: 'Row B', value: 'b', order: 1),
      ],
      questionOptions: const [
        QuestionOption(id: 20, label: 'Yes', value: 'yes', order: 0),
        QuestionOption(id: 21, label: 'No',  value: 'no',  order: 1),
      ],
    );

Widget _wrap(Widget child) => MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('SurveyGridField (single-select)', () {
    testWidgets('emits Map<String,String> keyed by row.value on tap',
        (tester) async {
      Map<String, String>? captured;
      await tester.pumpWidget(_wrap(SurveyGridField(
        question: _question(QuestionType.singleSelectGrid),
        onChanged: (v) => captured = (v as Map).cast<String, String>(),
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('grid-cell-a-yes')));
      await tester.pump();

      expect(captured, {'a': 'yes'});
    });

    testWidgets('picking another option for the same row replaces selection',
        (tester) async {
      Map<String, String>? captured;
      await tester.pumpWidget(_wrap(SurveyGridField(
        question: _question(QuestionType.singleSelectGrid),
        value: const {'a': 'yes'},
        onChanged: (v) => captured = (v as Map).cast<String, String>(),
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('grid-cell-a-no')));
      await tester.pump();

      expect(captured, {'a': 'no'});
    });
  });

  group('SurveyGridField (multi-select)', () {
    testWidgets('toggling two options produces a list for that row',
        (tester) async {
      Map<String, List<String>>? captured;
      await tester.pumpWidget(_wrap(SurveyGridField(
        question: _question(QuestionType.multiSelectGrid),
        value: const {},
        onChanged: (v) => captured =
            (v as Map).map((k, val) => MapEntry(k as String, (val as List).cast<String>())),
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('grid-cell-b-yes')));
      await tester.pump();
      expect(captured, {'b': ['yes']});

      await tester.tap(find.byKey(const ValueKey('grid-cell-b-no')));
      await tester.pump();
      expect(captured, {'b': ['yes', 'no']});
    });

    testWidgets('unticking last option removes the row key', (tester) async {
      dynamic captured;
      await tester.pumpWidget(_wrap(SurveyGridField(
        question: _question(QuestionType.multiSelectGrid),
        value: const {'a': ['yes']},
        onChanged: (v) => captured = v,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('grid-cell-a-yes')));
      await tester.pump();
      expect(captured, {});
    });
  });
}
