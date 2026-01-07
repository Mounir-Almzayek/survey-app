part of 'survey_details_bloc.dart';

abstract class SurveyDetailsState {}

class SurveyDetailsInitial extends SurveyDetailsState {}

class SurveyDetailsLoading extends SurveyDetailsState {}

class SurveyDetailsLoaded extends SurveyDetailsState {
  final Survey survey;

  SurveyDetailsLoaded(this.survey);
}

class SurveyDetailsError extends SurveyDetailsState {
  final String message;

  SurveyDetailsError(this.message);
}


