import 'package:equatable/equatable.dart';

/// Model representing location update request to server
class LocationUpdateRequest extends Equatable {
  final double latitude;
  final double longitude;
  final int? deviceId;
  final int? assignmentId;

  const LocationUpdateRequest({
    required this.latitude,
    required this.longitude,
    this.deviceId,
    this.assignmentId,
  });

  LocationUpdateRequest copyWith({
    double? latitude,
    double? longitude,
    int? deviceId,
    int? assignmentId,
    bool setDeviceIdToNull = false,
    bool setAssignmentIdToNull = false,
  }) {
    return LocationUpdateRequest(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deviceId: setDeviceIdToNull ? null : (deviceId ?? this.deviceId),
      assignmentId:
          setAssignmentIdToNull ? null : (assignmentId ?? this.assignmentId),
    );
  }

  /// Convert to Map for API request
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
    };
    if (deviceId != null) {
      json['device_id'] = deviceId;
    }
    if (assignmentId != null) {
      json['assignment_id'] = assignmentId;
    }
    return json;
  }

  @override
  List<Object?> get props => [latitude, longitude, deviceId, assignmentId];
}

