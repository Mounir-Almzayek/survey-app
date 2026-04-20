import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/condition_action_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/condition_rule_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/conditional_logic_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/section_model.dart';
import 'package:king_abdulaziz_center_survey_app/features/public_links/bloc/answering/public_link_answering_bloc.dart';
import 'package:king_abdulaziz_center_survey_app/features/public_links/bloc/answering/public_link_answering_event.dart'
    hide Retry;
import 'package:king_abdulaziz_center_survey_app/features/public_links/bloc/answering/public_link_answering_event.dart'
    as events show Retry;
import 'package:king_abdulaziz_center_survey_app/features/public_links/bloc/answering/public_link_answering_state.dart';
import 'package:king_abdulaziz_center_survey_app/features/public_links/models/public_link_start_result.dart';

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

final _requiredQuestion = Question(
  id: 1,
  type: QuestionType.textShort,
  label: 'Name',
  isRequired: true,
);

final _section1 = Section(
  id: 10,
  title: 'Section 1',
  questions: [_requiredQuestion],
);

final _section2 = Section(id: 20, title: 'Section 2', questions: []);

final _startResult = PublicLinkStartResult(
  responseId: 99,
  firstSection: _section1,
  conditionalLogics: [],
);

final _sectionResultContinue = PublicLinkSectionResult(
  isComplete: false,
  nextSection: _section2,
);

