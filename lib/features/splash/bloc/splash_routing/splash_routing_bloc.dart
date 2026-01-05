import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/settings_local_repository.dart';
import '../../../auth/repository/auth_local_repository.dart';

part 'splash_routing_event.dart';
part 'splash_routing_state.dart';

class SplashRoutingBloc extends Bloc<SplashRoutingEvent, SplashRoutingState> {
  SplashRoutingBloc() : super(const SplashInitial()) {
    on<SplashCheckStatus>(_checkStatus);
  }

  Future<void> _checkStatus(
    SplashRoutingEvent event,
    Emitter<SplashRoutingState> emit,
  ) async {
    emit(const SplashLoading());

    final isFirstTime = SettingsLocalRepository.isAppOpenedForFirstTime();
    final token = await AuthLocalRepository.retrieveToken();

    SplashDestination dest = SplashDestination.appReady;
    if (isFirstTime) {
      dest = SplashDestination.welcome;
      SettingsLocalRepository.markAppAsOpened();
    } else if (token.isEmpty) {
      dest = SplashDestination.unregistered;
    } else {
      dest = SplashDestination.appReady;
    }

    emit(SplashLoaded(destination: dest));
  }
}
