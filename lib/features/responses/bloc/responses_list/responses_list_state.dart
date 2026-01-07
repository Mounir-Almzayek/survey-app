part of 'responses_list_bloc.dart';

abstract class ResponsesListState {}

class ResponsesListInitial extends ResponsesListState {}

class ResponsesListLoading extends ResponsesListState {}

class ResponsesListLoaded extends ResponsesListState {
  final List<ResponseSummary> responses;

  ResponsesListLoaded(this.responses);
}

class ResponsesListError extends ResponsesListState {
  final String message;

  ResponsesListError(this.message);
}


