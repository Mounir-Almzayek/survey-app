import '../services/storage_service.dart';
import '../services/hardware_keystore_service.dart';

/// Device Local Metadata Service
///
/// Manages persistent storage for device-related metadata like physical device IDs,
/// assignment IDs, and other local settings.
class DeviceLocalMetadataService {
  static final DeviceLocalMetadataService _instance =
      DeviceLocalMetadataService._internal();
  factory DeviceLocalMetadataService() => _instance;
  DeviceLocalMetadataService._internal();

  final HardwareKeystoreService _hardwareService = HardwareKeystoreService();

  static const String _physicalDeviceIdKey = 'physical_device_id';
  static const String _assignmentIdKey = 'assignment_id';

  /// Save physical device ID (from backend)
  Future<void> savePhysicalDeviceId(int id) async {
    // 1. Save to standard storage
    await StorageService.setString(_physicalDeviceIdKey, id.toString());

    // 2. Sync to deep hardware storage (survives uninstall)
    try {
      await _hardwareService.saveDeviceId(id);
    } catch (_) {
      // Ignore errors, standard storage is primary
    }
  }

  /// Get physical device ID
  Future<int?> getPhysicalDeviceId() async {
    // 1. Try standard storage first
    final value = StorageService.getString(_physicalDeviceIdKey);
    if (value != null && value.isNotEmpty) {
      return int.tryParse(value);
    }

    // 2. Deep recovery from hardware storage
    try {
      final nativeValue = await _hardwareService.getDeviceId();
      if (nativeValue != null && nativeValue.isNotEmpty) {
        final id = int.tryParse(nativeValue);
        if (id != null) {
          // Recover to standard storage
          await StorageService.setString(_physicalDeviceIdKey, id.toString());
          return id;
        }
      }
    } catch (_) {}

    return null;
  }

  /// Save assignment ID
  Future<void> saveAssignmentId(int? id) async {
    if (id == null) {
      await StorageService.remove(_assignmentIdKey);
      try {
        await _hardwareService.deleteAssignmentId();
      } catch (_) {}
    } else {
      await StorageService.setString(_assignmentIdKey, id.toString());
      try {
        await _hardwareService.saveAssignmentId(id);
      } catch (_) {}
    }
  }

  /// Get assignment ID
  Future<int?> getAssignmentId() async {
    // 1. Try standard storage
    final value = StorageService.getString(_assignmentIdKey);
    if (value != null && value.isNotEmpty) {
      return int.tryParse(value);
    }

    // 2. Deep recovery
    try {
      final nativeValue = await _hardwareService.getAssignmentId();
      if (nativeValue != null && nativeValue.isNotEmpty) {
        final id = int.tryParse(nativeValue);
        if (id != null) {
          await StorageService.setString(_assignmentIdKey, id.toString());
          return id;
        }
      }
    } catch (_) {}

    return null;
  }

  /// Remove physical device ID
  Future<void> removePhysicalDeviceId() async {
    await StorageService.remove(_physicalDeviceIdKey);
    try {
      await _hardwareService.deleteDeviceId();
    } catch (_) {}
  }

  /// Clear all metadata
  Future<void> clearAll() async {
    await StorageService.remove(_physicalDeviceIdKey);
    await StorageService.remove(_assignmentIdKey);
    try {
      await _hardwareService.deleteDeviceId();
      await _hardwareService.deleteAssignmentId();
    } catch (_) {}
  }
}
