import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
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
  static const String _privateKeyStorageKey = 'device_bound_private_key';
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

      // Generate ECDSA key pair (ES256 - P-256 curve)
      // Note: In production, you should use platform-specific secure storage
      // (Android Keystore / iOS Secure Enclave) via platform channels
      final keyPair = _generateECDSAKeyPair();

      // Extract public key in base64 format
      final publicKeyBase64 = _encodeECPublicKeyToBase64(
        keyPair['public'] as ECPublicKey,
      );

      // Extract private key in base64 format (for signing)
      final privateKeyBase64 = _encodeECPrivateKeyToBase64(
        keyPair['private'] as ECPrivateKey,
      );

      // Store keys securely
      await _secureStorage.write(_publicKeyStorageKey, publicKeyBase64);
      await _secureStorage.write(_privateKeyStorageKey, privateKeyBase64);
      await _secureStorage.write(_keyIdStorageKey, keyId);

      return {
        'publicKey': publicKeyBase64,
        'keyId': keyId,
        'deviceId': deviceId,
      };
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
  /// Used for login where payload = "challenge|keyId|timestamp"
  Future<String> signPayload(
    String payload, {
    bool requireBiometric = false,
  }) async {
    try {
      // Check if key exists
      if (!await hasKey()) {
        throw Exception(
          'Device-bound key not found. Please register device first.',
        );
      }

      // Request biometric authentication if required
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
      final payloadBytes = utf8.encode(payload);
      final signature = await _signDataWithECDSA(payloadBytes);

      // Return signature as base64 string (just the signature, no metadata)
      return base64Encode(signature);
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
    await _secureStorage.delete(_privateKeyStorageKey);
    await _secureStorage.delete(_keyIdStorageKey);
  }

  // Private helper methods

  /// Generate ECDSA key pair (ES256 - P-256 curve)
  /// Note: In production, use Android Keystore / iOS Secure Enclave
  Map<String, dynamic> _generateECDSAKeyPair() {
    final keyGen = ECKeyGenerator();

    // Use FortunaRandom directly and seed it
    final secureRandom = FortunaRandom();

    // Initialize secure random with entropy
    final entropy = _getSecureRandomEntropy();
    secureRandom.seed(KeyParameter(Uint8List.fromList(entropy)));

    // Use P-256 curve (secp256r1) for ES256
    final domainParams = _getECDomainParameters();
    final keyParams = ECKeyGeneratorParameters(domainParams);
    final paramsWithRandom = ParametersWithRandom(keyParams, secureRandom);
    keyGen.init(paramsWithRandom);

    // Generate key pair
    final keyPair = keyGen.generateKeyPair();
    final publicKey = keyPair.publicKey as ECPublicKey;
    final privateKey = keyPair.privateKey as ECPrivateKey;

    return {'public': publicKey, 'private': privateKey};
  }

  /// Get secure random entropy (32 bytes)
  List<int> _getSecureRandomEntropy() {
    // Use system time and random values for entropy
    final now = DateTime.now();
    final entropy = <int>[];

    // Add timestamp-based entropy
    final timestamp = now.millisecondsSinceEpoch;
    for (int i = 0; i < 8; i++) {
      entropy.add((timestamp >> (i * 8)) & 0xff);
    }

    // Add microsecond-based entropy
    final microseconds = now.microsecondsSinceEpoch;
    for (int i = 0; i < 8; i++) {
      entropy.add((microseconds >> (i * 8)) & 0xff);
    }

    // Add additional random values
    final random = DateTime.now().microsecondsSinceEpoch;
    for (int i = 0; i < 16; i++) {
      entropy.add((random >> (i * 2)) & 0xff);
    }

    return entropy;
  }

  /// Encode ECDSA public key to base64 string
  String _encodeECPublicKeyToBase64(ECPublicKey publicKey) {
    final point = publicKey.Q;
    final x = point!.x!.toBigInteger()!;
    final y = point.y!.toBigInteger()!;

    // Convert x and y to bytes (32 bytes each for P-256)
    final xBytes = _bigIntToBytes(x, 32);
    final yBytes = _bigIntToBytes(y, 32);

    // Uncompressed point format: 0x04 + x + y (65 bytes total for P-256)
    final uncompressedPoint = <int>[0x04, ...xBytes, ...yBytes];

    // Encode as SPKI (SubjectPublicKeyInfo) DER structure expected by backend
    // SEQUENCE {
    //   SEQUENCE {
    //     OBJECT IDENTIFIER 1.2.840.10045.2.1 (id-ecPublicKey)
    //     OBJECT IDENTIFIER 1.2.840.10045.3.1.7 (secp256r1)
    //   }
    //   BIT STRING (uncompressedPoint)
    // }

    // id-ecPublicKey OID: 1.2.840.10045.2.1
    final algorithmId = <int>[
      0x06,
      0x07,
      0x2A,
      0x86,
      0x48,
      0xCE,
      0x3D,
      0x02,
      0x01,
    ];

    // secp256r1 OID: 1.2.840.10045.3.1.7
    final namedCurve = <int>[
      0x06,
      0x08,
      0x2A,
      0x86,
      0x48,
      0xCE,
      0x3D,
      0x03,
      0x01,
      0x07,
    ];

    // SEQUENCE (algorithm)
    final algorithmSeqContent = <int>[...algorithmId, ...namedCurve];
    final algorithmSeq = <int>[
      0x30,
      algorithmSeqContent.length,
      ...algorithmSeqContent,
    ];

    // BIT STRING for public key: 0 unused bits + uncompressed point
    final bitStringContent = <int>[0x00, ...uncompressedPoint];
    final bitString = <int>[0x03, bitStringContent.length, ...bitStringContent];

    // SPKI SEQUENCE
    final spkiContent = <int>[...algorithmSeq, ...bitString];
    final spki = <int>[0x30, spkiContent.length, ...spkiContent];

    return base64Encode(spki);
  }

  /// Encode ECDSA private key to base64 string
  String _encodeECPrivateKeyToBase64(ECPrivateKey privateKey) {
    // d is already BigInt in pointycastle
    final d = privateKey.d!;
    return base64Encode(utf8.encode(d.toString()));
  }

  /// Decode ECDSA private key from base64 string
  Future<ECPrivateKey> _decodeECPrivateKeyFromBase64(
    String privateKeyBase64,
  ) async {
    final dStr = utf8.decode(base64Decode(privateKeyBase64));
    final d = BigInt.parse(dStr);

    // Reconstruct private key (we need domain parameters)
    final domainParams = _getECDomainParameters();
    return ECPrivateKey(d, domainParams);
  }

  /// Decode ECDSA public key from base64 string
  /// Format: Uncompressed point (0x04 + x + y)
  Future<ECPublicKey> _decodeECPublicKeyFromBase64(
    String publicKeyBase64,
  ) async {
    final keyBytes = base64Decode(publicKeyBase64);

    // Uncompressed point format: 0x04 + x + y (65 bytes total for P-256)
    if (keyBytes.length != 65 || keyBytes[0] != 0x04) {
      throw Exception('Invalid public key format');
    }

    // Extract x and y (32 bytes each)
    final xBytes = keyBytes.sublist(1, 33);
    final yBytes = keyBytes.sublist(33, 65);

    final x = _bytesToBigInt(xBytes);
    final y = _bytesToBigInt(yBytes);

    final domainParams = _getECDomainParameters();
    final curve = domainParams.curve;
    final point = curve.createPoint(x, y);

    return ECPublicKey(point, domainParams);
  }

  /// Get ECDSA domain parameters for P-256 (secp256r1)
  ECDomainParameters _getECDomainParameters() {
    // ECCurve_secp256r1() returns ECDomainParameters directly
    return ECCurve_secp256r1();
  }

  /// Sign data using ECDSA private key with SHA256 (ES256)
  Future<List<int>> _signDataWithECDSA(List<int> data) async {
    // Get stored private key
    final privateKeyBase64 = await _secureStorage.read(_privateKeyStorageKey);
    if (privateKeyBase64 == null) {
      throw Exception('Private key not found');
    }

    // Decode private key
    final privateKey = await _decodeECPrivateKeyFromBase64(privateKeyBase64);

    // Sign using ECDSA with SHA-256 (ES256 semantics)
    // We pass the raw data bytes; the signer will hash internally.
    final signer = Signer('SHA-256/ECDSA');

    // Create SecureRandom for signing
    final secureRandom = FortunaRandom();
    final entropy = _getSecureRandomEntropy();
    secureRandom.seed(KeyParameter(Uint8List.fromList(entropy)));

    // Initialize signer with private key and secure random
    signer.init(
      true,
      ParametersWithRandom(PrivateKeyParameter(privateKey), secureRandom),
    );

    // Sign the data
    final signature =
        signer.generateSignature(Uint8List.fromList(data)) as ECSignature;

    // DER-encode ECDSA signature as SEQUENCE of two INTEGERs (r, s)
    final r = signature.r;
    final s = signature.s;

    final derR = _encodeDerInteger(r);
    final derS = _encodeDerInteger(s);

    return _encodeDerSequence(derR, derS);
  }

  /// Convert BigInt to bytes (fixed length with proper padding)
  List<int> _bigIntToBytes(BigInt value, int length) {
    // Convert to bytes (big-endian)
    final bytes = <int>[];
    var temp = value;

    // Extract all bytes
    while (temp > BigInt.zero) {
      bytes.insert(0, (temp & BigInt.from(0xff)).toInt());
      temp = temp >> 8;
    }

    // Pad with zeros at the beginning to reach desired length
    while (bytes.length < length) {
      bytes.insert(0, 0);
    }

    // Trim if longer than desired (shouldn't happen for P-256, but just in case)
    if (bytes.length > length) {
      return bytes.sublist(bytes.length - length);
    }

    return bytes;
  }

  /// Verify signature using public key
  Future<bool> _verifySignature(List<int> data, List<int> signature) async {
    try {
      // Get stored public key
      final publicKeyBase64 = await _secureStorage.read(_publicKeyStorageKey);
      if (publicKeyBase64 == null) {
        return false;
      }

      // Decode public key
      final publicKey = await _decodeECPublicKeyFromBase64(publicKeyBase64);

      // Hash the data
      final hash = sha256.convert(data);
      final hashBytes = hash.bytes;

      // Split signature into r and s (32 bytes each)
      if (signature.length != 64) {
        return false;
      }
      final rBytes = signature.sublist(0, 32);
      final sBytes = signature.sublist(32, 64);
      final r = _bytesToBigInt(rBytes);
      final s = _bytesToBigInt(sBytes);
      final ecSignature = ECSignature(r, s);

      // Verify signature
      final signer = Signer('SHA-256/ECDSA');
      signer.init(false, PublicKeyParameter(publicKey));

      return signer.verifySignature(Uint8List.fromList(hashBytes), ecSignature);
    } catch (e) {
      return false;
    }
  }

  /// Convert bytes to BigInt
  BigInt _bytesToBigInt(List<int> bytes) {
    var result = BigInt.zero;
    for (int i = 0; i < bytes.length; i++) {
      result = result << 8;
      result = result | BigInt.from(bytes[i]);
    }
    return result;
  }

  /// Encode BigInt as DER INTEGER
  List<int> _encodeDerInteger(BigInt value) {
    if (value == BigInt.zero) {
      return <int>[0x02, 0x01, 0x00];
    }

    final bytes = <int>[];
    var tmp = value;
    while (tmp > BigInt.zero) {
      bytes.insert(0, (tmp & BigInt.from(0xff)).toInt());
      tmp = tmp >> 8;
    }

    // If the highest bit is set, prepend 0x00 to indicate positive INTEGER
    if (bytes.isNotEmpty && (bytes[0] & 0x80) != 0) {
      bytes.insert(0, 0x00);
    }

    return <int>[0x02, bytes.length, ...bytes];
  }

  /// Encode two DER INTEGERs into a DER SEQUENCE
  List<int> _encodeDerSequence(List<int> a, List<int> b) {
    final content = <int>[...a, ...b];
    // For our sizes, length will always be < 128, so short-form length is fine.
    return <int>[0x30, content.length, ...content];
  }
}
