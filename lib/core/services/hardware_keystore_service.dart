import 'package:flutter/services.dart';

/// Hardware Keystore Service
///
/// Handles raw interactions with the native hardware security modules
/// (Android Keystore / iOS Secure Enclave) via MethodChannel.
class HardwareKeystoreService {
  static final HardwareKeystoreService _instance =
      HardwareKeystoreService._internal();
  factory HardwareKeystoreService() => _instance;
  HardwareKeystoreService._internal();

  static const MethodChannel _channel = MethodChannel(
    'com.rs4it.king_abdulaziz_center_survey_app/hardware_keystore',
  );

  // Response keys
  static const String publicKeyKey = 'publicKey';
  static const String signatureKey = 'signature';
  static const String certificateChainKey = 'certificateChain';

  /// Invoke a method on the hardware keystore platform channel
  Future<T?> invokeMethod<T>(
    String method, [
    Map<String, dynamic>? arguments,
  ]) async {
    if (arguments != null) {
      return await _channel.invokeMethod<T>(method, arguments);
    } else {
      return await _channel.invokeMethod<T>(method);
    }
  }

  /// Generate a new key pair in hardware
  Future<Map<Object?, Object?>?> generateKeyPair(String challenge) async {
    return await invokeMethod<Map<Object?, Object?>>('generateKeyPair', {
      'challenge': challenge,
    });
  }

  /// Get public key from hardware
  Future<String?> getPublicKey() async {
    return await invokeMethod<String>('getPublicKey');
  }

  /// Get key ID from hardware storage
  Future<String?> getKeyId() async {
    return await invokeMethod<String>('getKeyId');
  }

  /// Save key ID to hardware storage
  Future<void> saveKeyId(String keyId) async {
    await invokeMethod('saveKeyId', {'keyId': keyId});
  }

  /// Delete key ID from hardware storage
  Future<void> deleteKeyId() async {
    await invokeMethod('deleteKeyId');
  }

  /// Delete device-bound key from hardware
  Future<void> deleteKey() async {
    await invokeMethod('deleteKey');
  }

  /// Check if key exists in hardware
  Future<bool> hasKey() async {
    final result = await invokeMethod<bool>('hasKey');
    return result ?? false;
  }

  /// Sign payload using hardware key
  Future<String?> signPayload(String payload) async {
    return await invokeMethod<String>('signPayload', {'payload': payload});
  }

  /// Get native device ID (can be backend-assigned ID or fallback to hardware ID)
  Future<String?> getNativeDeviceId() async {
    return await invokeMethod<String>('getDeviceId');
  }

  /// Get permanent hardware ID (Android ID / identifierForVendor)
  Future<String?> getHardwareId() async {
    return await invokeMethod<String>('getHardwareId');
  }

  /// Delete native device ID
  Future<void> deleteNativeDeviceId() async {
    await invokeMethod('deleteDeviceId');
  }

  /// Save assignment ID to hardware storage
  Future<void> saveAssignmentId(int assignmentId) async {
    await invokeMethod('saveAssignmentId', {'assignmentId': assignmentId});
  }

  /// Get assignment ID from hardware storage
  Future<String?> getAssignmentId() async {
    return await invokeMethod<String>('getAssignmentId');
  }

  /// Delete assignment ID from hardware storage
  Future<void> deleteAssignmentId() async {
    await invokeMethod('deleteAssignmentId');
  }

  /// Save device ID (physical device ID from backend) to hardware storage
  Future<void> saveDeviceId(int deviceId) async {
    await invokeMethod('saveDeviceId', {'deviceId': deviceId});
  }

  /// Get device ID (physical device ID from backend) from hardware storage
  Future<String?> getDeviceId() async {
    return await invokeMethod<String>('getDeviceId');
  }

  /// Delete device ID from hardware storage
  Future<void> deleteDeviceId() async {
    await invokeMethod('deleteDeviceId');
  }
}
