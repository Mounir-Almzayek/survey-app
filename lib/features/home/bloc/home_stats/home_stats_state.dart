import 'package:equatable/equatable.dart';
import '../../models/survey_stats_model.dart';

abstract class HomeStatsState extends Equatable {
  const HomeStatsState();

  @override
  List<Object?> get props => [];
}

class HomeStatsInitial extends HomeStatsState {}

class HomeStatsLoading extends HomeStatsState {}

class HomeStatsLoaded extends HomeStatsState {
  final SurveyStatsModel stats;

  const HomeStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class HomeStatsError extends HomeStatsState {
  final String message;

  const HomeStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
