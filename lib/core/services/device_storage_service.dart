import 'package:flutter/services.dart';
import '../services/storage_service.dart';

/// Service for storing device-related data
///
/// Device ID is stored in hardware-backed secure storage:
/// - Android: EncryptedSharedPreferences with Android Keystore
/// - iOS: Keychain (protected by Secure Enclave on supported devices)
class DeviceStorageService {
  static const MethodChannel _channel = MethodChannel(
    'com.rs4it.king_abdulaziz_center_survey_app/hardware_keystore',
  );

  static const String _assignmentIdKey = 'assignment_id';

  /// Save device ID to hardware-backed secure storage
  ///
  /// Uses Android Keystore (EncryptedSharedPreferences) on Android
  /// Uses iOS Keychain on iOS
  static Future<void> saveDeviceId(int deviceId) async {
    try {
      await _channel.invokeMethod('saveDeviceId', {'deviceId': deviceId});
    } catch (e) {
      throw Exception('Failed to save device ID to hardware storage: $e');
    }
  }

  /// Get device ID from hardware-backed secure storage
  ///
  /// Returns null if device ID is not found
  static Future<int?> getDeviceId() async {
    try {
      final deviceIdStr = await _channel.invokeMethod<String>('getDeviceId');
      if (deviceIdStr == null || deviceIdStr.isEmpty) {
        return null;
      }
      return int.tryParse(deviceIdStr);
    } catch (e) {
      // Return null if error occurs (device ID not found)
      return null;
    }
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
  ///
  /// Deletes device ID from hardware storage and assignment ID from software storage
  static Future<void> clearDeviceData() async {
    try {
      // Delete device ID from hardware storage
      await _channel.invokeMethod('deleteDeviceId');
    } catch (e) {
      // Ignore errors when deleting device ID
    }
    // Delete assignment ID from software storage (not sensitive)
    await StorageService.remove(_assignmentIdKey);
  }
}
