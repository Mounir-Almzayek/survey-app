import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'hardware_keystore_service.dart';
import 'device_local_metadata_service.dart';
import '../utils/device_identifier_provider.dart';

/// Device-Bound Key Service (Facade)
///
/// Orchestrates device-bound cryptographic operations by coordinating between:
/// - [HardwareKeystoreService]: Native hardware security module interactions
/// - [DeviceLocalMetadataService]: Persistent storage for device metadata
/// - [DeviceIdentifierProvider]: Device identification logic
class DeviceBoundKeyService {
  // Singleton pattern
  static final DeviceBoundKeyService _instance =
      DeviceBoundKeyService._internal();
  factory DeviceBoundKeyService() => _instance;
  DeviceBoundKeyService._internal();

  final HardwareKeystoreService _hardwareKeystore = HardwareKeystoreService();
  final DeviceLocalMetadataService _metadata = DeviceLocalMetadataService();
  final DeviceIdentifierProvider _idProvider = DeviceIdentifierProvider();

  // ============================================================================
  // Key Generation
  // ============================================================================

  /// Generates a new device-bound key pair in hardware security module
  Future<Map<String, dynamic>> generateKeyPair(String challenge) async {
    try {
      if (challenge.isEmpty) {
        throw ArgumentError('Challenge cannot be empty');
      }

      final deviceId = await _idProvider.getDeviceIdentifier();
      final keyId = _generateKeyId(deviceId);

      final hardwareResponse = await _hardwareKeystore.generateKeyPair(
        challenge,
      );

      if (hardwareResponse == null) {
        throw DeviceBoundKeyException(
          'Failed to generate key pair in hardware',
          operation: 'generateKeyPair',
        );
      }

      final publicKeyBase64 =
          hardwareResponse[HardwareKeystoreService.publicKeyKey] as String?;
      final signatureBase64 =
          hardwareResponse[HardwareKeystoreService.signatureKey] as String?;
      final certificateChain =
          hardwareResponse[HardwareKeystoreService.certificateChainKey]
              as List<Object?>?;

      if (publicKeyBase64 == null || signatureBase64 == null) {
        throw DeviceBoundKeyException(
          'Invalid response from hardware: missing required fields',
          operation: 'generateKeyPair',
        );
      }

      await _hardwareKeystore.saveKeyId(keyId);

      final response = <String, dynamic>{
        'publicKey': publicKeyBase64,
        'keyId': keyId,
        'signature': signatureBase64,
        'deviceId': deviceId,
      };

      if (certificateChain != null && certificateChain.isNotEmpty) {
        response['attestation'] = {
          'certificateChain': certificateChain
              .map((cert) => cert.toString())
              .toList(),
        };
      }

      return response;
    } catch (e) {
      if (e is DeviceBoundKeyException || e is ArgumentError) rethrow;
      throw DeviceBoundKeyException(
        'Failed to generate device-bound key: $e',
        operation: 'generateKeyPair',
        originalError: e,
      );
    }
  }

  // ============================================================================
  // Key Retrieval
  // ============================================================================

  Future<String?> getPublicKey() => _hardwareKeystore.getPublicKey();

  Future<String?> getKeyId() => _hardwareKeystore.getKeyId();

  /// Gets or creates a key ID that is always available
  Future<String> getOrCreateKeyId() async {
    final existingKeyId = await getKeyId();
    if (existingKeyId != null && existingKeyId.isNotEmpty) {
      return existingKeyId;
    }

    final deviceId = await getOrCreateDeviceId();
    final keyId = _generateDeterministicKeyId(deviceId);

    try {
      await _hardwareKeystore.saveKeyId(keyId);
    } catch (e) {
      if (kDebugMode) {
        print('DeviceBoundKeyService: Failed to save deterministic key ID: $e');
      }
    }

    return keyId;
  }

  Future<String> getOrCreateDeviceId() => _idProvider.getDeviceIdentifier();

  Future<bool> hasKey() => _hardwareKeystore.hasKey();

  // ============================================================================
  // Signing Operations
  // ============================================================================

  Future<String> signChallenge(String challenge) => signPayload(challenge);

  Future<String> signPayload(String payload) async {
    try {
      if (payload.isEmpty) throw ArgumentError('Payload cannot be empty');

      if (!await hasKey()) {
        throw DeviceBoundKeyException(
          'Device-bound key not found. Please register device first.',
          operation: 'signPayload',
        );
      }

      final signature = await _hardwareKeystore.signPayload(payload);

      if (signature == null || signature.isEmpty) {
        throw DeviceBoundKeyException(
          'Failed to sign data in hardware: empty signature returned',
          operation: 'signPayload',
        );
      }

      return signature;
    } catch (e) {
      if (e is DeviceBoundKeyException || e is ArgumentError) rethrow;
      throw DeviceBoundKeyException(
        'Failed to sign payload: $e',
        operation: 'signPayload',
        originalError: e,
      );
    }
  }

  // ============================================================================
  // Key Management
  // ============================================================================

  Future<void> deleteKey() async {
    try {
      await _hardwareKeystore.deleteKey();
      await _hardwareKeystore.deleteKeyId();
    } catch (e) {
      throw DeviceBoundKeyException(
        'Failed to delete device-bound key: $e',
        operation: 'deleteKey',
        originalError: e,
      );
    }
  }

  // ============================================================================
  // Metadata Management
  // ============================================================================

  Future<void> savePhysicalDeviceId(int id) =>
      _metadata.savePhysicalDeviceId(id);

  Future<int?> getPhysicalDeviceId() async => _metadata.getPhysicalDeviceId();

  Future<void> saveAssignmentId(int? id) => _metadata.saveAssignmentId(id);

  Future<int?> getAssignmentId() async => _metadata.getAssignmentId();

  Future<void> clearDeviceData() async {
    await _metadata.clearAll();
    try {
      await _hardwareKeystore.deleteKeyId();
      await _hardwareKeystore.deleteNativeDeviceId();
    } catch (e) {
      if (kDebugMode) {
        print('DeviceBoundKeyService: Failed to clear hardware data: $e');
      }
    }
  }

  // ============================================================================
  // Private Helpers
  // ============================================================================

  String _generateKeyId(String deviceId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final keyIdInput = '$deviceId-$timestamp';
    return sha256.convert(utf8.encode(keyIdInput)).toString();
  }

  String _generateDeterministicKeyId(String deviceId) {
    final keyIdInput = 'device_key_$deviceId';
    return sha256.convert(utf8.encode(keyIdInput)).toString();
  }
}

/// Custom exception for device-bound key operations
class DeviceBoundKeyException implements Exception {
  final String message;
  final String operation;
  final Object? originalError;

  DeviceBoundKeyException(
    this.message, {
    required this.operation,
    this.originalError,
  });

  @override
  String toString() =>
      'DeviceBoundKeyException($operation): $message${originalError != null ? '\nOriginal error: $originalError' : ''}';
}
