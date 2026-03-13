part of 'assignments_list_bloc.dart';

abstract class AssignmentsListEvent {}

class LoadAssignments extends AssignmentsListEvent {}

/// Clears in-memory state (e.g. on logout) so the next account does not see old data.
class ClearAssignmentsList extends AssignmentsListEvent {}
