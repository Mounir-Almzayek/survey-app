part of 'assigned_surveys_bloc.dart';

abstract class AssignedSurveysEvent {}

class LoadAssignedSurveys extends AssignedSurveysEvent {
  final bool forceRefresh;

  LoadAssignedSurveys({this.forceRefresh = false});
}


