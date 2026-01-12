import 'package:equatable/equatable.dart';

/// Simple model for location data (latitude/longitude)
class LocationData extends Equatable {
  final double latitude;
  final double longitude;

  const LocationData({required this.latitude, required this.longitude});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  @override
  List<Object?> get props => [latitude, longitude];
}
