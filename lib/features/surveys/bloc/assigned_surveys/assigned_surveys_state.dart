import 'package:equatable/equatable.dart';
import '../../models/survey.dart';

abstract class AssignedSurveysState extends Equatable {
  const AssignedSurveysState();

  @override
  List<Object> get props => [];
}

class AssignedSurveysInitial extends AssignedSurveysState {}

class AssignedSurveysLoading extends AssignedSurveysState {}

class AssignedSurveysLoaded extends AssignedSurveysState {
  final List<Survey> surveys;

  const AssignedSurveysLoaded(this.surveys);

  @override
  List<Object> get props => [surveys];
}

class AssignedSurveysError extends AssignedSurveysState {
  final String message;

  const AssignedSurveysError(this.message);

  @override
  List<Object> get props => [message];
}
