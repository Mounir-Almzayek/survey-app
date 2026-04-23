part of 'assignments_list_bloc.dart';

abstract class AssignmentsListState {}

class AssignmentsListInitial extends AssignmentsListState {}

class AssignmentsListLoading extends AssignmentsListState {}

class AssignmentsListLoaded extends AssignmentsListState {
  final ListAssignmentsResponse response;
  final List<Survey> filteredSurveys;
  final String searchQuery;
  final List<String> recentSearches;

  AssignmentsListLoaded(
    this.response, {
    List<Survey>? filteredSurveys,
    this.searchQuery = '',
    this.recentSearches = const [],
  }) : filteredSurveys = filteredSurveys ?? response.surveys;

  AssignmentsListLoaded copyWith({
    ListAssignmentsResponse? response,
    List<Survey>? filteredSurveys,
    String? searchQuery,
    List<String>? recentSearches,
  }) {
    return AssignmentsListLoaded(
      response ?? this.response,
      filteredSurveys: filteredSurveys ?? this.filteredSurveys,
      searchQuery: searchQuery ?? this.searchQuery,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}

class AssignmentsListError extends AssignmentsListState {
  final String message;
  AssignmentsListError(this.message);
}
