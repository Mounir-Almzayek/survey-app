import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/async_runner.dart';
import '../../models/user.dart';
import '../../repository/profile_repository.dart';
import '../../repository/profile_local_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AsyncRunner<User> _profileRunner = AsyncRunner<User>();
  final AsyncRunner<void> _logoutRunner = AsyncRunner<void>();

  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<Logout>(_onLogout);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    await _profileRunner.run(
      onlineTask: (_) async {
        return await ProfileRepository.getProfile();
      },
      offlineTask: (_) async {
        final user = await ProfileLocalRepository.getUser();
        if (user == null) throw Exception('No local user data');
        return user;
      },
      checkConnectivity: true,
      onSuccess: (user) {
        if (!emit.isDone) emit(ProfileLoaded(user, isOffline: false));
      },
      onOffline: (user) {
        if (!emit.isDone) emit(ProfileLoaded(user, isOffline: true));
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
}
