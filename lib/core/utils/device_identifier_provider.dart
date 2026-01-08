import 'package:flutter/foundation.dart';
import '../../core/utils/device_info_util.dart';
import '../services/hardware_keystore_service.dart';

/// Device Identifier Provider
///
/// Provides unique identifiers for the device, prioritizing native platform
/// IDs and falling back to software-generated tokens.
class DeviceIdentifierProvider {
  static final DeviceIdentifierProvider _instance =
      DeviceIdentifierProvider._internal();
  factory DeviceIdentifierProvider() => _instance;
  DeviceIdentifierProvider._internal();

  final HardwareKeystoreService _hardwareService = HardwareKeystoreService();

  /// Gets a unique device identifier
  ///
  /// Priority:
  /// 1. Native platform ID (Android ID / identifierForVendor)
  /// 2. Device info platform ID
  /// 3. Device token (UUID)
  Future<String> getDeviceIdentifier() async {
    try {
      // 1. Try native platform ID
      final nativeId = await _hardwareService.getNativeDeviceId();
      if (nativeId != null && nativeId.isNotEmpty) {
        return nativeId;
      }
    } catch (e) {
      if (kDebugMode) {
        print('DeviceIdentifierProvider: Native ID fetch failed: $e');
      }
    }

    // 2. Fallback to DeviceInfoUtil
    final platformId = await DeviceInfoUtil.getPlatformDeviceId();
    if (platformId != null && platformId.isNotEmpty) {
      return platformId;
    }

    // 3. Last resort: Device token
    return await DeviceInfoUtil.getDeviceToken();
  }
}
