package com.rs4it.king_abdulaziz_center_survey_app

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import java.security.spec.ECGenParameterSpec

/**
 * Hardware-backed Key Store Handler for Android
 * 
 * Uses Android Keystore to store cryptographic keys in hardware security module.
 * Keys never leave the hardware and cannot be extracted even with root access.
 */
class HardwareKeyStoreHandler(private val context: Context) : MethodChannel.MethodCallHandler {
    
    companion object {
        private const val KEYSTORE_PROVIDER = "AndroidKeyStore"
        private const val KEY_ALIAS = "device_bound_key"
        private const val KEY_ALGORITHM = "EC"
        private const val CURVE_NAME = "secp256r1" // P-256 curve for ES256
        private const val SIGNATURE_ALGORITHM = "SHA256withECDSA"
    }
    
    private val keyStore: KeyStore = KeyStore.getInstance(KEYSTORE_PROVIDER).apply {
        load(null)
    }
    
    /**
     * Generate a new ECDSA key pair in Android Keystore with attestation
     * 
     * [challenge] - Challenge string from backend for attestation
     * Returns: Map containing 'publicKey', 'signature', and 'certificateChain'
     */
    private fun generateKeyPair(challenge: String): Map<String, Any> {
        // Delete existing key if present
        if (keyStore.containsAlias(KEY_ALIAS)) {
            keyStore.deleteEntry(KEY_ALIAS)
        }
        
        val keyPairGenerator = KeyPairGenerator.getInstance(KEY_ALGORITHM, KEYSTORE_PROVIDER)
        
        val challengeBytes = challenge.toByteArray(Charsets.UTF_8)
        
        // Try StrongBox first (hardware security module), fall back to regular Keystore
        var keyPair: KeyPair? = null
        var useStrongBox = false
        
        // Try with StrongBox if available (Android P+)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
            try {
                val strongBoxSpec = KeyGenParameterSpec.Builder(
                    KEY_ALIAS,
                    KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
                )
                    .setAlgorithmParameterSpec(ECGenParameterSpec(CURVE_NAME))
                    .setDigests(KeyProperties.DIGEST_SHA256)
                    .setUserAuthenticationRequired(false)
                    .setAttestationChallenge(challengeBytes)
                    .setIsStrongBoxBacked(true) // Try StrongBox
                    .build()
                
                keyPairGenerator.initialize(strongBoxSpec)
                keyPair = keyPairGenerator.generateKeyPair()
                useStrongBox = true
            } catch (e: Exception) {
                // StrongBox not available or failed, will try regular Keystore below
                // Delete the key if it was partially created
                try {
                    if (keyStore.containsAlias(KEY_ALIAS)) {
                        keyStore.deleteEntry(KEY_ALIAS)
                    }
                } catch (deleteError: Exception) {
                    // Ignore delete errors
                }
            }
        }
        
        // If StrongBox failed or not available, use regular Keystore
        if (keyPair == null) {
            val regularSpec = KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
            )
                .setAlgorithmParameterSpec(ECGenParameterSpec(CURVE_NAME))
                .setDigests(KeyProperties.DIGEST_SHA256)
                .setUserAuthenticationRequired(false)
                .setAttestationChallenge(challengeBytes)
                // Don't set setIsStrongBoxBacked - use regular Keystore
                .build()
            
