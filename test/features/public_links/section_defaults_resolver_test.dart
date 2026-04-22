import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_option_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/section_model.dart';
import 'package:king_abdulaziz_center_survey_app/features/public_links/utils/section_defaults_resolver.dart';

void main() {
  test('rating question pre-fills default option value as int', () {
    final q = Question(
      id: 9,
      type: QuestionType.rating,
      label: 'R',
      questionOptions: const [
        QuestionOption(id: 1, value: '3', isDefault: true),
        QuestionOption(id: 2, value: '5', isDefault: false),
      ],
    );
    final section = Section(id: 1, title: 's', questions: [q]);
    final result = SectionDefaultsResolver.defaultsFor(section);
    expect(result[9], 3);
  });
}
