import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../core/utils/device_info_util.dart';

/// Device-Bound Key Service
///
/// A singleton service that manages device-bound cryptographic keys stored
/// in hardware security modules (HSM). This service provides secure key
/// generation, signing, and management capabilities.
///
/// ## Security Features
/// - **Hardware Storage**: Keys are stored in Android Keystore / iOS Secure Enclave
/// - **Non-extractable**: Private keys never leave the hardware, even with root/jailbreak
/// - **Device Binding**: Keys are bound to the specific device
/// - **Attestation**: Supports hardware attestation for key verification
///
/// ## Storage Architecture
/// - **Private Key**: Stored in hardware (Android Keystore / iOS Secure Enclave)
/// - **Public Key**: Can be retrieved from hardware when needed
/// - **Key ID**: Stored in hardware-backed encrypted storage
///   - Android: EncryptedSharedPreferences with Android Keystore
///   - iOS: Keychain (protected by Secure Enclave on supported devices)
///
/// ## Usage Example
/// ```dart
/// final service = DeviceBoundKeyService();
///
/// // Generate a new key pair
/// final keyPair = await service.generateKeyPair(challenge);
///
/// // Sign a payload
/// final signature = await service.signPayload('challenge|keyId|timestamp');
///
/// // Check if key exists
/// final hasKey = await service.hasKey();
/// ```
class DeviceBoundKeyService {
  // Singleton pattern
  static final DeviceBoundKeyService _instance =
      DeviceBoundKeyService._internal();
  factory DeviceBoundKeyService() => _instance;
  DeviceBoundKeyService._internal();

  // Constants
  static const MethodChannel _channel = MethodChannel(
    'com.rs4it.king_abdulaziz_center_survey_app/hardware_keystore',
  );

  // Response keys
  static const String _publicKeyKey = 'publicKey';
  static const String _signatureKey = 'signature';
  static const String _certificateChainKey = 'certificateChain';

  // ============================================================================
  // Key Generation
  // ============================================================================

