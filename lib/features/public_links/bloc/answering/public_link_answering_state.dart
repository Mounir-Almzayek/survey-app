import 'package:equatable/equatable.dart';
import '../../../../core/models/survey/section_model.dart';
import '../../../../core/models/survey/conditional_logic_model.dart';

enum PublicLinkAnsweringErrorKind { offline, server, unknown }

sealed class PublicLinkAnsweringState extends Equatable {
  const PublicLinkAnsweringState();
}

class PublicLinkAnsweringInitial extends PublicLinkAnsweringState {
  const PublicLinkAnsweringInitial();

  @override
  List<Object?> get props => [];
}

class PublicLinkAnsweringCollectingDemographics
    extends PublicLinkAnsweringState {
  const PublicLinkAnsweringCollectingDemographics();

  @override
  List<Object?> get props => [];
}

class PublicLinkAnsweringStarting extends PublicLinkAnsweringState {
  const PublicLinkAnsweringStarting();

  @override
  List<Object?> get props => [];
}

/// State while the user is filling in a section.
///
/// Two answer maps are kept side-by-side so we can mirror the web's
/// section-by-section flow precisely:
///
/// - [answers] — answers entered for the *current* section. These get sent
///   to the backend on submit, and only these.
/// - [priorAnswers] — accumulated answers from sections already submitted.
///   The bloc never mutates them after a section is submitted; they exist
///   so that conditional logic on later sections can evaluate against the
///   user's earlier choices, matching the backend's cross-section behavior.
///
/// Use [mergedAnswers] when feeding `SurveyBehaviorManager.calculateBehavior`
/// — never just [answers] on its own, or cross-section rules will fail.
class PublicLinkAnsweringSection extends PublicLinkAnsweringState {
  final int responseId;
  final Section section;

  /// 1-based index of the current section. The server doesn't return total
  /// sections (paged section-by-section), so this only grows monotonically.
  final int sectionNumber;

  final Map<int, dynamic> answers;

  /// Answers from previously submitted sections. Frozen — never modified
  /// once a section is left.
  final Map<int, dynamic> priorAnswers;

  final List<ConditionalLogic> conditionalLogics;
  final Map<int, String> errors;
  final bool submitting;

  const PublicLinkAnsweringSection({
    required this.responseId,
    required this.section,
    required this.answers,
    required this.conditionalLogics,
    required this.errors,
    this.priorAnswers = const {},
    this.sectionNumber = 1,
    this.submitting = false,
  });

  /// Union of [priorAnswers] (immutable) and [answers] (current section,
  /// mutable). Current section answers take precedence on key collisions
  /// — they shouldn't, but we defend anyway.
  Map<int, dynamic> get mergedAnswers => {
        ...priorAnswers,
        ...answers,
      };

  PublicLinkAnsweringSection copyWith({
    int? responseId,
    Section? section,
    int? sectionNumber,
    Map<int, dynamic>? answers,
    Map<int, dynamic>? priorAnswers,
    List<ConditionalLogic>? conditionalLogics,
    Map<int, String>? errors,
    bool? submitting,
  }) {
    return PublicLinkAnsweringSection(
      responseId: responseId ?? this.responseId,
      section: section ?? this.section,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      answers: answers ?? this.answers,
      priorAnswers: priorAnswers ?? this.priorAnswers,
      conditionalLogics: conditionalLogics ?? this.conditionalLogics,
      errors: errors ?? this.errors,
      submitting: submitting ?? this.submitting,
    );
  }

  @override
  List<Object?> get props => [
        responseId,
        section,
        sectionNumber,
        answers,
        priorAnswers,
        conditionalLogics,
        errors,
        submitting,
      ];
}

class PublicLinkAnsweringCompleted extends PublicLinkAnsweringState {
  final String? status;
  final String? rejectionReason;

  const PublicLinkAnsweringCompleted({this.status, this.rejectionReason});

  @override
  List<Object?> get props => [status, rejectionReason];
}

class PublicLinkAnsweringError extends PublicLinkAnsweringState {
  final PublicLinkAnsweringErrorKind kind;
  final String message;

  const PublicLinkAnsweringError({required this.kind, required this.message});

  @override
  List<Object?> get props => [kind, message];
}
