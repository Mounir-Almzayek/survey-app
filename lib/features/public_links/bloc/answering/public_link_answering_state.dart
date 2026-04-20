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

class PublicLinkAnsweringSection extends PublicLinkAnsweringState {
  final int responseId;
  final Section section;
  final Map<int, dynamic> answers;
  final List<ConditionalLogic> conditionalLogics;
  final Map<int, String> errors;
  final bool submitting;

  const PublicLinkAnsweringSection({
    required this.responseId,
    required this.section,
    required this.answers,
    required this.conditionalLogics,
    required this.errors,
    this.submitting = false,
  });

  PublicLinkAnsweringSection copyWith({
    int? responseId,
    Section? section,
    Map<int, dynamic>? answers,
    List<ConditionalLogic>? conditionalLogics,
    Map<int, String>? errors,
    bool? submitting,
  }) {
    return PublicLinkAnsweringSection(
      responseId: responseId ?? this.responseId,
      section: section ?? this.section,
      answers: answers ?? this.answers,
      conditionalLogics: conditionalLogics ?? this.conditionalLogics,
      errors: errors ?? this.errors,
      submitting: submitting ?? this.submitting,
    );
  }

  @override
  List<Object?> get props => [
    responseId,
    section,
    answers,
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
