import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../features/auth/repository/auth_local_repository.dart';
import '../../../../features/profile/repository/profile_repository.dart';
import '../models/device_location.dart';
import '../models/location_update_request.dart';
import '../repository/device_location_online_repository.dart';
import '../repository/device_location_local_repository.dart';
import 'location_service.dart';

/// Background Location Service
/// Handles periodic location updates every 7 seconds
/// Automatically logs out if warning or outside zone
class BackgroundLocationService {
  static BackgroundLocationService? _instance;
  factory BackgroundLocationService() => _instance ??= BackgroundLocationService._internal();
  BackgroundLocationService._internal();

  StreamSubscription<DeviceLocation>? _locationSubscription;
  Timer? _updateTimer;
  bool _isRunning = false;
  int? _deviceId;
  int? _assignmentId;

  /// Start background location tracking
  /// 
  /// Parameters:
  /// - [deviceId]: The device ID to update location for
  /// - [assignmentId]: Optional assignment ID
  Future<void> start({
    required int deviceId,
    int? assignmentId,
  }) async {
    if (_isRunning) {
      return;
    }

    _deviceId = deviceId;
    _assignmentId = assignmentId;
    _isRunning = true;

    // Start location service
    await LocationService.startLocationTracking();

    // Listen to location updates
    _locationSubscription = LocationService.locationStream.listen(
      _handleLocationUpdate,
      onError: (error) {
        if (kDebugMode) {
          print('Location tracking error: $error');
        }
      },
    );
  }

  /// Stop background location tracking
  Future<void> stop() async {
    if (!_isRunning) {
      return;
    }

    _isRunning = false;
    _updateTimer?.cancel();
    _updateTimer = null;
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    await LocationService.stopLocationTracking();
  }

  /// Handle location update
  Future<void> _handleLocationUpdate(DeviceLocation location) async {
    if (!_isRunning || _deviceId == null) {
      return;
    }

    // Check if token exists
    final token = await AuthLocalRepository.retrieveToken();
    if (token.isEmpty) {
      // No token, don't send request
      if (kDebugMode) {
        print('No token available, skipping location update');
      }
      return;
    }

    // Save location locally
    await DeviceLocationLocalRepository.saveLastLocation(location);

    try {
      // Update location on server
      await DeviceLocationOnlineRepository.updateDeviceLocation(
        deviceId: _deviceId!,
        request: location.toUpdateRequest(assignmentId: _assignmentId),
      );

      // Remove from pending if it was there
      await DeviceLocationLocalRepository.removePendingLocation(location);
    } catch (e) {
      // Save to pending for retry later
      await DeviceLocationLocalRepository.savePendingLocation(location);

      // Check if error indicates warning or outside zone
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('warning') ||
          errorMessage.contains('outside') ||
          errorMessage.contains('zone') ||
          errorMessage.contains('unauthorized') ||
          errorMessage.contains('forbidden')) {
        // Logout immediately
        if (kDebugMode) {
          print('Warning or outside zone detected, logging out...');
        }
        await _forceLogout();
      }
    }
  }

  /// Force logout
  Future<void> _forceLogout() async {
    try {
      await stop();
      await ProfileRepository.logout();
    } catch (e) {
      if (kDebugMode) {
        print('Error during force logout: $e');
      }
    }
  }

  /// Get device ID
  int? get deviceId => _deviceId;

  /// Check if service is running
  bool get isRunning => _isRunning;
}

/// Extension to convert DeviceLocation to LocationUpdateRequest
extension DeviceLocationExtension on DeviceLocation {
  LocationUpdateRequest toUpdateRequest({int? assignmentId}) {
    return LocationUpdateRequest(
      latitude: latitude,
      longitude: longitude,
      assignmentId: assignmentId,
    );
  }
}

