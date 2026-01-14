import 'package:equatable/equatable.dart';

abstract class HomeStatsEvent extends Equatable {
  const HomeStatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeStats extends HomeStatsEvent {}
