import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/assignment_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/researcher_quota_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/scope_criterion_binding.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/survey_model.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/services/quota_matcher.dart';
import '../../../helpers/quota_test_factories.dart';

void main() {
  // Reusable two-target scenario:
  //   target 100: Gender=male, Age=18-29
  //   target 200: Gender=female, Age=18-29
  Assignment makeTwoTargets() => Assignment(
    id: 1,
    surveyId: 1,
    researcherQuotas: [
      ResearcherQuota(
        id: 1,
        quotaId: 1,
        assignmentId: 1,
        quotaTargetId: 100,
        target: 10,
        coordinates: [
          coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
          coord(scopeCriterionId: 4, criterionName: 'Age', categoryId: 14, value: '18-29'),
        ],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      ResearcherQuota(
        id: 2,
        quotaId: 2,
        assignmentId: 1,
        quotaTargetId: 200,
        target: 10,
        coordinates: [
          coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 12, value: 'female'),
          coord(scopeCriterionId: 4, criterionName: 'Age', categoryId: 14, value: '18-29'),
        ],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ],
  );

  // Helper to build a Survey with the bindings and status we want.
  Survey makeSurvey({
    SurveyStatus status = SurveyStatus.published,
    List<ScopeCriterionBinding> bindings = const [],
  }) => Survey(
    id: 1,
    title: 'S',
    description: 'D',
    status: status,
    lang: 'en',
    sections: const [],
    assignments: const [],
    bindings: bindings,
  );

  group('QuotaMatcher.match', () {
    test('single-binding match', () {
      final survey = makeSurvey(bindings: [
        const ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3),
      ]);
      final asgn = Assignment(
        id: 1, surveyId: 1,
        researcherQuotas: [
          ResearcherQuota(
            id: 1, quotaId: 1, assignmentId: 1,
            quotaTargetId: 100, target: 10,
            coordinates: [coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male')],
            createdAt: DateTime(2024, 1, 1), updatedAt: DateTime(2024, 1, 1),
          ),
        ],
      );
      expect(QuotaMatcher.match(survey: survey, assignment: asgn, answers: {2: 'male'}), 100);
    });

    test('multi-binding match resolves to unique target', () {
      final survey = makeSurvey(bindings: const [
        ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3),
        ScopeCriterionBinding(sourceQuestionId: 3, scopeCriterionId: 4),
      ]);
      final asgn = makeTwoTargets();
      expect(QuotaMatcher.match(survey: survey, assignment: asgn, answers: {2: 'male', 3: '18-29'}), 100);
      expect(QuotaMatcher.match(survey: survey, assignment: asgn, answers: {2: 'female', 3: '18-29'}), 200);
    });

    test('TEST_MODE survey -> null', () {
      final survey = makeSurvey(
        status: SurveyStatus.testMode,
        bindings: const [ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3)],
      );
      expect(QuotaMatcher.match(survey: survey, assignment: makeTwoTargets(), answers: {2: 'male'}), isNull);
    });

    test('empty bindings -> null', () {
      final survey = makeSurvey();
      expect(QuotaMatcher.match(survey: survey, assignment: makeTwoTargets(), answers: const {}), isNull);
    });

    test('missing answer for a bound question -> null', () {
      final survey = makeSurvey(bindings: const [
        ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3),
      ]);
      expect(QuotaMatcher.match(survey: survey, assignment: makeTwoTargets(), answers: const {}), isNull);
    });

    test('answer that matches no category -> null', () {
      final survey = makeSurvey(bindings: const [
        ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3),
      ]);
      expect(QuotaMatcher.match(survey: survey, assignment: makeTwoTargets(), answers: {2: 'other'}), isNull);
    });

    test('coordinate-count mismatch (target needs more pairs than resolved) -> null', () {
      final survey = makeSurvey(bindings: const [
        ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3),
      ]);
      // makeTwoTargets has 2 coords each; resolved set will only have 1 -> mismatch.
      expect(QuotaMatcher.match(survey: survey, assignment: makeTwoTargets(), answers: {2: 'male'}), isNull);
    });

    test('two targets share the resolved coordinate set -> null', () {
      final asgn = Assignment(
        id: 1, surveyId: 1,
        researcherQuotas: [
          ResearcherQuota(
            id: 1, quotaId: 1, assignmentId: 1, quotaTargetId: 100, target: 10,
            coordinates: [coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male')],
            createdAt: DateTime(2024, 1, 1), updatedAt: DateTime(2024, 1, 1),
          ),
          ResearcherQuota(
            id: 99, quotaId: 99, assignmentId: 1, quotaTargetId: 999, target: 10,
            coordinates: [coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male')],
            createdAt: DateTime(2024, 1, 1), updatedAt: DateTime(2024, 1, 1),
          ),
        ],
      );
      final survey = makeSurvey(bindings: const [
        ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3),
      ]);
      expect(QuotaMatcher.match(survey: survey, assignment: asgn, answers: {2: 'male'}), isNull);
    });
  });
}
