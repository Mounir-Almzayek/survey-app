import '../../../core/services/hive_service.dart';
import '../models/device_location.dart';

/// Repository for storing device location locally
class DeviceLocationLocalRepository {
  static const String _lastLocationKey = 'last_device_location';
  static const String _pendingLocationsKey = 'pending_device_locations';

  /// Save last known location
  static Future<void> saveLastLocation(DeviceLocation location) async {
    await HiveService.saveData(_lastLocationKey, location.toJson());
  }

  /// Get last known location
  static Future<DeviceLocation?> getLastLocation() async {
    try {
      final data = await HiveService.getData(_lastLocationKey) as Map<String, dynamic>?;
      if (data == null) return null;
      return DeviceLocation.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  /// Save pending location (for offline support)
  static Future<void> savePendingLocation(DeviceLocation location) async {
    final pending = await getPendingLocations();
    pending.add(location);
    await HiveService.saveData(_pendingLocationsKey, pending.map((l) => l.toJson()).toList());
  }

  /// Get pending locations
  static Future<List<DeviceLocation>> getPendingLocations() async {
    try {
      final data = await HiveService.getData(_pendingLocationsKey) as List<dynamic>?;
      if (data == null) return [];
      return data.map((item) => DeviceLocation.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear pending locations
  static Future<void> clearPendingLocations() async {
    await HiveService.deleteData(_pendingLocationsKey);
  }

  /// Remove specific pending location
  static Future<void> removePendingLocation(DeviceLocation location) async {
    final pending = await getPendingLocations();
    pending.removeWhere((l) => l.timestamp == location.timestamp);
    await HiveService.saveData(_pendingLocationsKey, pending.map((l) => l.toJson()).toList());
  }
}

