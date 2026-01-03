part of 'main_navigation_bloc.dart';

abstract class MainNavigationEvent extends Equatable {
  const MainNavigationEvent();

  @override
  List<Object?> get props => [];
}

class ChangeTab extends MainNavigationEvent {
  final MainNavTab tab;
  const ChangeTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

