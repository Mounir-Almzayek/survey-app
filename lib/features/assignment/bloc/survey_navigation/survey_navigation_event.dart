import '../../../../core/models/survey/survey_model.dart';

abstract class SurveyNavigationEvent {}

class SetSurvey extends SurveyNavigationEvent {
  final Survey survey;
  final int? responseId;
  SetSurvey(this.survey, this.responseId);
}

class UpdateResponseId extends SurveyNavigationEvent {
  final int? responseId;
  UpdateResponseId(this.responseId);
}

class ResumeFromSection extends SurveyNavigationEvent {
  final int sectionId;
  ResumeFromSection(this.sectionId);
}

class RefreshBehavior extends SurveyNavigationEvent {
  final Map<int, dynamic> answers;
  RefreshBehavior(this.answers);
}

class NextSection extends SurveyNavigationEvent {}

class PreviousSection extends SurveyNavigationEvent {}

class GoToSection extends SurveyNavigationEvent {
  final int index;
  GoToSection(this.index);
}

class StartSurvey extends SurveyNavigationEvent {}

class CompleteSurvey extends SurveyNavigationEvent {}