  /// Generates a new device-bound key pair in hardware security module
  ///
  /// This method:
  /// 1. Generates a unique key ID based on device ID and timestamp
  /// 2. Creates an ECDSA key pair in hardware (P-256 curve, ES256)
  /// 3. Signs the challenge for proof of possession
  /// 4. Retrieves attestation certificate chain (Android only)
  /// 5. Stores the key ID in hardware-backed secure storage
  ///
  /// **Parameters:**
  /// - [challenge] - Challenge string from backend for attestation and proof of possession
  ///
  /// **Returns:**
  /// A map containing:
  /// - `publicKey` (String): Base64-encoded public key in SPKI format
  /// - `keyId` (String): Unique identifier for this key pair
  /// - `signature` (String): Base64-encoded DER signature of the challenge (Proof of Possession)
  /// - `deviceId` (String): Device identifier used to bind the key
  /// - `attestation` (Map, optional): Attestation data with certificate chain (Android only)
  ///
  /// **Throws:**
  /// - `Exception` if key generation fails or hardware is unavailable
  ///
  /// **Example:**
  /// ```dart
  /// final challenge = 'random-challenge-from-backend';
  /// final keyPair = await service.generateKeyPair(challenge);
  /// print('Key ID: ${keyPair['keyId']}');
  /// print('Public Key: ${keyPair['publicKey']}');
  /// ```
  Future<Map<String, dynamic>> generateKeyPair(String challenge) async {
    try {
      // Validate challenge
      if (challenge.isEmpty) {
        throw ArgumentError('Challenge cannot be empty');
      }

      // Get device identifier to bind the key to this specific device
      final deviceId = await _getDeviceIdentifier();

      // Generate a unique key ID based on device ID + timestamp
      final keyId = _generateKeyId(deviceId);

      // Generate ECDSA key pair in hardware (Android Keystore / iOS Secure Enclave)
      // The private key is stored in hardware and never leaves it
      final hardwareResponse =
          await _invokeHardwareMethod<Map<Object?, Object?>>(
            'generateKeyPair',
            {'challenge': challenge},
          );

      if (hardwareResponse == null) {
        throw DeviceBoundKeyException(
          'Failed to generate key pair in hardware',
          operation: 'generateKeyPair',
        );
      }

      // Extract and validate response data
      final publicKeyBase64 = hardwareResponse[_publicKeyKey] as String?;
      final signatureBase64 = hardwareResponse[_signatureKey] as String?;
      final certificateChain =
          hardwareResponse[_certificateChainKey] as List<Object?>?;

      if (publicKeyBase64 == null || signatureBase64 == null) {
        throw DeviceBoundKeyException(
          'Invalid response from hardware key generation: missing required fields',
          operation: 'generateKeyPair',
        );
      }

      // Store keyId in hardware-backed secure storage
      await _saveKeyIdToHardware(keyId);

      // Build response map
      final response = <String, dynamic>{
        _publicKeyKey: publicKeyBase64,
        'keyId': keyId,
        _signatureKey: signatureBase64, // Proof of Possession
        'deviceId': deviceId,
      };

      // Add attestation if certificate chain is available (Android only)
      if (certificateChain != null && certificateChain.isNotEmpty) {
        response['attestation'] = {
          'certificateChain': certificateChain
              .map((cert) => cert.toString())
              .toList(),
        };
      }

      return response;
    } on DeviceBoundKeyException {
      rethrow;
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('DeviceBoundKeyService.generateKeyPair: Unexpected error');
        print('Error: $e');
        print('Stack trace: $stackTrace');
      }
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

  /// Retrieves the public key from hardware security module
  ///
  /// **Returns:**
  /// - Base64-encoded public key in SPKI format, or `null` if key doesn't exist
  ///
  /// **Example:**
  /// ```dart
  /// final publicKey = await service.getPublicKey();
  /// if (publicKey != null) {
  ///   print('Public Key: $publicKey');
  /// }
  /// ```
  Future<String?> getPublicKey() async {
    try {
      return await _invokeHardwareMethod<String>('getPublicKey');
    } catch (e) {
      if (kDebugMode) {
        print('DeviceBoundKeyService.getPublicKey: Error: $e');
      }
      return null;
    }
  }

  /// Retrieves the key ID from hardware-backed secure storage
  ///
  /// **Returns:**
  /// - Key ID string, or `null` if key ID doesn't exist
  ///
  /// **Example:**
  /// ```dart
  /// final keyId = await service.getKeyId();
  /// if (keyId != null) {
  ///   print('Key ID: $keyId');
  /// }
  /// ```
  Future<String?> getKeyId() async {
    try {
      return await _invokeHardwareMethod<String>('getKeyId');
    } catch (e) {
      if (kDebugMode) {
        print('DeviceBoundKeyService.getKeyId: Error: $e');
      }
      return null;
    }
  }

  /// Checks if a device-bound key exists in hardware security module
  ///
  /// **Returns:**
  /// - `true` if key exists, `false` otherwise
  ///
  /// **Example:**
  /// ```dart
  /// final hasKey = await service.hasKey();
  /// if (hasKey) {
  ///   print('Device key exists');
  /// }
  /// ```
  Future<bool> hasKey() async {
    try {
      final hasKey = await _invokeHardwareMethod<bool>('hasKey');
      return hasKey ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('DeviceBoundKeyService.hasKey: Error: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // Signing Operations
  // ============================================================================

  /// Signs a challenge using the device-bound private key
  ///
  /// This is a convenience method that calls [signPayload] with the challenge.
  ///
  /// **Parameters:**
  /// - [challenge] - Challenge string to sign
  ///
  /// **Returns:**
  /// - Base64-encoded DER signature
  ///
  /// **Throws:**
  /// - `DeviceBoundKeyException` if key doesn't exist or signing fails
  ///
  /// **Example:**
  /// ```dart
  /// final challenge = 'random-challenge';
  /// final signature = await service.signChallenge(challenge);
  /// ```
  Future<String> signChallenge(String challenge) async {
    return signPayload(challenge);
  }

  /// Signs an arbitrary payload string using the device-bound private key
  ///
  /// The private key is stored in hardware and signing happens in hardware.
  /// This method is used for login where payload format is:
  /// `"challenge|keyId|timestamp"`
  ///
  /// **Parameters:**
  /// - [payload] - Payload string to sign (e.g., "challenge|keyId|timestamp")
  ///
  /// **Returns:**
  /// - Base64-encoded DER signature (ECDSA with SHA-256, ES256)
  ///
  /// **Throws:**
  /// - `DeviceBoundKeyException` if key doesn't exist or signing fails
  ///
  /// **Example:**
  /// ```dart
  /// final payload = 'challenge|keyId|1234567890';
  /// final signature = await service.signPayload(payload);
  /// ```
  Future<String> signPayload(String payload) async {
    try {
      // Validate payload
      if (payload.isEmpty) {
        throw ArgumentError('Payload cannot be empty');
      }

      // Check if key exists in hardware
      if (!await hasKey()) {
        throw DeviceBoundKeyException(
          'Device-bound key not found. Please register device first.',
          operation: 'signPayload',
        );
      }

      // Sign the payload string exactly as the backend verifies it
      // Backend uses the UTF-8 bytes of the same payload string.
      // Pass payload directly as string to platform channel
      final signatureBase64 = await _invokeHardwareMethod<String>(
        'signPayload',
        {'payload': payload},
      );

      if (signatureBase64 == null || signatureBase64.isEmpty) {
        throw DeviceBoundKeyException(
          'Failed to sign data in hardware: empty signature returned',
          operation: 'signPayload',
        );
      }

      // Return signature as base64 string (DER-encoded ECDSA signature)
      return signatureBase64;
    } on DeviceBoundKeyException {
      rethrow;
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('DeviceBoundKeyService.signPayload: Unexpected error');
        print('Error: $e');
        print('Stack trace: $stackTrace');
      }
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

  /// Deletes the device-bound key from hardware security module
  ///
  /// This method deletes both:
  /// - The cryptographic key pair from hardware
  /// - The key ID from hardware-backed secure storage
  ///
  /// This is typically used for re-registration scenarios.
  ///
  /// **Example:**
  /// ```dart
  /// await service.deleteKey();
  /// ```
  Future<void> deleteKey() async {
    try {
      // Delete key from hardware
      await _invokeHardwareMethod('deleteKey');

      // Delete keyId from hardware storage
      await _deleteKeyIdFromHardware();
    } catch (e) {
      if (kDebugMode) {
        print('DeviceBoundKeyService.deleteKey: Error: $e');
      }
      // Still try to delete keyId even if hardware deletion fails
      try {
        await _deleteKeyIdFromHardware();
      } catch (deleteError) {
        // Ignore errors when deleting keyId (best effort cleanup)
        if (kDebugMode) {
          print(
            'DeviceBoundKeyService.deleteKey: Failed to delete keyId: $deleteError',
          );
        }
      }
      // Re-throw original error if key deletion failed
      throw DeviceBoundKeyException(
        'Failed to delete device-bound key: $e',
        operation: 'deleteKey',
        originalError: e,
      );
    }
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  /// Gets device identifier for key binding
  ///
  /// Tries to get platform device ID first, falls back to device token.
  /// Device token always returns a non-null value (generates UUID if needed).
  Future<String> _getDeviceIdentifier() async {
    final deviceId =
        await DeviceInfoUtil.getPlatformDeviceId() ??
        await DeviceInfoUtil.getDeviceToken();

    // getDeviceToken() always returns a non-null String, so deviceId can't be null
    // But we check isEmpty as a safety measure
    if (deviceId.isEmpty) {
      throw DeviceBoundKeyException(
        'Failed to get device identifier: empty identifier',
        operation: '_getDeviceIdentifier',
      );
    }

    return deviceId;
  }

  /// Generates a unique key ID based on device ID and timestamp
  ///
  /// Uses SHA-256 hash of "deviceId-timestamp" to ensure uniqueness.
  String _generateKeyId(String deviceId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final keyIdInput = '$deviceId-$timestamp';
    return sha256.convert(utf8.encode(keyIdInput)).toString();
  }

  /// Saves key ID to hardware-backed secure storage
  Future<void> _saveKeyIdToHardware(String keyId) async {
    try {
      await _invokeHardwareMethod('saveKeyId', {'keyId': keyId});
    } catch (e) {
      throw DeviceBoundKeyException(
        'Failed to save key ID to hardware storage: $e',
        operation: '_saveKeyIdToHardware',
        originalError: e,
      );
    }
  }

  /// Deletes key ID from hardware-backed secure storage
  Future<void> _deleteKeyIdFromHardware() async {
    await _invokeHardwareMethod('deleteKeyId');
  }

  /// Invokes a method on the hardware keystore platform channel
  ///
  /// This is a type-safe wrapper around MethodChannel.invokeMethod.
  Future<T?> _invokeHardwareMethod<T>(
    String method, [
    Map<String, dynamic>? arguments,
  ]) async {
    try {
      if (arguments != null) {
        return await _channel.invokeMethod<T>(method, arguments);
      } else {
        return await _channel.invokeMethod<T>(method);
      }
    } on PlatformException catch (e) {
      throw DeviceBoundKeyException(
        'Platform error: ${e.message}',
        operation: method,
        originalError: e,
      );
    } catch (e) {
      throw DeviceBoundKeyException(
        'Failed to invoke hardware method "$method": $e',
        operation: method,
        originalError: e,
      );
    }
  }
}

// ============================================================================
// Custom Exceptions
// ============================================================================

/// Custom exception for device-bound key operations
///
/// Provides detailed error information including the operation that failed
/// and the original error (if any).
class DeviceBoundKeyException implements Exception {
  /// Error message
  final String message;

  /// Operation that failed (e.g., 'generateKeyPair', 'signPayload')
  final String operation;

  /// Original error that caused this exception (if any)
  final Object? originalError;

  DeviceBoundKeyException(
    this.message, {
    required this.operation,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('DeviceBoundKeyException');
    buffer.write('($operation): $message');
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceBoundKeyException &&
        other.message == message &&
        other.operation == operation &&
        other.originalError == originalError;
  }

  @override
  int get hashCode => Object.hash(message, operation, originalError);
}
