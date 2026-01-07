# Device Binding Implementation Guide (Native Hardware)

## 1. Dart Side (`DeviceBoundKeyService.dart`)

Replace `pointycastle` logic with `MethodChannel`.

```dart
class DeviceBoundKeyService {
  static const _channel = MethodChannel('com.rs4it.survey/device_key');

  // 1. Generate Key (Pass challenge for attestation)
  Future<Map<String, dynamic>> generateKeyPair(String challenge) async {
    final Map result = await _channel.invokeMethod('generateKeyPair', {
      'challenge': challenge
    });
    return {
      'publicKey': result['publicKey'],
      'keyId': result['keyId'],
      'signature': result['signature'], // <--- Proof of Possession
      'attestation': {
         'certificateChain': result['certificateChain'] // List<String>
      }
    };
  }

  // 2. Sign Payload (Hardware backed)
  Future<String> signPayload(String payload) async {
    final String signature = await _channel.invokeMethod('signPayload', {
      'payload': payload, // Backend expects "challenge|keyId|timestamp"
    });
    return signature;
  }
}
```

## 2. Android (`MainActivity.java/kt`)

Use `AndroidKeyStore` with `setIsStrongBoxBacked(true)`.

### Key Generation

1.  Get `challenge` string from arguments.
2.  `KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore")`.
3.  `KeyGenParameterSpec.Builder(alias, PURPOSE_SIGN | PURPOSE_VERIFY)`.
    - `.setAttestationChallenge(challenge.getBytes())`
    - `.setIsStrongBoxBacked(true)` (Fall back to false if unavailable).
4.  Generate KeyPair.
5.  **Sign Challenge**: Use the new Private Key to sign the `challenge` bytes.
6.  Get Certificate Chain: `keyStore.getCertificateChain(alias)`.
7.  Return: Public Key (Base64) + Chain (Base64 list) + Signature (Base64).

### Signing

1.  Get `payload` string.
2.  `KeyStore.getEntry(alias)`.
3.  `Signature.getInstance("SHA256withECDSA")`.
4.  `signature.initSign(privateKey)`.
5.  `signature.update(payload.getBytes())`.
6.  Return: Base64 Signature.

## 3. iOS (`AppDelegate.swift`)

Use `Secure Enclave` (`kSecAttrTokenIDSecureEnclave`).
_Note: Full remote attestation requires `DCAppAttestService`._

### Key Generation

1.  Attributes:

    - `kSecAttrTokenID`: `kSecAttrTokenIDSecureEnclave`
    - `kSecAttrKeyType`: `kSecAttrKeyTypeECSECPrimeRandom`
    - `kSecAttrKeySizeInBits`: 256
    - `kSecPrivateKeyUsage`: `.sign`

2.  `SecKeyCreateRandomKey`.
3.  **Sign Challenge**: Use `SecKeyCreateSignature` with the new Private Key to sign the `challenge`.
4.  Return: Public Key (Base64) + Signature (Base64).
    - _iOS Attestation is complex (CBOR); simplified version just returns key/signature._

### Signing

1.  `SecItemCopyMatching` to find Private Key reference.
2.  `SecKeyCreateSignature` with algorithm `kSecKeyAlgorithmECDSASignatureMessageX962SHA256`.
3.  Return: Base64 Signature.
