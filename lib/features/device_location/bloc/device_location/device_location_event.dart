import 'package:equatable/equatable.dart';

/// Events for Device Location Bloc
abstract class DeviceLocationEvent extends Equatable {
  const DeviceLocationEvent();

  @override
  List<Object?> get props => [];
}

/// Start location tracking (no params - bloc resolves deviceId from login method, assignmentId from metadata)
class StartLocationTrackingEvent extends DeviceLocationEvent {
  const StartLocationTrackingEvent();
}

/// Stop location tracking
class StopLocationTrackingEvent extends DeviceLocationEvent {
  const StopLocationTrackingEvent();
}

/// Refresh assignment_id from DeviceLocalMetadataService before each send
class RefreshAssignmentIdEvent extends DeviceLocationEvent {
  const RefreshAssignmentIdEvent();
}

/// Update latitude/longitude in request
class UpdateCoordinatesEvent extends DeviceLocationEvent {
  final double latitude;
  final double longitude;

  const UpdateCoordinatesEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Refresh device_id (no params - bloc resolves from login method: challenge = deviceId, emailOnly = null)
class RefreshDeviceIdEvent extends DeviceLocationEvent {
  const RefreshDeviceIdEvent();
}

/// Send current state.request to API
class SendLocationEvent extends DeviceLocationEvent {
  const SendLocationEvent();
}

/// Location permission requested
class RequestLocationPermissionEvent extends DeviceLocationEvent {
  const RequestLocationPermissionEvent();
}

