part of 'save_section_bloc.dart';

abstract class SaveSectionEvent {}

class UpdateResponseId extends SaveSectionEvent {
  final int? responseId;
  final int? initialSectionId;
  UpdateResponseId(this.responseId, {this.initialSectionId});
}

class UpdateCurrentSection extends SaveSectionEvent {
  final int sectionId;
  UpdateCurrentSection(this.sectionId);
}

class UpdateSaveSectionRequest extends SaveSectionEvent {
  final SaveSectionRequest saveRequest;
  UpdateSaveSectionRequest(this.saveRequest);
}

class UpdateAnswers extends SaveSectionEvent {
  final List<AnswerRequest> answers;
  UpdateAnswers(this.answers);
}

class AddAnswer extends SaveSectionEvent {
  final AnswerRequest answer;
  AddAnswer(this.answer);
}

class UpdateAnswer extends SaveSectionEvent {
  final int questionId;
  final dynamic value;
  UpdateAnswer({required this.questionId, required this.value});
}

class RemoveAnswer extends SaveSectionEvent {
  final int questionId;
  RemoveAnswer(this.questionId);
}

class SubmitSection extends SaveSectionEvent {
  final List<AnswerRequest>? answers;
  SubmitSection({this.answers});
}
