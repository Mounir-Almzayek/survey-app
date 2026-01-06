import 'package:equatable/equatable.dart';

/// Events for Device Location Bloc
abstract class DeviceLocationEvent extends Equatable {
  const DeviceLocationEvent();

  @override
  List<Object?> get props => [];
}

/// Start location tracking
class StartLocationTrackingEvent extends DeviceLocationEvent {
  final int deviceId;
  final int? assignmentId;

  const StartLocationTrackingEvent({
    required this.deviceId,
    this.assignmentId,
  });

  @override
  List<Object?> get props => [deviceId, assignmentId];
}

/// Stop location tracking
class StopLocationTrackingEvent extends DeviceLocationEvent {
  const StopLocationTrackingEvent();
}

/// Update location manually
class UpdateLocationEvent extends DeviceLocationEvent {
  const UpdateLocationEvent();
}

/// Location permission requested
class RequestLocationPermissionEvent extends DeviceLocationEvent {
  const RequestLocationPermissionEvent();
}

