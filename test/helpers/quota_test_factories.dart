import 'package:king_abdulaziz_center_survey_app/core/models/survey/assignment_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_option_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/quota_coordinate.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/researcher_quota_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/section_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/survey_model.dart';

/// Builds a [QuotaCoordinate] with sensible defaults so tests can specify only
/// the fields the [BindingInferer] consumes.
QuotaCoordinate coord({
  required int scopeCriterionId,
  required String criterionName,
  required int categoryId,
  required String value,
  String? label,
  int order = 0,
}) {
  return QuotaCoordinate(
    scopeCriterionId: scopeCriterionId,
    criterionName: criterionName,
    scopeCriterionCategoryId: categoryId,
    categoryLabel: label ?? value,
    categoryValue: value,
    order: order,
  );
}

QuestionOption _option(int id, String value) {
  return QuestionOption(
    id: id,
    label: value,
    value: value,
  );
}

Question _question({
  required int id,
  required List<String> optionValues,
}) {
  return Question(
    id: id,
    label: 'Question $id',
    questionOptions: [
      for (var i = 0; i < optionValues.length; i++)
        _option(id * 1000 + i + 1, optionValues[i]),
    ],
  );
}

Survey _surveyWithQuestions(List<Question> questions) {
  return Survey(
    id: 1,
    lang: 'en',
    sections: [
      Section(id: 1, title: 'Section 1', questions: questions),
    ],
  );
}

Survey makeSurveyWithSingleQuestion({
  required int questionId,
  required List<String> optionValues,
}) {
  return _surveyWithQuestions([
    _question(id: questionId, optionValues: optionValues),
  ]);
}

Survey makeSurveyWithTwoQuestions({
  required List<int> ids,
  required List<String> optionValuesEach,
}) {
  return _surveyWithQuestions([
    for (final id in ids) _question(id: id, optionValues: optionValuesEach),
  ]);
}

Survey makeSurveyWithThreeQuestions({
  required int regionQuestionId,
  required List<String> regionOptions,
  required int genderQuestionId,
  required List<String> genderOptions,
  required int ageQuestionId,
  required List<String> ageOptions,
}) {
  return _surveyWithQuestions([
    _question(id: regionQuestionId, optionValues: regionOptions),
    _question(id: genderQuestionId, optionValues: genderOptions),
    _question(id: ageQuestionId, optionValues: ageOptions),
  ]);
}

/// Bundles every supplied coordinate into a single [ResearcherQuota] hung off
/// one [Assignment]. The inferer aggregates across all quotas, so this single-
/// bucket shape exercises the same code path as a multi-bucket plan.
Assignment makeAssignmentWithCoordinates(List<QuotaCoordinate> coords) {
  final now = DateTime(2024, 1, 1);
  return Assignment(
    id: 1,
    surveyId: 1,
    researcherQuotas: [
      ResearcherQuota(
        id: 1,
        assignmentId: 1,
        target: 10,
        coordinates: List<QuotaCoordinate>.from(coords),
        createdAt: now,
        updatedAt: now,
      ),
    ],
  );
}
