import 'package:equatable/equatable.dart';
import '../../models/save_section_answers_request.dart';

/// Events for Save Section Answers Bloc
abstract class SaveSectionAnswersEvent extends Equatable {
  const SaveSectionAnswersEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the section context and load local progress if exists
class InitializeSection extends SaveSectionAnswersEvent {
  final String shortCode;
  final int responseId;
  final int sectionId;

  const InitializeSection({
    required this.shortCode,
    required this.responseId,
    required this.sectionId,
  });

  @override
  List<Object?> get props => [shortCode, responseId, sectionId];
}

/// Update current answers in the state before saving
class UpdateAnswers extends SaveSectionAnswersEvent {
  final SaveSectionAnswersRequest request;

  const UpdateAnswers(this.request);

  @override
  List<Object?> get props => [request];
}

/// Save section answers using current context from state
class SaveSectionAnswers extends SaveSectionAnswersEvent {
  const SaveSectionAnswers();
}
