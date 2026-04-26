import 'package:equatable/equatable.dart';

sealed class PublicLinkAnsweringEvent extends Equatable {
  const PublicLinkAnsweringEvent();
}

/// Kick off the survey by calling /start. The body carries only an
/// optional location now — quota matching happens server-side at
/// FINAL_SUBMIT.
class StartAnswering extends PublicLinkAnsweringEvent {
  final ({double latitude, double longitude})? location;

  const StartAnswering({this.location});

  @override
  List<Object?> get props => [location];
}

/// User typed / selected an answer for a question.
class AnswerChanged extends PublicLinkAnsweringEvent {
  final int questionId;
  final dynamic value;

  const AnswerChanged({required this.questionId, required this.value});

  @override
  List<Object?> get props => [questionId, value];
}

/// User pressed "Continue" / "Submit" on the current section.
class SubmitCurrentSection extends PublicLinkAnsweringEvent {
  const SubmitCurrentSection();

  @override
  List<Object?> get props => [];
}

/// Retry after an error – replays the last attempted action.
class Retry extends PublicLinkAnsweringEvent {
  const Retry();

  @override
  List<Object?> get props => [];
}
