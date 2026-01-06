import '../services/storage_service.dart';

/// Service for storing device-related data
class DeviceStorageService {
  static const String _deviceIdKey = 'device_id';
  static const String _assignmentIdKey = 'assignment_id';

  /// Save device ID
  static Future<void> saveDeviceId(int deviceId) async {
    await StorageService.setString(_deviceIdKey, deviceId.toString());
  }

  /// Get device ID
  static Future<int?> getDeviceId() async {
    final deviceIdStr = StorageService.getString(_deviceIdKey);
    if (deviceIdStr == null || deviceIdStr.isEmpty) {
      return null;
    }
    return int.tryParse(deviceIdStr);
  }

  /// Save assignment ID
  static Future<void> saveAssignmentId(int? assignmentId) async {
    if (assignmentId == null) {
      await StorageService.remove(_assignmentIdKey);
    } else {
      await StorageService.setString(_assignmentIdKey, assignmentId.toString());
    }
  }

  /// Get assignment ID
  static Future<int?> getAssignmentId() async {
    final assignmentIdStr = StorageService.getString(_assignmentIdKey);
    if (assignmentIdStr == null || assignmentIdStr.isEmpty) {
      return null;
    }
    return int.tryParse(assignmentIdStr);
  }

  /// Clear device data
  static Future<void> clearDeviceData() async {
    await StorageService.remove(_deviceIdKey);
    await StorageService.remove(_assignmentIdKey);
  }
}
