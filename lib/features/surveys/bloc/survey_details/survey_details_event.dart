part of 'survey_details_bloc.dart';

abstract class SurveyDetailsEvent {}

class LoadSurveyDetails extends SurveyDetailsEvent {
  final int surveyId;
  final bool forceRefresh;

  LoadSurveyDetails({required this.surveyId, this.forceRefresh = false});
}


