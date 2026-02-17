import 'package:equatable/equatable.dart';
import '../../models/device_location.dart';
import '../../models/location_update_request.dart';

/// States for Device Location Bloc
abstract class DeviceLocationState extends Equatable {
  const DeviceLocationState({this.request});

  final LocationUpdateRequest? request;

  @override
  List<Object?> get props => [request];
}

/// Initial state
class DeviceLocationInitial extends DeviceLocationState {
  const DeviceLocationInitial({super.request});
}

/// Tracking not started yet; waiting for context (assignment_id or device_id)
class DeviceLocationWaitingForContext extends DeviceLocationState {
  const DeviceLocationWaitingForContext();
}

/// Loading state
class DeviceLocationLoading extends DeviceLocationState {
  const DeviceLocationLoading({super.request});
}

/// Location tracking started
class DeviceLocationTrackingStarted extends DeviceLocationState {
  const DeviceLocationTrackingStarted({required LocationUpdateRequest request})
      : super(request: request);

  DeviceLocationTrackingStarted copyWith({LocationUpdateRequest? request}) {
    return DeviceLocationTrackingStarted(
      request: request ?? this.request!,
    );
  }

  @override
  List<Object?> get props => [request];
}

/// Location tracking stopped
class DeviceLocationTrackingStopped extends DeviceLocationState {
  const DeviceLocationTrackingStopped();
}

/// Location updated
class DeviceLocationUpdated extends DeviceLocationState {
  final DeviceLocation location;

  const DeviceLocationUpdated(this.location, {super.request});

  @override
  List<Object?> get props => [location, request];
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

