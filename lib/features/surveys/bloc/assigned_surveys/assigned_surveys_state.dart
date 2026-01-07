part of 'assigned_surveys_bloc.dart';

abstract class AssignedSurveysState {}

class AssignedSurveysInitial extends AssignedSurveysState {}

class AssignedSurveysLoading extends AssignedSurveysState {}

class AssignedSurveysLoaded extends AssignedSurveysState {
  final List<Assignment> assignments;

  AssignedSurveysLoaded(this.assignments);
}

class AssignedSurveysError extends AssignedSurveysState {
  final String message;

  AssignedSurveysError(this.message);
}


