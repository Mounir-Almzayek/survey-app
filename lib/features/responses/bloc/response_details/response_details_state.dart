part of 'response_details_bloc.dart';

abstract class ResponseDetailsState {}

class ResponseDetailsInitial extends ResponseDetailsState {}

class ResponseDetailsLoading extends ResponseDetailsState {}

class ResponseDetailsLoaded extends ResponseDetailsState {
  final ResponseDetails details;

  ResponseDetailsLoaded(this.details);
}

class ResponseDetailsError extends ResponseDetailsState {
  final String message;

  ResponseDetailsError(this.message);
}


