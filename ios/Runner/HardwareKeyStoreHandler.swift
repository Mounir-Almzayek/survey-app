import Foundation
import Flutter
import Security
import UIKit

/**
 * Hardware-backed Key Store Handler for iOS
 * 
 * Uses Secure Enclave for hardware-backed keys.
 */
@objc class HardwareKeyStoreHandler: NSObject, FlutterPlugin {
    private static let CHANNEL_NAME = "com.rs4it.king_abdulaziz_center_survey_app/hardware_keystore"
    private static let KEY_TAG = "com.rs4it.survey.device_key"
    
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
        case "generateKeyPair":
            guard let args = call.arguments as? [String: Any],
                  let challenge = args["challenge"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Challenge required", details: nil))
                return
            }
            generateKeyPair(challenge: challenge, result: result)
            
        case "signPayload":
            guard let args = call.arguments as? [String: Any],
                  let payload = args["payload"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Payload required", details: nil))
                return
            }
            signPayload(payload: payload, result: result)
            
        case "hasKey":
            result(getPrivateKeyReference() != nil)
            
        case "getPublicKey":
            if let key = getPrivateKeyReference(),
               let publicKey = SecKeyCopyPublicKey(key),
               let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) {
                let spkiData = encodeECPublicKeyToSPKI(publicKeyData: publicKeyData as Data)
                result(spkiData.base64EncodedString())
            } else {
                result(nil)
            }
            
        case "deleteKey":
            deleteKey()
            result(nil)
            
        case "getKeyId":
            if getPrivateKeyReference() != nil {
                result(UIDevice.current.identifierForVendor?.uuidString ?? Self.KEY_TAG)
            } else {
                result(nil)
            }
            
        case "getDeviceId", "getHardwareId":
            result(UIDevice.current.identifierForVendor?.uuidString ?? "unknown_vendor_id")
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func generateKeyPair(challenge: String, result: @escaping FlutterResult) {
        // 1. Delete old key
        deleteKey()
        
        // 2. Access control (Secure Enclave)
        var error: Unmanaged<CFError>?
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            .privateKeyUsage,
            &error
        ) else {
            result(FlutterError(code: "KEY_ERROR", message: "Access control creation failed", details: error?.takeRetainedValue().localizedDescription))
            return
        }
        
        // 3. Key attributes
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: Self.KEY_TAG.data(using: .utf8)!,
                kSecAttrAccessControl as String: accessControl
            ]
        ]
        
        // 4. Create Key
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            result(FlutterError(code: "KEY_ERROR", message: "Key creation failed", details: error?.takeRetainedValue().localizedDescription))
            return
        }
        
        // 5. Get Public Key and sign challenge
        guard let publicKey = SecKeyCopyPublicKey(privateKey),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) else {
            result(FlutterError(code: "KEY_ERROR", message: "Public key extraction failed", details: error?.takeRetainedValue().localizedDescription))
            return
        }
        
        let challengeData = challenge.data(using: .utf8)!
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .ecdsaSignatureMessageX962SHA256,
            challengeData as CFData,
            &error
        ) else {
            result(FlutterError(code: "CRYPTO_ERROR", message: "Challenge signing failed", details: error?.takeRetainedValue().localizedDescription))
            return
        }
        
        let spkiData = encodeECPublicKeyToSPKI(publicKeyData: publicKeyData as Data)
        
        result([
            "publicKey": spkiData.base64EncodedString(),
            "signature": (signature as Data).base64EncodedString(),
            "keyId": Self.KEY_TAG,
            "certificateChain": [] as [String]
        ])
    }
    
    private func signPayload(payload: String, result: @escaping FlutterResult) {
        guard let privateKey = getPrivateKeyReference() else {
            result(FlutterError(code: "KEY_NOT_FOUND", message: "No hardware key found", details: nil))
            return
        }
        
        var error: Unmanaged<CFError>?
        let payloadData = payload.data(using: .utf8)!
        
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .ecdsaSignatureMessageX962SHA256,
            payloadData as CFData,
            &error
        ) else {
            result(FlutterError(code: "CRYPTO_ERROR", message: "Signing failed", details: error?.takeRetainedValue().localizedDescription))
            return
        }
        
        result((signature as Data).base64EncodedString())
    }
    
    private func getPrivateKeyReference() -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: Self.KEY_TAG.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        return (item as! SecKey)
    }
    
    private func deleteKey() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: Self.KEY_TAG.data(using: .utf8)!
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    private func encodeECPublicKeyToSPKI(publicKeyData: Data) -> Data {
        // CryptoKit/SecureEnclave returns 0x04 + X + Y (65 bytes)
        let algorithmId: [UInt8] = [0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01]
        let namedCurve: [UInt8] = [0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07]
        let algorithmSeq = Data([0x30, 0x13, 0x30, 0x0F]) + Data(algorithmId) + Data(namedCurve)
        let bitString = Data([0x03, 0x42, 0x00]) + publicKeyData
        let totalContent = algorithmSeq + bitString
        return Data([0x30, UInt8(totalContent.count)]) + totalContent
    }
}
