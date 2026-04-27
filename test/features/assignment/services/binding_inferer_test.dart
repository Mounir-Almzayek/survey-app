import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/services/binding_inferer.dart';
import '../../../helpers/quota_test_factories.dart';

void main() {
  group('BindingInferer.infer', () {
    test('infers binding when one question has a superset of category values', () {
      final survey = makeSurveyWithSingleQuestion(
        questionId: 9,
        optionValues: const ['male', 'female'],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 12, value: 'female'),
      ]);

      final bindings = BindingInferer.infer(survey: survey, assignment: assignment);

      expect(bindings.length, 1);
      expect(bindings.first.sourceQuestionId, 9);
      expect(bindings.first.scopeCriterionId, 3);
    });

    test('strict superset still matches (extra option value is fine)', () {
      final survey = makeSurveyWithSingleQuestion(
        questionId: 9,
        optionValues: const ['male', 'female', 'other'],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 12, value: 'female'),
      ]);

      final bindings = BindingInferer.infer(survey: survey, assignment: assignment);
      expect(bindings.length, 1);
    });

    test('no candidate question with superset → no binding for that criterion', () {
      final survey = makeSurveyWithSingleQuestion(
        questionId: 9,
        optionValues: const ['yes', 'no'],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
      ]);

      final bindings = BindingInferer.infer(survey: survey, assignment: assignment);
      expect(bindings, isEmpty);
    });

    test('two candidate questions match → ambiguous, no binding', () {
      final survey = makeSurveyWithTwoQuestions(
        ids: const [9, 10],
        optionValuesEach: const ['male', 'female'],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 12, value: 'female'),
      ]);

      final bindings = BindingInferer.infer(survey: survey, assignment: assignment);
      expect(bindings, isEmpty);
    });

    test('multi-criterion (Region + Gender + Age) → three bindings', () {
      final survey = makeSurveyWithThreeQuestions(
        regionQuestionId: 1,
        regionOptions: const ['baha', 'jouf', 'riyadh'],
        genderQuestionId: 2,
        genderOptions: const ['male', 'female'],
        ageQuestionId: 3,
        ageOptions: const ['18-29', '30-39'],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 1, criterionName: 'Region', categoryId: 100, value: 'baha'),
        coord(scopeCriterionId: 1, criterionName: 'Region', categoryId: 101, value: 'jouf'),
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
        coord(scopeCriterionId: 4, criterionName: 'Age Group', categoryId: 14, value: '18-29'),
      ]);

      final bindings = BindingInferer.infer(survey: survey, assignment: assignment);
      final byCriterion = {for (final b in bindings) b.scopeCriterionId: b.sourceQuestionId};
      expect(byCriterion[1], 1);
      expect(byCriterion[3], 2);
      expect(byCriterion[4], 3);
    });

    test('questions with no options are ignored', () {
      final survey = makeSurveyWithSingleQuestion(
        questionId: 9,
        optionValues: const [],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
      ]);

      expect(BindingInferer.infer(survey: survey, assignment: assignment), isEmpty);
    });

    test('empty researcherQuotas → empty bindings', () {
      final survey = makeSurveyWithSingleQuestion(questionId: 9, optionValues: const ['male']);
      final assignment = makeAssignmentWithCoordinates(const []);
      expect(BindingInferer.infer(survey: survey, assignment: assignment), isEmpty);
    });

    test('output is deterministic', () {
      final survey = makeSurveyWithSingleQuestion(questionId: 9, optionValues: const ['male', 'female']);
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 12, value: 'female'),
      ]);
      final a = BindingInferer.infer(survey: survey, assignment: assignment);
      final b = BindingInferer.infer(survey: survey, assignment: assignment);
      expect(a, b);
    });

    test('case-insensitive: question option "MALE" matches category "male"', () {
      final survey = makeSurveyWithSingleQuestion(
        questionId: 9,
        optionValues: const ['MALE', 'FEMALE'],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 12, value: 'female'),
      ]);
      final bindings = BindingInferer.infer(survey: survey, assignment: assignment);
      expect(bindings.length, 1);
    });

    test('whitespace tolerance: trims option values', () {
      final survey = makeSurveyWithSingleQuestion(
        questionId: 9,
        optionValues: const ['  male  ', '  female  '],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 12, value: 'female'),
      ]);
      expect(BindingInferer.infer(survey: survey, assignment: assignment).length, 1);
    });

    test('partial overlap: question with 1 of 2 category values still binds when unique', () {
      // Researcher quota covers {male, female}, but question only lists {male}.
      // Score is 1 vs nothing else → unique top → bind.
      final survey = makeSurveyWithSingleQuestion(
        questionId: 9,
        optionValues: const ['male'],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 12, value: 'female'),
      ]);
      expect(BindingInferer.infer(survey: survey, assignment: assignment).length, 1);
    });

    test('a question used for one criterion is not reused for another', () {
      // Both criteria see this question as the best (or only) match.
      // First criterion (sorted by id) consumes it; second gets nothing.
      final survey = makeSurveyWithSingleQuestion(
        questionId: 9,
        optionValues: const ['x', 'y'],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 1, criterionName: 'A', categoryId: 100, value: 'x'),
        coord(scopeCriterionId: 2, criterionName: 'B', categoryId: 200, value: 'y'),
      ]);
      final bindings = BindingInferer.infer(survey: survey, assignment: assignment);
      // Either criterion 1 or 2 binds, but not both (sorted ascending so 1 wins).
      expect(bindings.length, 1);
      expect(bindings.first.scopeCriterionId, 1);
    });
  });
}
