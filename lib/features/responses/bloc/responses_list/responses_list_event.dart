part of 'responses_list_bloc.dart';

abstract class ResponsesListEvent {}

class LoadResponsesForSurvey extends ResponsesListEvent {
  final int surveyId;
  final bool forceRefresh;

  LoadResponsesForSurvey({
    required this.surveyId,
    this.forceRefresh = false,
  });
}


