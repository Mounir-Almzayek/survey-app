import '../../../../core/models/survey/survey_model.dart';

abstract class SurveyNavigationEvent {}

class SetSurvey extends SurveyNavigationEvent {
  final Survey survey;
  SetSurvey(this.survey);
}

class NextSection extends SurveyNavigationEvent {}

class PreviousSection extends SurveyNavigationEvent {}

class GoToSection extends SurveyNavigationEvent {
  final int index;
  GoToSection(this.index);
}