            keyPairGenerator.initialize(regularSpec)
            keyPair = keyPairGenerator.generateKeyPair()
        }
        
        if (keyPair == null) {
            throw Exception("Failed to generate key pair")
        }
        
        // Extract and encode public key in SPKI format
        val publicKeyBase64 = encodePublicKeyToSPKI(keyPair)
        
        // Sign the challenge using the new private key (Proof of Possession)
        // challengeBytes was already defined above, reuse it
        val signatureBase64 = signData(challengeBytes)
        
        // Get certificate chain for attestation (Android only)
        val certificateChain = mutableListOf<String>()
        try {
            val entry = keyStore.getEntry(KEY_ALIAS, null) as? KeyStore.PrivateKeyEntry
            val chain = entry?.certificateChain
            if (chain != null) {
                for (cert in chain) {
                    val certBytes = cert.encoded
                    certificateChain.add(Base64.encodeToString(certBytes, Base64.NO_WRAP))
                }
            }
        } catch (e: Exception) {
            // Certificate chain not available, continue without it
        }
        
        return mapOf(
            "publicKey" to publicKeyBase64,
            "signature" to signatureBase64,
            "certificateChain" to certificateChain
        )
    }
    
    /**
     * Encode ECDSA public key to SPKI (SubjectPublicKeyInfo) format
     * 
     * Android Keystore returns public keys already in SPKI format (X.509 SubjectPublicKeyInfo).
     * This is the standard format expected by the backend.
     * 
     * SPKI format structure:
     * SEQUENCE {
     *   SEQUENCE {
     *     OBJECT IDENTIFIER 1.2.840.10045.2.1 (id-ecPublicKey)
     *     OBJECT IDENTIFIER 1.2.840.10045.3.1.7 (secp256r1)
     *   }
     *   BIT STRING (uncompressedPoint: 0x04 + x + y)
     * }
     */
    private fun encodePublicKeyToSPKI(keyPair: KeyPair): String {
        val publicKey = keyPair.public
        // Android Keystore's publicKey.encoded is already in SPKI format
        // This matches the format we manually build in iOS
        val encoded = publicKey.encoded
        return Base64.encodeToString(encoded, Base64.NO_WRAP)
    }
    
    /**
     * Check if key exists in Keystore
     */
    private fun hasKey(): Boolean {
        return keyStore.containsAlias(KEY_ALIAS)
    }
    
    /**
     * Get public key from Keystore
     * Returns: Base64 encoded public key in SPKI format (same format as generateKeyPair)
     * 
     * Note: We use certificate.publicKey which should give the same SPKI format
     * as keyPair.public.encoded from generateKeyPair
     */
    private fun getPublicKey(): String? {
        if (!hasKey()) {
            return null
        }
        
        val entry = keyStore.getEntry(KEY_ALIAS, null) as? KeyStore.PrivateKeyEntry
        val publicKey = entry?.certificate?.publicKey ?: return null
        
        // Android Keystore's certificate.publicKey.encoded is in SPKI format
        // This should match the format from generateKeyPair (keyPair.public.encoded)
        val encoded = publicKey.encoded
        return Base64.encodeToString(encoded, Base64.NO_WRAP)
    }
    
    /**
     * Sign data using the private key stored in Keystore
     * The private key never leaves the hardware
     * 
     * Algorithm: SHA256withECDSA (ES256)
     * - Automatically hashes the input data with SHA-256
     * - Signs the hash using ECDSA with P-256 curve
     * - Returns DER-encoded signature (SEQUENCE of two INTEGERs: r, s)
     * 
     * Note: Android Keystore's Signature.sign() returns DER-encoded signature
     * which is the standard format expected by most backends
     */
    private fun signData(data: ByteArray): String {
        if (!hasKey()) {
            throw Exception("Key not found in Keystore")
        }
        
        val entry = keyStore.getEntry(KEY_ALIAS, null) as? KeyStore.PrivateKeyEntry
        val privateKey = entry?.privateKey ?: throw Exception("Private key not found")
        
        // SHA256withECDSA automatically hashes the data with SHA-256
        // So we pass the raw data bytes, not the hash
        val signature = Signature.getInstance(SIGNATURE_ALGORITHM)
        signature.initSign(privateKey)
        signature.update(data)
        val signatureBytes = signature.sign()
        
        // Android Keystore returns DER-encoded signature
        // Backend (Node.js crypto) expects DER format for verification
        // Return DER-encoded signature as base64
        return Base64.encodeToString(signatureBytes, Base64.NO_WRAP)
    }
    
    /**
     * Delete key from Keystore
     */
    private fun deleteKey() {
        if (keyStore.containsAlias(KEY_ALIAS)) {
            keyStore.deleteEntry(KEY_ALIAS)
        }
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "getPublicKey" -> {
                    val publicKey = getPublicKey()
                    result.success(publicKey)
                }
                "hasKey" -> {
                    result.success(hasKey())
                }
                "generateKeyPair" -> {
                    val challenge = call.argument<String>("challenge")
                    if (challenge == null) {
                        result.error("INVALID_ARGUMENT", "Challenge parameter is required", null)
                        return
                    }
                    val resultMap = generateKeyPair(challenge)
                    result.success(resultMap)
                }
                "signPayload" -> {
                    val payload = call.argument<String>("payload")
                    if (payload == null) {
                        result.error("INVALID_ARGUMENT", "Payload parameter is required", null)
                        return
                    }
                    // Sign the payload string directly (UTF-8 bytes)
                    // SHA256withECDSA will hash them automatically
                    val payloadBytes = payload.toByteArray(Charsets.UTF_8)
                    val signature = signData(payloadBytes)
                    result.success(signature)
                }
                "deleteKey" -> {
                    deleteKey()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            result.error("KEYSTORE_ERROR", e.message, e.stackTraceToString())
        }
    }
}

