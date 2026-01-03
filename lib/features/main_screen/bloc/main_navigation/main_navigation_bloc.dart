import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/main_nav_tab.dart';

part 'main_navigation_event.dart';
part 'main_navigation_state.dart';

class MainNavigationBloc extends Bloc<MainNavigationEvent, MainNavigationState> {
  MainNavigationBloc() : super(const MainNavigationState(MainNavTab.home)) {
    on<ChangeTab>((event, emit) {
      emit(MainNavigationState(event.tab));
    });
  }
}

