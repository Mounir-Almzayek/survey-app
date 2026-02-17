import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/device_location.dart';

/// Location Service
/// Handles GPS location tracking using isolate for better performance
class LocationService {
  // We used to use a separate Isolate, but plugins like Geolocator don't work
  // from background isolates. We now use a simple Timer on the main isolate.
  static Timer? _timer;
  static StreamController<DeviceLocation>? _locationController;

  static StreamController<DeviceLocation> get _controller {
    if (_locationController == null || _locationController!.isClosed) {
      _locationController = StreamController<DeviceLocation>.broadcast();
    }
    return _locationController!;
  }

  /// Stream of location updates
  static Stream<DeviceLocation> get locationStream => _controller.stream;

  /// Check if location service is running
  static bool get isRunning => _timer != null;

  /// Request location permissions
  static Future<bool> requestPermissions() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if location permissions are granted
  static Future<bool> hasPermissions() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Start location tracking in isolate
  static Future<void> startLocationTracking() async {
    if (isRunning) {
      return;
    }

    final hasPermission = await hasPermissions();
    if (!hasPermission) {
      final granted = await requestPermissions();
      if (!granted) {
        throw Exception('Location permission denied');
      }
    }

    // Start periodic location updates (every 7 seconds) on main isolate
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) async {
      try {
        // Double-check permission at runtime
        final hasPermission = await hasPermissions();
        if (!hasPermission) {
          _controller.addError(Exception('Location permission denied'));
          await stopLocationTracking();
          return;
        }

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );

        final location = DeviceLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          heading: position.heading,
          speed: position.speed,
          timestamp: position.timestamp,
        );

        if (!_controller.isClosed) {
          _controller.add(location);
        }
      } catch (e) {
        // Report error but keep tracking so next tick can retry (transient GPS/network errors)
        if (!_controller.isClosed) {
          _controller.addError(
            Exception('Location tracking error: ${e.toString()}'),
          );
        }
      }
    });
  }

  /// Stop location tracking
  static Future<void> stopLocationTracking() async {
    _timer?.cancel();
    _timer = null;
  }

  /// Get current location (one-time)
  static Future<DeviceLocation> getCurrentLocation() async {
    final hasPermission = await hasPermissions();
    if (!hasPermission) {
      final granted = await requestPermissions();
      if (!granted) {
        throw Exception('Location permission denied');
      }
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return DeviceLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        heading: position.heading,
        speed: position.speed,
        timestamp: position.timestamp,
      );
    } catch (e) {
      throw Exception('Failed to get current location: ${e.toString()}');
    }
  }

  /// Dispose resources
  static void dispose() {
    stopLocationTracking();
    if (_locationController != null && !_locationController!.isClosed) {
      _locationController!.close();
    }
  }
}
