part of 'assignments_list_bloc.dart';

abstract class AssignmentsListEvent {}

class LoadAssignments extends AssignmentsListEvent {}

class ClearAssignmentsList extends AssignmentsListEvent {}

class SearchAssignments extends AssignmentsListEvent {
  final String query;
  SearchAssignments(this.query);
}

class LoadSearchHistory extends AssignmentsListEvent {}

class ClearSearchHistory extends AssignmentsListEvent {}

class AddToHistory extends AssignmentsListEvent {
  final String query;
  AddToHistory(this.query);
}
