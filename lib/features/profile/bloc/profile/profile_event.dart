part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class Logout extends ProfileEvent {
  const Logout();
}

/// Token was rejected by the API; local data is already cleared.
class SessionInvalidatedByServer extends ProfileEvent {
  const SessionInvalidatedByServer();
}
