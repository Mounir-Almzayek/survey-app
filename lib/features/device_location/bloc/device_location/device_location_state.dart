import 'package:equatable/equatable.dart';
import '../../models/device_location.dart';

/// States for Device Location Bloc
abstract class DeviceLocationState extends Equatable {
  const DeviceLocationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DeviceLocationInitial extends DeviceLocationState {
  const DeviceLocationInitial();
}

/// Loading state
class DeviceLocationLoading extends DeviceLocationState {
  const DeviceLocationLoading();
}

/// Location tracking started
class DeviceLocationTrackingStarted extends DeviceLocationState {
  const DeviceLocationTrackingStarted();
}

/// Location tracking stopped
class DeviceLocationTrackingStopped extends DeviceLocationState {
  const DeviceLocationTrackingStopped();
}

/// Location updated
class DeviceLocationUpdated extends DeviceLocationState {
  final DeviceLocation location;

  const DeviceLocationUpdated(this.location);

  @override
  List<Object?> get props => [location];
}

/// Location update failed
class DeviceLocationUpdateFailed extends DeviceLocationState {
  final String error;

  const DeviceLocationUpdateFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// Permission denied
class DeviceLocationPermissionDenied extends DeviceLocationState {
  const DeviceLocationPermissionDenied();
}

/// Error state
class DeviceLocationError extends DeviceLocationState {
  final String message;

  const DeviceLocationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Warning or outside zone - logout required
class DeviceLocationWarningLogout extends DeviceLocationState {
  final String message;

  const DeviceLocationWarningLogout(this.message);

  @override
  List<Object?> get props => [message];
}

