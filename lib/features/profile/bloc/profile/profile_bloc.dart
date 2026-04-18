import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/async_runner.dart';
import '../../models/researcher_profile_response_model.dart';
import '../../repository/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AsyncRunner<ResearcherProfileResponseModel> _profileRunner =
      AsyncRunner<ResearcherProfileResponseModel>();
  final AsyncRunner<void> _logoutRunner = AsyncRunner<void>();

  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<Logout>(_onLogout);
    on<SessionInvalidatedByServer>(_onSessionInvalidatedByServer);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    await _profileRunner.run(
      onlineTask: (_) async {
        return await ProfileRepository.getProfile(forceOnline: true);
      },
      offlineTask: (_) async {
        final user = await ProfileRepository.getProfile();
        return user;
      },
      checkConnectivity: true,
      onSuccess: (profile) {
        if (!emit.isDone) emit(ProfileLoaded(profile, isOffline: false));
      },
      onOffline: (profile) {
        if (!emit.isDone) emit(ProfileLoaded(profile, isOffline: true));
      },
      onError: (error) {
        if (!emit.isDone) emit(ProfileError(error.toString()));
      },
    );
  }

  Future<void> _onLogout(Logout event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    await _logoutRunner.run(
      onlineTask: (_) async => await ProfileRepository.logout(),
      offlineTask: (_) async => await ProfileRepository.logout(),
      checkConnectivity: false,
      onSuccess: (_) {
        if (!emit.isDone) emit(ProfileLogoutSuccess());
      },
      onError: (error) {
        if (!emit.isDone) emit(ProfileError(error.toString()));
      },
    );
  }

  void _onSessionInvalidatedByServer(
    SessionInvalidatedByServer event,
    Emitter<ProfileState> emit,
  ) {
    emit(ProfileLogoutSuccess());
  }
}
