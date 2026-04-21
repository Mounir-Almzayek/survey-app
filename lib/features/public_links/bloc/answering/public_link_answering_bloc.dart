import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/models/survey/section_model.dart';
import '../../../../core/utils/survey_behavior_manager.dart';
import '../../../../core/utils/survey_validator.dart';
import '../../models/public_link_start_result.dart';
import '../../repository/public_links_online_repository.dart';
import '../../utils/section_defaults_resolver.dart';
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
      // A survey with no sections is finished the moment we start it —
      // skip straight to completion instead of trying to render a null
      // section.
      final firstSection = result.firstSection;
      if (firstSection == null) {
        emit(const PublicLinkAnsweringCompleted(status: 'SUBMITTED'));
        return;
      }
      emit(
        PublicLinkAnsweringSection(
          responseId: result.responseId,
          section: firstSection,
          sectionNumber: 1,
          answers: SectionDefaultsResolver.defaultsFor(firstSection),
          priorAnswers: const {},
          conditionalLogics: result.conditionalLogics,
          errors: const {},
        ),
      );
    } on DioException catch (e) {
      emit(PublicLinkAnsweringError(
        kind: _dioKind(e),
        message: e.message ?? S.current.network_error,
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

    // Empty strings are normalized to null so required-checks behave consistently.
    final sanitized = SurveyValidator.sanitizeValue(event.value);

    final newAnswers = Map<int, dynamic>.from(s.answers)
      ..[event.questionId] = sanitized;

    // Clear error for this question — user is editing.
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

    // ---- Validate required + custom rules on visible questions ----
    // Logic must see ALL answers (current + prior) because cross-section
    // rules reference earlier sections' choices, just like the web does.
    final mergedAnswers = s.mergedAnswers;
    final behavior = SurveyBehaviorManager.calculateBehavior(
      logics: s.conditionalLogics,
      answers: mergedAnswers,
    );
    final visibilityMap = behavior['visibility'] as Map<String, bool>? ?? {};
    final requirementMap = behavior['requirement'] as Map<String, bool>? ?? {};

    bool isQuestionVisible(int id) =>
        visibilityMap['question_$id'] ?? true;

    bool isQuestionRequired(int qId, bool baseRequired) =>
        requirementMap['question_$qId'] ?? baseRequired;

    final locale = Intl.defaultLocale ?? 'en';
    final errors = <int, String>{};
    for (final q in s.section.questions ?? []) {
      if (!isQuestionVisible(q.id)) continue;
      final required = isQuestionRequired(q.id, q.isRequired ?? false);
      final val = s.answers[q.id];

      // 1. Required check
      if (required && SurveyValidator.isValueEmpty(val)) {
        errors[q.id] = S.current.field_required;
        continue;
      }

      // 2. Custom validations (length / numeric range / regex)
      final validationErrors = SurveyValidator.validateQuestion(
        question: q,
        value: val,
        locale: locale,
        isRequired: required,
      );
      if (validationErrors.isNotEmpty) {
        errors[q.id] = validationErrors.join('\n');
      }
    }

    if (errors.isNotEmpty) {
      emit(s.copyWith(errors: errors));
      return;
    }

    // ---- Submit to backend ----
    emit(s.copyWith(submitting: true, errors: const {}));

    // Send only this section's visible answers — never include prior
    // sections' answers (the backend already has them).
    final answerPayload = s.answers.entries
        .where((e) => isQuestionVisible(e.key))
        .map((e) => (questionId: e.key, value: e.value))
        .toList();

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
        return;
      }

      final nextSection = result.nextSection;
      if (nextSection == null) {
        // Defensive: treat missing next_section as completion.
        emit(const PublicLinkAnsweringCompleted());
        return;
      }

      // Roll the just-submitted section's answers into priorAnswers and
      // start the new section with its defaults pre-applied.
      final nextPrior = _foldIntoPrior(s.priorAnswers, s.answers);
      emit(_buildSectionState(
        responseId: s.responseId,
        section: nextSection,
        sectionNumber: s.sectionNumber + 1,
        priorAnswers: nextPrior,
        conditionalLogics: s.conditionalLogics,
      ));
    } on DioException catch (e) {
      emit(PublicLinkAnsweringError(
        kind: _dioKind(e),
        message: e.message ?? S.current.network_error,
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

  /// Folds `current` answers into the immutable `prior` map, returning a
  /// fresh map. Used when leaving a section so subsequent logic can see
  /// the full answer history.
  static Map<int, dynamic> _foldIntoPrior(
    Map<int, dynamic> prior,
    Map<int, dynamic> current,
  ) =>
      <int, dynamic>{...prior, ...current};

  /// Builds the section state for [section] with defaults pre-filled, so
  /// the user lands on a section that already reflects `is_default: true`
  /// option choices.
  static PublicLinkAnsweringSection _buildSectionState({
    required int responseId,
    required Section section,
    required int sectionNumber,
    required Map<int, dynamic> priorAnswers,
    required List conditionalLogics,
  }) {
    return PublicLinkAnsweringSection(
      responseId: responseId,
      section: section,
      sectionNumber: sectionNumber,
      answers: SectionDefaultsResolver.defaultsFor(section),
      priorAnswers: priorAnswers,
      conditionalLogics: conditionalLogics.cast(),
      errors: const {},
    );
  }

  static PublicLinkAnsweringErrorKind _dioKind(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return PublicLinkAnsweringErrorKind.offline;
    }
    return PublicLinkAnsweringErrorKind.server;
  }
}
