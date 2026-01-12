part of 'start_response_bloc.dart';

abstract class StartResponseState {
  final int? surveyId;

  StartResponseState({this.surveyId});
}

class StartResponseInitial extends StartResponseState {
  StartResponseInitial({super.surveyId});
}

class StartResponseLoading extends StartResponseState {
  StartResponseLoading({super.surveyId});
}

class StartResponseSuccess extends StartResponseState {
  final StartResponseResponse response;
  StartResponseSuccess(this.response, {super.surveyId});
}

class StartResponseError extends StartResponseState {
  final String message;
  StartResponseError(this.message, {super.surveyId});
}
