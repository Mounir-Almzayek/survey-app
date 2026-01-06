import 'package:equatable/equatable.dart';

/// Model representing device location
class DeviceLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? heading;
  final double? speed;
  final DateTime timestamp;

  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.heading,
    this.speed,
    required this.timestamp,
  });

  /// Create DeviceLocation from Map
  factory DeviceLocation.fromMap(Map<String, dynamic> map) {
    return DeviceLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      accuracy: map['accuracy'] != null ? (map['accuracy'] as num).toDouble() : null,
      altitude: map['altitude'] != null ? (map['altitude'] as num).toDouble() : null,
      heading: map['heading'] != null ? (map['heading'] as num).toDouble() : null,
      speed: map['speed'] != null ? (map['speed'] as num).toDouble() : null,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'heading': heading,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'heading': heading,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        accuracy,
        altitude,
        heading,
        speed,
        timestamp,
      ];
}

