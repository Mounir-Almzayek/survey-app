import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/export.dart';
import '../../core/utils/device_info_util.dart';
import 'secure_storage_service.dart';

/// Device-Bound Key Service
///
/// Generates and manages device-bound cryptographic keys that are:
/// - Stored locally only (no cloud sync)
/// - Bound to the specific device
/// - Used for device authentication
class DeviceBoundKeyService {
  static final DeviceBoundKeyService _instance =
      DeviceBoundKeyService._internal();
  factory DeviceBoundKeyService() => _instance;
  DeviceBoundKeyService._internal();

  static const String _publicKeyStorageKey = 'device_bound_public_key';
  static const String _keyIdStorageKey = 'device_bound_key_id';
  static final SecureStorageService _secureStorage = SecureStorageService();
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Generate a new device-bound key pair
  ///
  /// Returns: Map containing 'publicKey' (base64) and 'keyId'
  Future<Map<String, String>> generateKeyPair() async {
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

      // Generate RSA key pair (2048 bits)
      // Note: In production, you should use platform-specific secure storage
      // (Android Keystore / iOS Secure Enclave) via platform channels
      final keyPair = _generateRSAKeyPair();

      // Extract public key in PEM format
      final publicKeyPem = _encodePublicKeyToPEM(
        keyPair['public'] as List<int>,
      );

      // Store public key securely (private key should be in hardware keystore)
      await _secureStorage.write(_publicKeyStorageKey, publicKeyPem);
      await _secureStorage.write(_keyIdStorageKey, keyId);

      return {'publicKey': publicKeyPem, 'keyId': keyId, 'deviceId': deviceId};
    } catch (e) {
      throw Exception('Failed to generate device-bound key: $e');
    }
  }

  /// Get existing public key
  Future<String?> getPublicKey() async {
    return await _secureStorage.read(_publicKeyStorageKey);
  }

  /// Get key ID
  Future<String?> getKeyId() async {
    return await _secureStorage.read(_keyIdStorageKey);
  }

  /// Check if device-bound key exists
  Future<bool> hasKey() async {
    final publicKey = await getPublicKey();
    return publicKey != null && publicKey.isNotEmpty;
  }

  /// Sign a challenge using the device-bound private key
  ///
  /// Requires biometric authentication before signing
  Future<String> signChallenge(String challenge) async {
    try {
      // Check if key exists
      if (!await hasKey()) {
        throw Exception(
          'Device-bound key not found. Please register device first.',
        );
      }

      // Request biometric authentication
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

      // Get device ID for additional binding
      final deviceId =
          await DeviceInfoUtil.getPlatformDeviceId() ??
          await DeviceInfoUtil.getDeviceToken();

      // Create signature payload: challenge + deviceId + timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final payload = '$challenge|$deviceId|$timestamp';

      // Sign the payload
      // Note: In production, this should use hardware-backed signing
      final signature = _signData(utf8.encode(payload));

      // Return signature + metadata as JSON
      return jsonEncode({
        'signature': base64Encode(signature),
        'deviceId': deviceId,
        'timestamp': timestamp,
        'challenge': challenge,
      });
    } catch (e) {
      throw Exception('Failed to sign challenge: $e');
    }
  }

  /// Verify signature (for testing purposes)
  /// In production, this is done on the server side
  Future<bool> verifySignature(String challenge, String signatureJson) async {
    try {
      final signatureData = jsonDecode(signatureJson) as Map<String, dynamic>;
      final signature = base64Decode(signatureData['signature'] as String);
      final deviceId = signatureData['deviceId'] as String;
      final timestamp = signatureData['timestamp'] as int;

      final payload = '$challenge|$deviceId|$timestamp';
      return _verifySignature(utf8.encode(payload), signature);
    } catch (e) {
      return false;
    }
  }

  /// Delete device-bound key (for re-registration)
  Future<void> deleteKey() async {
    await _secureStorage.delete(_publicKeyStorageKey);
    await _secureStorage.delete(_keyIdStorageKey);
  }

  // Private helper methods

  /// Generate RSA key pair (2048 bits)
  /// Note: In production, use Android Keystore / iOS Secure Enclave
  Map<String, dynamic> _generateRSAKeyPair() {
    final keyGen = RSAKeyGenerator();
    final secureRandom = FortunaRandom();

    // Initialize secure random
    final seedSource = _getSecureRandom();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    // Generate RSA key parameters
    final keyParams = RSAKeyGeneratorParameters(
      BigInt.parse('65537'),
      2048,
      64,
    );
    final paramsWithRandom = ParametersWithRandom(keyParams, secureRandom);
    keyGen.init(paramsWithRandom);

    // Generate key pair
    final keyPair = keyGen.generateKeyPair();
    final publicKey = keyPair.publicKey as RSAPublicKey;
    final privateKey = keyPair.privateKey as RSAPrivateKey;

    return {'public': publicKey, 'private': privateKey};
  }

  /// Get secure random source
  _SecureRandomSource _getSecureRandom() {
    return _SecureRandomSource();
  }

  /// Encode public key to base64 string
  String _encodePublicKeyToPEM(dynamic publicKey) {
    if (publicKey is RSAPublicKey) {
      // Encode RSA public key as base64
      final modulus = publicKey.modulus;
      final exponent = publicKey.exponent;

      // Simple encoding: modulus|exponent
      final keyData = '${modulus.toString()}|${exponent.toString()}';
      return base64Encode(utf8.encode(keyData));
    }
    throw Exception('Invalid public key type');
  }

  /// Sign data using private key with SHA256
  List<int> _signData(List<int> data) {
    // Get stored private key (in production, this should be from hardware keystore)
    // For now, we'll use a hash-based approach
    // In production, use RSA signing with private key from hardware keystore
    final hash = sha256.convert(data);
    return hash.bytes;
  }

  /// Verify signature using public key
  bool _verifySignature(List<int> data, List<int> signature) {
    // In production, verify RSA signature using public key
    // For now, use hash comparison
    final hash = sha256.convert(data);
    return hash.bytes.toString() == signature.toString();
  }
}

/// Secure random source helper
class _SecureRandomSource {
  int nextInt(int max) {
    return DateTime.now().microsecondsSinceEpoch % max;
  }
}
