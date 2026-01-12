part of 'survey_details_bloc.dart';

abstract class SurveyDetailsState {
  final int? surveyId;

  SurveyDetailsState({this.surveyId});
}

class SurveyDetailsInitial extends SurveyDetailsState {
  SurveyDetailsInitial({super.surveyId});
}

class SurveyDetailsLoading extends SurveyDetailsState {
  SurveyDetailsLoading({super.surveyId});
}

class SurveyDetailsLoaded extends SurveyDetailsState {
  final GetSurveyAssignmentResponse response;
  SurveyDetailsLoaded(this.response, {super.surveyId});
}

class SurveyDetailsError extends SurveyDetailsState {
  final String message;
  SurveyDetailsError(this.message, {super.surveyId});
}
