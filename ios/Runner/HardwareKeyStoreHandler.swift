import Foundation
import Flutter
import Security

/**
 * Hardware-backed Key Store Handler for iOS
 * 
 * Uses iOS Secure Enclave to store cryptographic keys in hardware security module.
 * Keys never leave the hardware and cannot be extracted even with jailbreak.
 */
@objc class HardwareKeyStoreHandler: NSObject, FlutterPlugin {
    private static let CHANNEL_NAME = "com.rs4it.king_abdulaziz_center_survey_app/hardware_keystore"
    private static let KEY_TAG = "com.rs4it.king_abdulaziz_center_survey_app.device_bound_key"
    private static let DEVICE_ID_KEY = "com.rs4it.king_abdulaziz_center_survey_app.device_id"
    private static let KEY_ID_KEY = "com.rs4it.king_abdulaziz_center_survey_app.device_bound_key_id"
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: CHANNEL_NAME,
            binaryMessenger: registrar.messenger()
        )
        let instance = HardwareKeyStoreHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPublicKey":
            getPublicKey(result: result)
        case "hasKey":
            hasKey(result: result)
        case "generateKeyPair":
            if let args = call.arguments as? [String: Any],
               let challenge = args["challenge"] as? String {
                generateKeyPair(challenge: challenge, result: result)
            } else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "Challenge parameter is required",
                    details: nil
                ))
            }
        case "signPayload":
            if let args = call.arguments as? [String: Any],
               let payload = args["payload"] as? String {
                signPayload(payload: payload, result: result)
            } else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "Payload parameter is required",
                    details: nil
                ))
            }
        case "deleteKey":
            deleteKey(result: result)
        case "saveDeviceId":
            if let args = call.arguments as? [String: Any],
               let deviceId = args["deviceId"] as? Int {
                saveDeviceId(deviceId: deviceId, result: result)
            } else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "DeviceId parameter is required",
                    details: nil
                ))
            }
        case "getDeviceId":
            getDeviceId(result: result)
        case "deleteDeviceId":
            deleteDeviceId(result: result)
        case "saveKeyId":
            if let args = call.arguments as? [String: Any],
               let keyId = args["keyId"] as? String {
                saveKeyId(keyId: keyId, result: result)
            } else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "KeyId parameter is required",
                    details: nil
                ))
            }
        case "getKeyId":
            getKeyId(result: result)
        case "deleteKeyId":
            deleteKeyId(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /**
     * Generate a new ECDSA key pair in Secure Enclave with attestation
     * 
     * [challenge] - Challenge string from backend for attestation
     * Returns: Map containing 'publicKey', 'signature', and 'certificateChain'
     * Note: iOS attestation is complex (CBOR), simplified version returns key/signature
     */
    private func generateKeyPair(challenge: String, result: @escaping FlutterResult) {
        
        // Delete existing key if present
        deleteKeyInternal()
        
        let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage, .biometryAny], // Require biometric for signing
            nil
        )
        
        guard let accessControl = accessControl else {
            result(FlutterError(
                code: "KEYSTORE_ERROR",
                message: "Failed to create access control",
                details: nil
            ))
            return
        }
        
        let privateKeyParams: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: Self.KEY_TAG.data(using: .utf8)!,
            kSecAttrAccessControl as String: accessControl,
        ]
        
        // Use Secure Enclave token (kSecAttrTokenIDSecureEnclave)
        let parameters: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256, // P-256 curve
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave, // Use Secure Enclave
            kSecPrivateKeyAttrs as String: privateKeyParams,
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(parameters as CFDictionary, &error) else {
            let errorMessage = error?.takeRetainedValue().localizedDescription ?? "Unknown error"
            result(FlutterError(
                code: "KEYSTORE_ERROR",
                message: "Failed to generate key: \(errorMessage)",
                details: nil
            ))
            return
        }
        
        // Get public key
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            result(FlutterError(
                code: "KEYSTORE_ERROR",
                message: "Failed to get public key",
                details: nil
            ))
            return
        }
        
        // Export public key in SPKI format
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            let errorMessage = error?.takeRetainedValue().localizedDescription ?? "Unknown error"
            result(FlutterError(
                code: "KEYSTORE_ERROR",
                message: "Failed to export public key: \(errorMessage)",
                details: nil
            ))
            return
        }
        
        // Convert to SPKI format (X.509 SubjectPublicKeyInfo)
        let spkiData = encodeECPublicKeyToSPKI(publicKeyData: publicKeyData)
        let base64PublicKey = spkiData.base64EncodedString()
        
        // Sign the challenge using the new private key (Proof of Possession)
        let challengeData = challenge.data(using: .utf8)!
        guard let challengeSignature = SecKeyCreateSignature(
            privateKey,
            .ecdsaSignatureMessageX962SHA256,
            challengeData as CFData,
            &error
        ) as Data? else {
            let errorMessage = error?.takeRetainedValue().localizedDescription ?? "Unknown error"
            result(FlutterError(
                code: "KEYSTORE_ERROR",
                message: "Failed to sign challenge: \(errorMessage)",
                details: nil
            ))
            return
        }
        
        // iOS Secure Enclave returns DER-encoded signature
        // Backend (Node.js crypto) expects DER format for verification
        // Return DER-encoded signature as base64
        let base64Signature = challengeSignature.base64EncodedString()
        
        // Return public key, signature, and empty certificate chain (iOS doesn't provide attestation easily)
        let response: [String: Any] = [
            "publicKey": base64PublicKey,
            "signature": base64Signature,
            "certificateChain": [] as [String] // iOS attestation requires DCAppAttestService (complex)
        ]
        
        result(response)
    }
    
    /**
     * Encode EC public key to SPKI (SubjectPublicKeyInfo) format
     * The raw key from Secure Enclave is in uncompressed format (0x04 + x + y)
     */
    private func encodeECPublicKeyToSPKI(publicKeyData: Data) -> Data {
        // Raw key format: 0x04 (uncompressed) + 32 bytes x + 32 bytes y = 65 bytes
        guard publicKeyData.count == 65, publicKeyData[0] == 0x04 else {
            // If already in SPKI format, return as is
            return publicKeyData
        }
        
        // Build SPKI structure manually
        // SEQUENCE {
        //   SEQUENCE {
        //     OBJECT IDENTIFIER 1.2.840.10045.2.1 (id-ecPublicKey)
        //     OBJECT IDENTIFIER 1.2.840.10045.3.1.7 (secp256r1)
        //   }
        //   BIT STRING (uncompressedPoint)
        // }
        
        // id-ecPublicKey OID: 1.2.840.10045.2.1
        let algorithmId: [UInt8] = [0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01]
        
        // secp256r1 OID: 1.2.840.10045.3.1.7
        let namedCurve: [UInt8] = [0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07]
        
        // SEQUENCE (algorithm) - length is 15 (7 + 8)
        let algorithmSeqContent = Data(algorithmId) + Data(namedCurve)
        let algorithmSeq = Data([0x30, 0x0F]) + algorithmSeqContent
        
        // BIT STRING for public key: 0 unused bits + uncompressed point (65 bytes)
        // Length is 66 (1 + 65) = 0x42
        let bitStringContent = Data([0x00]) + publicKeyData
        let bitString = Data([0x03, 0x42]) + bitStringContent
        
        // SPKI SEQUENCE - length calculation:
        // algorithmSeq: 2 (tag + length) + 15 (content) = 17 bytes
        // bitString: 2 (tag + length) + 66 (content) = 68 bytes
        // Total: 17 + 68 = 85 bytes = 0x55
        let spkiContent = algorithmSeq + bitString
        let spki = Data([0x30, 0x55]) + spkiContent
        
        return spki
    }
    
    /**
     * Check if key exists in Secure Enclave
     */
    private func hasKey(result: @escaping FlutterResult) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: Self.KEY_TAG.data(using: .utf8)!,
            kSecReturnRef as String: true,
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        result(status == errSecSuccess)
    }
    
    /**
     * Get public key from Secure Enclave
     */
    private func getPublicKey(result: @escaping FlutterResult) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: Self.KEY_TAG.data(using: .utf8)!,
            kSecReturnRef as String: true,
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let privateKey = item as! SecKey? else {
            result(nil)
            return
        }
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            result(nil)
            return
        }
        
        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            result(nil)
            return
        }
        
        let spkiData = encodeECPublicKeyToSPKI(publicKeyData: publicKeyData)
        let base64PublicKey = spkiData.base64EncodedString()
        result(base64PublicKey)
    }
    
    /**
     * Sign data using the private key stored in Secure Enclave
     * The private key never leaves the hardware
     * 
     * Algorithm: ECDSA with SHA-256 (ES256)
     * - Automatically hashes the input data with SHA-256
     * - Signs the hash using ECDSA with P-256 curve
     * - Returns DER-encoded signature (SEQUENCE of two INTEGERs: r, s)
     * 
     * Note: iOS Secure Enclave returns DER-encoded signature
     * which is the standard format expected by most backends
     * 
     * [payload] - Payload string to sign (e.g., "challenge|keyId|timestamp")
     */
    private func signPayload(payload: String, result: @escaping FlutterResult) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: Self.KEY_TAG.data(using: .utf8)!,
            kSecReturnRef as String: true,
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let privateKey = item as! SecKey? else {
            result(FlutterError(
                code: "KEYSTORE_ERROR",
                message: "Key not found in Secure Enclave",
                details: nil
            ))
            return
        }
        
        // Convert payload string to UTF-8 bytes
        guard let payloadData = payload.data(using: .utf8) else {
            result(FlutterError(
                code: "INVALID_ARGUMENT",
                message: "Failed to encode payload to UTF-8",
                details: nil
            ))
            return
        }
        
        // Sign using Secure Enclave (requires biometric if configured)
        // .ecdsaSignatureMessageX962SHA256 automatically hashes the data with SHA-256
        // So we pass the raw data, not the hash
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .ecdsaSignatureMessageX962SHA256,
            payloadData as CFData,
            &error
        ) as Data? else {
            let errorMessage = error?.takeRetainedValue().localizedDescription ?? "Unknown error"
            result(FlutterError(
                code: "KEYSTORE_ERROR",
                message: "Failed to sign: \(errorMessage)",
                details: nil
            ))
            return
        }
        
        // iOS Secure Enclave returns DER-encoded signature
        // Backend (Node.js crypto) expects DER format for verification
        // Return DER-encoded signature as base64
        let base64Signature = signature.base64EncodedString()
        result(base64Signature)
    }
    
    /**
     * Delete key from Secure Enclave
     */
    private func deleteKey(result: @escaping FlutterResult) {
        deleteKeyInternal()
        result(nil)
    }
    
    private func deleteKeyInternal() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: Self.KEY_TAG.data(using: .utf8)!,
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    /**
     * Save device ID to iOS Keychain (hardware-backed secure storage)
     * Uses Keychain which is protected by Secure Enclave on supported devices
     */
    private func saveDeviceId(deviceId: Int, result: @escaping FlutterResult) {
        let deviceIdString = String(deviceId)
        guard let deviceIdData = deviceIdString.data(using: .utf8) else {
            result(FlutterError(
                code: "KEYSTORE_ERROR",
                message: "Failed to encode device ID",
                details: nil
            ))
            return
        }
        
        // Delete existing device ID if present
        deleteDeviceIdInternal()
        
        // Create access control for Keychain item
        // kSecAttrAccessibleWhenUnlockedThisDeviceOnly ensures data is only accessible
        // when device is unlocked and only on this device (not synced to iCloud)
        let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [],
            nil
        )
        
        guard let accessControl = accessControl else {
            result(FlutterError(
                code: "KEYSTORE_ERROR",
                message: "Failed to create access control",
                details: nil
            ))
            return
        }
        
        // Keychain query for saving device ID
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.DEVICE_ID_KEY,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.rs4it.king_abdulaziz_center_survey_app",
            kSecValueData as String: deviceIdData,
            kSecAttrAccessControl as String: accessControl,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            result(nil)
        } else {
            result(FlutterError(
                code: "KEYSTORE_ERROR",
                message: "Failed to save device ID to Keychain: \(status)",
                details: nil
            ))
        }
    }
    
    /**
     * Get device ID from iOS Keychain (hardware-backed secure storage)
     * Returns null if device ID is not found
     */
    private func getDeviceId(result: @escaping FlutterResult) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.DEVICE_ID_KEY,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.rs4it.king_abdulaziz_center_survey_app",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let deviceIdString = String(data: data, encoding: .utf8) else {
            result(nil)
            return
        }
        
        result(deviceIdString)
    }
    
    /**
     * Delete device ID from iOS Keychain
     */
    private func deleteDeviceId(result: @escaping FlutterResult) {
        deleteDeviceIdInternal()
        result(nil)
    }
    
    private func deleteDeviceIdInternal() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.DEVICE_ID_KEY,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.rs4it.king_abdulaziz_center_survey_app",
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    /**
     * Save key ID to iOS Keychain (hardware-backed secure storage)
     * Uses Keychain which is protected by Secure Enclave on supported devices
     */
    private func saveKeyId(keyId: String, result: @escaping FlutterResult) {
        guard let keyIdData = keyId.data(using: .utf8) else {
            result(FlutterError(
                code: "KEYSTORE_ERROR",
                message: "Failed to encode key ID",
                details: nil
            ))
            return
        }
        
        // Delete existing key ID if present
        deleteKeyIdInternal()
        
        // Create access control for Keychain item
        // kSecAttrAccessibleWhenUnlockedThisDeviceOnly ensures data is only accessible
        // when device is unlocked and only on this device (not synced to iCloud)
        let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [],
            nil
        )
        
        guard let accessControl = accessControl else {
            result(FlutterError(
                code: "KEYSTORE_ERROR",
                message: "Failed to create access control",
                details: nil
            ))
            return
        }
        
        // Keychain query for saving key ID
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.KEY_ID_KEY,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.rs4it.king_abdulaziz_center_survey_app",
            kSecValueData as String: keyIdData,
            kSecAttrAccessControl as String: accessControl,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            result(nil)
        } else {
            result(FlutterError(
                code: "KEYSTORE_ERROR",
                message: "Failed to save key ID to Keychain: \(status)",
                details: nil
            ))
        }
    }
    
    /**
     * Get key ID from iOS Keychain (hardware-backed secure storage)
     * Returns null if key ID is not found
     */
    private func getKeyId(result: @escaping FlutterResult) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.KEY_ID_KEY,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.rs4it.king_abdulaziz_center_survey_app",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let keyIdString = String(data: data, encoding: .utf8) else {
            result(nil)
            return
        }
        
        result(keyIdString)
    }
    
    /**
     * Delete key ID from iOS Keychain
     */
    private func deleteKeyId(result: @escaping FlutterResult) {
        deleteKeyIdInternal()
        result(nil)
    }
    
    private func deleteKeyIdInternal() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.KEY_ID_KEY,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.rs4it.king_abdulaziz_center_survey_app",
        ]
        SecItemDelete(query as CFDictionary)
    }
}

