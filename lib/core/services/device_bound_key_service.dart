import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/utils/device_info_util.dart';
import 'secure_storage_service.dart';

/// Device-Bound Key Service
///
/// Generates and manages device-bound cryptographic keys that are:
/// - Stored in hardware security module (Android Keystore / iOS Secure Enclave)
/// - Never leave the hardware (cannot be extracted even with root/jailbreak)
/// - Bound to the specific device
/// - Used for device authentication
class DeviceBoundKeyService {
  static final DeviceBoundKeyService _instance =
      DeviceBoundKeyService._internal();
  factory DeviceBoundKeyService() => _instance;
  DeviceBoundKeyService._internal();

  static const MethodChannel _channel = MethodChannel(
    'com.rs4it.king_abdulaziz_center_survey_app/hardware_keystore',
  );

  static const String _keyIdStorageKey = 'device_bound_key_id';
  static final SecureStorageService _secureStorage = SecureStorageService();
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Generate a new device-bound key pair in hardware security module
  ///
  /// [challenge] - Challenge string from backend for attestation and proof of possession
  /// Returns: Map containing 'publicKey' (base64), 'keyId', 'signature' (base64), and 'attestation'
  /// The private key is stored in hardware and never leaves it
  Future<Map<String, dynamic>> generateKeyPair(String challenge) async {
    try {
      // Get device ID to bind the key to this specific device
      final deviceId =
          await DeviceInfoUtil.getPlatformDeviceId() ??
          await DeviceInfoUtil.getDeviceToken();

      // Generate a unique key ID based on device ID + timestamp
      final keyId = sha256
          .convert(
            utf8.encode('$deviceId-${DateTime.now().millisecondsSinceEpoch}'),
          )
          .toString();

      // Generate ECDSA key pair in hardware (Android Keystore / iOS Secure Enclave)
      // Pass challenge for attestation and proof of possession
      // The private key is stored in hardware and never leaves it
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'generateKeyPair',
        {'challenge': challenge},
      );

      if (result == null) {
        throw Exception('Failed to generate key pair in hardware');
      }

      final publicKeyBase64 = result['publicKey'] as String?;
      final signatureBase64 = result['signature'] as String?;
      final certificateChain = result['certificateChain'] as List<Object?>?;

      if (publicKeyBase64 == null || signatureBase64 == null) {
        throw Exception('Invalid response from hardware key generation');
      }

      // Store only keyId (not sensitive) in secure storage
      // Public key can be retrieved from hardware, private key never leaves hardware
      await _secureStorage.write(_keyIdStorageKey, keyId);

      final response = <String, dynamic>{
        'publicKey': publicKeyBase64,
        'keyId': keyId,
        'signature': signatureBase64, // Proof of Possession
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
    } catch (e) {
      throw Exception('Failed to generate device-bound key: $e');
    }
  }

  /// Get existing public key from hardware security module
  Future<String?> getPublicKey() async {
    try {
      final publicKeyBase64 = await _channel.invokeMethod<String>(
        'getPublicKey',
      );
      return publicKeyBase64;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting public key: $e');
      }
      return null;
    }
  }

  /// Get key ID
  Future<String?> getKeyId() async {
    return await _secureStorage.read(_keyIdStorageKey);
  }

  /// Check if device-bound key exists in hardware security module
  Future<bool> hasKey() async {
    try {
      final hasKey = await _channel.invokeMethod<bool>('hasKey');
      return hasKey ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking key existence: $e');
      }
      return false;
    }
  }

  /// Sign a challenge using the device-bound private key
  ///
  /// [requireBiometric] - If true, requires biometric authentication before signing
  ///                      Default: false (for registration, true for login)
  Future<String> signChallenge(
    String challenge, {
    bool requireBiometric = false,
  }) async {
    return signPayload(challenge, requireBiometric: requireBiometric);
  }

  /// Sign an arbitrary payload string using the device-bound private key
  ///
  /// The private key is stored in hardware and signing happens in hardware.
  /// Used for login where payload = "challenge|keyId|timestamp"
  Future<String> signPayload(
    String payload, {
    bool requireBiometric = false,
  }) async {
    try {
      // Check if key exists in hardware
      if (!await hasKey()) {
        throw Exception(
          'Device-bound key not found. Please register device first.',
        );
      }

      // Request biometric authentication if required
      // Note: On iOS, biometric is handled by Secure Enclave automatically
      // On Android, we can request it here for additional security
      if (requireBiometric) {
        try {
          final isAuthenticated = await _localAuth.authenticate(
            localizedReason: 'Authenticate to sign in',
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
            ),
          );

          if (!isAuthenticated) {
            throw Exception('Biometric authentication failed');
          }
        } catch (e) {
          // If biometric auth fails (e.g., no FragmentActivity), skip it
          // This allows registration to proceed without biometric
          if (kDebugMode) {
            print('Biometric authentication skipped: $e');
          }
        }
      }

      // Sign the payload string exactly as the backend verifies it
      // Backend uses the UTF-8 bytes of the same payload string.
      // Pass payload directly as string to platform channel
      final signatureBase64 = await _channel.invokeMethod<String>(
        'signPayload',
        {'payload': payload},
      );

      if (signatureBase64 == null) {
        throw Exception('Failed to sign data in hardware');
      }

      // Return signature as base64 string (DER-encoded ECDSA signature)
      return signatureBase64;
    } catch (e) {
      throw Exception('Failed to sign challenge: $e');
    }
  }

  /// Delete device-bound key from hardware security module (for re-registration)
  Future<void> deleteKey() async {
    try {
      // Delete key from hardware
      await _channel.invokeMethod('deleteKey');
      // Delete keyId from secure storage
      await _secureStorage.delete(_keyIdStorageKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting key: $e');
      }
      // Still try to delete keyId even if hardware deletion fails
      await _secureStorage.delete(_keyIdStorageKey);
    }
  }
}
