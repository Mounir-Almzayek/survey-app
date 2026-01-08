import 'package:flutter/services.dart';
import 'device_local_metadata_service.dart';

/// Device-Bound Key Service (Facade)
///
/// Implementation based on IMPLEMENTATION_PLAN_DEVICE_BINDING.md
/// Orchestrates device-bound cryptographic operations via native hardware (Secure Enclave / StrongBox)
class DeviceBoundKeyService {
  // Singleton pattern
  static final DeviceBoundKeyService _instance =
      DeviceBoundKeyService._internal();
  factory DeviceBoundKeyService() => _instance;
  DeviceBoundKeyService._internal();

  static const MethodChannel _channel = MethodChannel(
    'com.rs4it.king_abdulaziz_center_survey_app/hardware_keystore',
  );
  final DeviceLocalMetadataService _metadata = DeviceLocalMetadataService();

  // ============================================================================
  // Key Generation (Section 1.1 of Plan)
  // ============================================================================

  /// Generates a new device-bound key pair in hardware security module
  Future<Map<String, dynamic>> generateKeyPair(String challenge) async {
    final Map? result = await _channel.invokeMethod('generateKeyPair', {
      'challenge': challenge,
    });

    if (result == null) {
      throw Exception('Failed to generate key pair in hardware');
    }

    return {
      'publicKey': result['publicKey'],
      'keyId': result['keyId'],
      'signature': result['signature'], // Proof of Possession
      'attestation': {
        'certificateChain': List<String>.from(result['certificateChain'] ?? []),
      },
    };
  }

  // ============================================================================
  // Signing Operations (Section 1.2 of Plan)
  // ============================================================================

  /// Sign Payload (Hardware backed)
  /// Payload usually follows: "challenge|keyId|timestamp"
  Future<String> signPayload(String payload) async {
    final String? signature = await _channel.invokeMethod('signPayload', {
      'payload': payload,
    });

    if (signature == null) {
      throw Exception('Failed to sign payload in hardware');
    }

    return signature;
  }

  // ============================================================================
  // Metadata & Helpers
  // ============================================================================

  Future<bool> hasKey() async {
    final bool? result = await _channel.invokeMethod('hasKey');
    return result ?? false;
  }

  Future<String?> getKeyId() async {
    return await _channel.invokeMethod<String>('getKeyId');
  }

  Future<String> getPermanentHardwareId() async {
    final String? id = await _channel.invokeMethod<String>('getHardwareId');
    return id ?? "unknown_hw_id";
  }

  Future<void> deleteKey() async {
    await _channel.invokeMethod('deleteKey');
    await _metadata.clearAll();
  }

  Future<void> savePhysicalDeviceId(int id) =>
      _metadata.savePhysicalDeviceId(id);
  Future<int?> getPhysicalDeviceId() => _metadata.getPhysicalDeviceId();
  Future<void> saveAssignmentId(int? id) => _metadata.saveAssignmentId(id);
  Future<int?> getAssignmentId() => _metadata.getAssignmentId();

  Future<void> clearDeviceData() async {
    await deleteKey();
    await _metadata.clearAll();
  }
}
