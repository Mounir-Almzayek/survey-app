part of 'start_response_bloc.dart';

abstract class StartResponseEvent {}

class UpdateSurveyId extends StartResponseEvent {
  final int surveyId;
  UpdateSurveyId(this.surveyId);
}

class StartSurveyResponse extends StartResponseEvent {}
