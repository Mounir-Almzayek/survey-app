part of 'survey_details_bloc.dart';

abstract class SurveyDetailsEvent {}

class UpdateSurveyIdForDetails extends SurveyDetailsEvent {
  final int surveyId;
  UpdateSurveyIdForDetails(this.surveyId);
}

class LoadSurveyDetails extends SurveyDetailsEvent {}
