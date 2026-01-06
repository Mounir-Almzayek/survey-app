import 'dart:async';
import 'dart:isolate';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/device_location.dart';

/// Location Service
/// Handles GPS location tracking using isolate for better performance
class LocationService {
  static ReceivePort? _receivePort;
  static Isolate? _isolate;
  static SendPort? _sendPort;
  static final StreamController<DeviceLocation> _locationController =
      StreamController<DeviceLocation>.broadcast();

  /// Stream of location updates
  static Stream<DeviceLocation> get locationStream => _locationController.stream;

  /// Check if location service is running
  static bool get isRunning => _isolate != null && _sendPort != null;

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

    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      _locationIsolate,
      _receivePort!.sendPort,
    );

    _receivePort!.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
      } else if (message is DeviceLocation) {
        _locationController.add(message);
      } else if (message is String && message == 'error') {
        _locationController.addError(Exception('Location tracking error'));
      }
    });
  }

  /// Stop location tracking
  static Future<void> stopLocationTracking() async {
    if (_sendPort != null) {
      _sendPort!.send('stop');
      _sendPort = null;
    }

    if (_isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
    }

    if (_receivePort != null) {
      _receivePort!.close();
      _receivePort = null;
    }
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

  /// Isolate entry point for location tracking
  static void _locationIsolate(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    Timer? timer;
    bool isRunning = true;

    receivePort.listen((message) {
      if (message == 'stop') {
        isRunning = false;
        timer?.cancel();
        receivePort.close();
        return;
      }
    });

    // Start periodic location updates (every 7 seconds)
    timer = Timer.periodic(const Duration(seconds: 7), (timer) async {
      if (!isRunning) {
        timer.cancel();
        return;
      }

      try {
        final hasPermission = await Permission.location.status.isGranted;
        if (!hasPermission) {
          sendPort.send('error');
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

        sendPort.send(location);
      } catch (e) {
        sendPort.send('error');
      }
    });
  }

  /// Dispose resources
  static void dispose() {
    stopLocationTracking();
    _locationController.close();
  }
}