final _sectionResultComplete = PublicLinkSectionResult(
  isComplete: true,
  status: 'SUBMITTED',
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PublicLinkAnsweringBloc _bloc({
  PublicLinkStarter? starter,
  PublicLinkSectionSubmitter? sectionSubmitter,
}) {
  return PublicLinkAnsweringBloc(
    shortCode: 'abc',
    starter: starter,
    sectionSubmitter: sectionSubmitter,
  );
}

Future<PublicLinkStartResult> _successStarter({
  required String shortCode,
  required String gender,
  required String ageGroup,
  ({double latitude, double longitude})? location,
}) async =>
    _startResult;

Future<PublicLinkSectionResult> _continueSectionSubmitter({
  required String shortCode,
  required int responseId,
  required int sectionId,
  required List<({int questionId, dynamic value})> answers,
}) async =>
    _sectionResultContinue;

Future<PublicLinkSectionResult> _completeSectionSubmitter({
  required String shortCode,
  required int responseId,
  required int sectionId,
  required List<({int questionId, dynamic value})> answers,
}) async =>
    _sectionResultComplete;

DioException _offlineError() => DioException(
      requestOptions: RequestOptions(path: ''),
      type: DioExceptionType.connectionError,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PublicLinkAnsweringBloc', () {
    // 1. StartAnswering success -> Section state
    blocTest<PublicLinkAnsweringBloc, PublicLinkAnsweringState>(
      'StartAnswering success emits Starting then Section',
      build: () => _bloc(starter: _successStarter),
      act: (b) => b.add(const StartAnswering(gender: 'MALE', ageGroup: 'AGE_18_29')),
      expect: () => [
        const PublicLinkAnsweringStarting(),
        isA<PublicLinkAnsweringSection>()
            .having((s) => s.responseId, 'responseId', 99)
            .having((s) => s.section.id, 'sectionId', 10)
            .having((s) => s.answers, 'answers', isEmpty),
      ],
    );

    // 2. StartAnswering offline -> Error(offline)
    blocTest<PublicLinkAnsweringBloc, PublicLinkAnsweringState>(
      'StartAnswering offline error emits Error(offline)',
      build: () => _bloc(
        starter: ({required shortCode, required gender, required ageGroup, location}) async =>
            throw _offlineError(),
      ),
      act: (b) => b.add(const StartAnswering(gender: 'MALE', ageGroup: 'AGE_18_29')),
      expect: () => [
        const PublicLinkAnsweringStarting(),
        isA<PublicLinkAnsweringError>()
            .having((s) => s.kind, 'kind', PublicLinkAnsweringErrorKind.offline),
      ],
    );

    // 3. AnswerChanged updates answers + re-runs conditional logic for visibility
    blocTest<PublicLinkAnsweringBloc, PublicLinkAnsweringState>(
      'AnswerChanged updates answers map and clears error for that question',
      build: () => _bloc(starter: _successStarter),
      seed: () => PublicLinkAnsweringSection(
        responseId: 99,
        section: _section1,
        answers: const {},
        conditionalLogics: const [],
        errors: const {1: 'Required'},
      ),
      act: (b) => b.add(const AnswerChanged(questionId: 1, value: 'John')),
      expect: () => [
        isA<PublicLinkAnsweringSection>()
            .having((s) => s.answers[1], 'answer', 'John')
            .having((s) => s.errors, 'errors', isEmpty),
      ],
    );

    // 4. AnswerChanged triggers visibility change via conditional logic
    blocTest<PublicLinkAnsweringBloc, PublicLinkAnsweringState>(
      'AnswerChanged with conditional logic changes visibility in answers map',
      build: () => _bloc(starter: _successStarter),
      seed: () {
        final hiddenQuestion = Question(
          id: 2,
          type: QuestionType.textShort,
          label: 'Hidden',
          isRequired: false,
        );
        final section = Section(
          id: 10,
          questions: [_requiredQuestion, hiddenQuestion],
        );
        final logic = ConditionalLogic(
          id: 1,
          enabled: true,
          conditionRules: [
            ConditionRule(
              id: 1,
              questionId: 1,
              operator: ConditionOperator.eq,
              value: 'show',
              order: 0,
            ),
          ],
          actions: [
            ConditionAction(
              id: 1,
              targetType: ActionTargetType.question,
              targetId: 2,
              actionType: ActionType.show,
              order: 0,
            ),
          ],
        );
        return PublicLinkAnsweringSection(
          responseId: 99,
          section: section,
          answers: const {},
          conditionalLogics: [logic],
          errors: const {},
        );
      },
      act: (b) => b.add(const AnswerChanged(questionId: 1, value: 'show')),
      expect: () => [
        isA<PublicLinkAnsweringSection>()
            .having((s) => s.answers[1], 'answer', 'show'),
      ],
    );

    // 5. SubmitCurrentSection: required question unanswered -> errors, no submit
    blocTest<PublicLinkAnsweringBloc, PublicLinkAnsweringState>(
      'SubmitCurrentSection with unanswered required question sets errors',
      build: () {
        var submitted = false;
        return _bloc(
          starter: _successStarter,
          sectionSubmitter: ({
            required shortCode,
            required responseId,
            required sectionId,
            required answers,
          }) async {
            submitted = true;
            return _continueSectionSubmitter(
              shortCode: shortCode,
              responseId: responseId,
              sectionId: sectionId,
              answers: answers,
            );
          },
        );
      },
      seed: () => PublicLinkAnsweringSection(
        responseId: 99,
        section: _section1,
        answers: const {},
        conditionalLogics: const [],
        errors: const {},
      ),
      act: (b) => b.add(const SubmitCurrentSection()),
      expect: () => [
        isA<PublicLinkAnsweringSection>()
            .having((s) => s.errors, 'errors', isNotEmpty),
      ],
    );

    // 6. SubmitCurrentSection: answered, backend returns next section
    blocTest<PublicLinkAnsweringBloc, PublicLinkAnsweringState>(
      'SubmitCurrentSection success continues to next section',
      build: () => _bloc(
        starter: _successStarter,
        sectionSubmitter: _continueSectionSubmitter,
      ),
      seed: () => PublicLinkAnsweringSection(
        responseId: 99,
        section: _section1,
        answers: const {1: 'John'},
        conditionalLogics: const [],
        errors: const {},
      ),
      act: (b) => b.add(const SubmitCurrentSection()),
      expect: () => [
        isA<PublicLinkAnsweringSection>()
            .having((s) => s.submitting, 'submitting', true),
        isA<PublicLinkAnsweringSection>()
            .having((s) => s.section.id, 'sectionId', 20)
            .having((s) => s.answers, 'answers', isEmpty),
      ],
    );

    // 7. SubmitCurrentSection: backend returns is_complete=true -> Completed
    blocTest<PublicLinkAnsweringBloc, PublicLinkAnsweringState>(
      'SubmitCurrentSection with is_complete=true emits Completed',
      build: () => _bloc(
        starter: _successStarter,
        sectionSubmitter: _completeSectionSubmitter,
      ),
      seed: () => PublicLinkAnsweringSection(
        responseId: 99,
        section: _section1,
        answers: const {1: 'John'},
        conditionalLogics: const [],
        errors: const {},
      ),
      act: (b) => b.add(const SubmitCurrentSection()),
      expect: () => [
        isA<PublicLinkAnsweringSection>()
            .having((s) => s.submitting, 'submitting', true),
        isA<PublicLinkAnsweringCompleted>()
            .having((s) => s.status, 'status', 'SUBMITTED'),
      ],
    );

    // 8. Retry from Error replays last StartAnswering
    blocTest<PublicLinkAnsweringBloc, PublicLinkAnsweringState>(
      'Retry from Error replays StartAnswering',
      build: () {
        var attempt = 0;
        return _bloc(
          starter: ({required shortCode, required gender, required ageGroup, location}) async {
            attempt++;
            if (attempt == 1) throw _offlineError();
            return _startResult;
          },
        );
      },
      act: (b) async {
        b.add(const StartAnswering(gender: 'MALE', ageGroup: 'AGE_18_29'));
        await Future.delayed(const Duration(milliseconds: 10));
        b.add(const events.Retry());
      },
      expect: () => [
        const PublicLinkAnsweringStarting(),
        isA<PublicLinkAnsweringError>(),
        const PublicLinkAnsweringStarting(),
        isA<PublicLinkAnsweringSection>(),
      ],
    );
  });
}
