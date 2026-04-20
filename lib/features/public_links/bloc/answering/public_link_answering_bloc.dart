import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/survey/section_model.dart';
import '../../../../core/models/survey/conditional_logic_model.dart';
import '../../../../core/utils/survey_behavior_manager.dart';
import '../../models/public_link_start_result.dart';
import '../../repository/public_links_online_repository.dart';
import 'public_link_answering_event.dart';
import 'public_link_answering_state.dart';

// ---------------------------------------------------------------------------
// Injected function types (allow test injection without HTTP)
// ---------------------------------------------------------------------------

typedef PublicLinkStarter = Future<PublicLinkStartResult> Function({
  required String shortCode,
  required String gender,
  required String ageGroup,
  ({double latitude, double longitude})? location,
});

typedef PublicLinkSectionSubmitter = Future<PublicLinkSectionResult> Function({
  required String shortCode,
  required int responseId,
  required int sectionId,
  required List<({int questionId, dynamic value})> answers,
});

// ---------------------------------------------------------------------------
// Bloc
// ---------------------------------------------------------------------------

class PublicLinkAnsweringBloc
    extends Bloc<PublicLinkAnsweringEvent, PublicLinkAnsweringState> {
  final String shortCode;
  final PublicLinkStarter _starter;
  final PublicLinkSectionSubmitter _sectionSubmitter;

  /// Stores the last StartAnswering event so [Retry] can replay it.
  StartAnswering? _lastStartEvent;

  PublicLinkAnsweringBloc({
    required this.shortCode,
    PublicLinkStarter? starter,
    PublicLinkSectionSubmitter? sectionSubmitter,
  })  : _starter = starter ?? PublicLinksOnlineRepository.startPublicLinkResponse,
        _sectionSubmitter =
            sectionSubmitter ?? PublicLinksOnlineRepository.submitPublicLinkSection,
        super(const PublicLinkAnsweringInitial()) {
    on<StartAnswering>(_onStartAnswering);
    on<AnswerChanged>(_onAnswerChanged);
    on<SubmitCurrentSection>(_onSubmitCurrentSection);
    on<Retry>(_onRetry);
  }

  // -------------------------------------------------------------------------
  // Handlers
  // -------------------------------------------------------------------------

  Future<void> _onStartAnswering(
    StartAnswering event,
    Emitter<PublicLinkAnsweringState> emit,
  ) async {
    _lastStartEvent = event;
    emit(const PublicLinkAnsweringStarting());
    try {
      final result = await _starter(
        shortCode: shortCode,
        gender: event.gender,
        ageGroup: event.ageGroup,
        location: event.location,
      );
      emit(
        PublicLinkAnsweringSection(
          responseId: result.responseId,
          section: result.firstSection,
          answers: const {},
          conditionalLogics: result.conditionalLogics,
          errors: const {},
        ),
      );
    } on DioException catch (e) {
      emit(PublicLinkAnsweringError(
        kind: _dioKind(e),
        message: e.message ?? 'Network error',
      ));
    } catch (e) {
      emit(PublicLinkAnsweringError(
        kind: PublicLinkAnsweringErrorKind.unknown,
        message: e.toString(),
      ));
    }
  }

  void _onAnswerChanged(
    AnswerChanged event,
    Emitter<PublicLinkAnsweringState> emit,
  ) {
    final s = state;
    if (s is! PublicLinkAnsweringSection) return;

    final newAnswers = Map<int, dynamic>.from(s.answers)
      ..[event.questionId] = event.value;

    // Clear error for this question
    final newErrors = Map<int, String>.from(s.errors)
      ..remove(event.questionId);

    emit(s.copyWith(answers: newAnswers, errors: newErrors));
  }

  Future<void> _onSubmitCurrentSection(
    SubmitCurrentSection event,
    Emitter<PublicLinkAnsweringState> emit,
  ) async {
    final s = state;
    if (s is! PublicLinkAnsweringSection) return;

    // ---- Validate required visible questions ----
    final behavior = SurveyBehaviorManager.calculateBehavior(
      logics: s.conditionalLogics,
      answers: s.answers,
    );
    final visibilityMap = behavior['visibility'] as Map<String, bool>? ?? {};
    final requirementMap = behavior['requirement'] as Map<String, bool>? ?? {};

    bool isQuestionVisible(int id) {
      // If conditional logic explicitly marks it, use that; default to visible.
      return visibilityMap['question_$id'] ?? true;
    }

    bool isQuestionRequired(int qId, bool baseRequired) {
      // Conditional logic may override the base requirement.
      return requirementMap['question_$qId'] ?? baseRequired;
    }

    final errors = <int, String>{};
    for (final q in s.section.questions ?? <dynamic>[]) {
      if (!isQuestionVisible(q.id)) continue;
      final required = isQuestionRequired(q.id, q.isRequired ?? false);
      if (!required) continue;
      final val = s.answers[q.id];
      if (val == null || (val is String && val.trim().isEmpty)) {
        errors[q.id] = 'This field is required';
      }
    }

    if (errors.isNotEmpty) {
      emit(s.copyWith(errors: errors));
      return;
    }

    // ---- Submit to backend ----
    emit(s.copyWith(submitting: true, errors: const {}));

    final answerPayload = s.answers.entries.map((e) {
      return (questionId: e.key, value: e.value);
    }).toList();

    try {
      final result = await _sectionSubmitter(
        shortCode: shortCode,
        responseId: s.responseId,
        sectionId: s.section.id,
        answers: answerPayload,
      );

      if (result.isComplete) {
        emit(PublicLinkAnsweringCompleted(
          status: result.status,
          rejectionReason: result.rejectionReason,
        ));
      } else {
        final nextSection = result.nextSection;
        if (nextSection == null) {
          // Defensive: treat missing next_section as completion
          emit(const PublicLinkAnsweringCompleted());
        } else {
          emit(PublicLinkAnsweringSection(
            responseId: s.responseId,
            section: nextSection,
            answers: const {},
            conditionalLogics: s.conditionalLogics,
            errors: const {},
          ));
        }
      }
    } on DioException catch (e) {
      emit(PublicLinkAnsweringError(
        kind: _dioKind(e),
        message: e.message ?? 'Network error',
      ));
    } catch (e) {
      emit(PublicLinkAnsweringError(
        kind: PublicLinkAnsweringErrorKind.unknown,
        message: e.toString(),
      ));
    }
  }

  void _onRetry(Retry event, Emitter<PublicLinkAnsweringState> emit) {
    final s = state;
    if (s is! PublicLinkAnsweringError) return;
    if (_lastStartEvent != null) {
      add(_lastStartEvent!);
    }
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  static PublicLinkAnsweringErrorKind _dioKind(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return PublicLinkAnsweringErrorKind.offline;
    }
    return PublicLinkAnsweringErrorKind.server;
  }
}
