part of 'assignments_list_bloc.dart';

abstract class AssignmentsListState {}

class AssignmentsListInitial extends AssignmentsListState {}

class AssignmentsListLoading extends AssignmentsListState {}

class AssignmentsListLoaded extends AssignmentsListState {
  final ListAssignmentsResponse response;
  AssignmentsListLoaded(this.response);
}

class AssignmentsListError extends AssignmentsListState {
  final String message;
  AssignmentsListError(this.message);
}
