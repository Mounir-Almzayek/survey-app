import 'package:equatable/equatable.dart';

abstract class AssignedSurveysEvent extends Equatable {
  const AssignedSurveysEvent();

  @override
  List<Object> get props => [];
}

class LoadAssignedSurveys extends AssignedSurveysEvent {}

class RefreshAssignedSurveys extends AssignedSurveysEvent {}
