part of 'start_response_bloc.dart';

abstract class StartResponseState {
  final StartResponseRequest? request;

  StartResponseState({this.request});
}

class StartResponseInitial extends StartResponseState {
  StartResponseInitial({super.request});
}

class StartResponseLoading extends StartResponseState {
  StartResponseLoading({super.request});
}

class StartResponseSuccess extends StartResponseState {
  final StartResponseResponse response;
  StartResponseSuccess(this.response, {super.request});
}

class StartResponseError extends StartResponseState {
  final String message;
  StartResponseError(this.message, {super.request});
}
