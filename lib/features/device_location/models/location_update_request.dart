import 'package:equatable/equatable.dart';

/// Model representing location update request to server
class LocationUpdateRequest extends Equatable {
  final double latitude;
  final double longitude;
  final int? assignmentId;

  const LocationUpdateRequest({
    required this.latitude,
    required this.longitude,
    this.assignmentId,
  });

  /// Convert to Map for API request
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
    };
    if (assignmentId != null) {
      json['assignment_id'] = assignmentId;
    }
    return json;
  }

  @override
  List<Object?> get props => [latitude, longitude, assignmentId];
}

