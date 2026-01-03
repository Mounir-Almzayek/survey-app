part of 'main_navigation_bloc.dart';

class MainNavigationState extends Equatable {
  final MainNavTab currentTab;
  const MainNavigationState(this.currentTab);

  @override
  List<Object?> get props => [currentTab];
}

