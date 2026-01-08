package com.rs4it.king_abdulaziz_center_survey_app

import android.content.Context
import android.os.Environment
import android.provider.Settings
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.nio.charset.StandardCharsets
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.MessageDigest
import java.security.Signature
import java.security.spec.ECGenParameterSpec
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

/**
 * Hardware-backed Key Store Handler for Android
 *
 * Uses Android Keystore to store cryptographic keys in hardware security module. Keys never leave
 * the hardware and cannot be extracted even with root access.
 */
class HardwareKeyStoreHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val KEYSTORE_PROVIDER = "AndroidKeyStore"
        private const val KEY_ALIAS = "device_bound_key"
        private const val KEY_ALGORITHM = "EC"
        private const val CURVE_NAME = "secp256r1" // P-256 curve for ES256
        private const val SIGNATURE_ALGORITHM = "SHA256withECDSA"

        // Device ID storage constants
        private const val DEVICE_ID_PREFS_NAME = "hardware_device_id_prefs"
        private const val DEVICE_ID_KEY = "device_id"

        // Key ID storage constants
        private const val KEY_ID_KEY = "device_bound_key_id"

        // Assignment ID storage constants
        private const val ASSIGNMENT_ID_KEY = "assignment_id"
    }

    private val keyStore: KeyStore = KeyStore.getInstance(KEYSTORE_PROVIDER).apply { load(null) }

    /**
     * Get Android ID (persists across app uninstalls) This is a unique identifier for the device
     * that remains constant even after app uninstall/reinstall
     */
    private fun getAndroidId(): String {
        return Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
                ?: "unknown_android_id"
    }

    /**
     * Get persistent storage directory that survives app uninstall
     * Uses a public directory (Documents) to store hidden identity data
     * This directory remains even after app uninstall on most devices
     */
    private fun getPersistentStorageDir(): File {
        val androidId = getAndroidId()
        // Use Documents directory as a more stable location for persistence
        val baseDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
        val persistentDir = File(baseDir, ".kac_survey_identity_$androidId")
        
        if (!persistentDir.exists()) {
            try {
                persistentDir.mkdirs()
            } catch (e: Exception) {
                // If mkdirs fails, fallback to internal storage (won't survive uninstall but won't crash)
                return context.filesDir
            }
        }
        return if (persistentDir.exists() && persistentDir.canWrite()) persistentDir else context.filesDir
    }

    /**
     * Get EncryptedSharedPreferences instance for storing device ID in hardware-backed storage Uses
     * Android Keystore to encrypt the SharedPreferences data Uses Android ID as part of the
     * preferences name to persist across uninstalls
     */
    private fun getEncryptedPrefs(): android.content.SharedPreferences {
        val androidId = getAndroidId()
        // Use Android ID in preferences name to persist across uninstalls
        val prefsName = "${DEVICE_ID_PREFS_NAME}_$androidId"

        val masterKey =
                MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build()

        return EncryptedSharedPreferences.create(
                context,
                prefsName,
                masterKey,
                EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    /**
     * Save data to persistent external storage (survives app uninstall) Uses Android ID-based
     * encryption for security
     */
    private fun saveToPersistentStorage(key: String, value: String) {
        try {
            val storageDir = getPersistentStorageDir()

            // Ensure directory exists and is writable
            if (!storageDir.exists()) {
                val created = storageDir.mkdirs()
                if (!created && !storageDir.exists()) {
                    throw Exception(
                            "Failed to create storage directory: ${storageDir.absolutePath}"
                    )
                }
            }

            if (!storageDir.canWrite()) {
                throw Exception("Storage directory is not writable: ${storageDir.absolutePath}")
            }

            val file = File(storageDir, key)

            // Encrypt data using Android ID as part of encryption key
            val androidId = getAndroidId()
            val encryptedData = encryptData(value, androidId)

            FileOutputStream(file).use { fos -> fos.write(encryptedData.toByteArray()) }
        } catch (e: Exception) {
            throw Exception("Failed to save to persistent storage: ${e.message}")
        }
    }

    /** Read data from persistent external storage */
    private fun readFromPersistentStorage(key: String): String? {
        return try {
            val storageDir = getPersistentStorageDir()
            val file = File(storageDir, key)

            if (!file.exists()) {
                return null
            }

            val encryptedData =
                    FileInputStream(file).use { fis -> fis.readBytes().toString(Charsets.UTF_8) }

            // Decrypt data using Android ID
            val androidId = getAndroidId()
            decryptData(encryptedData, androidId)
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Encrypt data using AES-GCM with Android ID-derived key Uses Android ID to derive encryption
     * key for persistent storage
     */
    private fun encryptData(data: String, androidId: String): String {
        try {
            // Derive 256-bit key from Android ID using SHA-256
            val keyBytes =
                    MessageDigest.getInstance("SHA-256")
                            .digest(androidId.toByteArray(StandardCharsets.UTF_8))
            val secretKey = SecretKeySpec(keyBytes, "AES")

            // Initialize cipher with AES-GCM
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            cipher.init(Cipher.ENCRYPT_MODE, secretKey)

            // Encrypt data
            val encryptedBytes = cipher.doFinal(data.toByteArray(StandardCharsets.UTF_8))
            val iv = cipher.iv

            // Combine IV and encrypted data
            val combined = ByteArray(iv.size + encryptedBytes.size)
            System.arraycopy(iv, 0, combined, 0, iv.size)
            System.arraycopy(encryptedBytes, 0, combined, iv.size, encryptedBytes.size)

            return Base64.encodeToString(combined, Base64.NO_WRAP)
        } catch (e: Exception) {
            throw Exception("Failed to encrypt data: ${e.message}")
        }
    }

    /** Decrypt data using AES-GCM with Android ID-derived key */
    private fun decryptData(encryptedData: String, androidId: String): String {
        try {
            // Derive 256-bit key from Android ID using SHA-256
            val keyBytes =
                    MessageDigest.getInstance("SHA-256")
                            .digest(androidId.toByteArray(StandardCharsets.UTF_8))
            val secretKey = SecretKeySpec(keyBytes, "AES")

            // Decode base64
            val combined = Base64.decode(encryptedData, Base64.NO_WRAP)

            // Extract IV (first 12 bytes for GCM)
            val iv = ByteArray(12)
            System.arraycopy(combined, 0, iv, 0, 12)

            // Extract encrypted data
            val encryptedBytes = ByteArray(combined.size - 12)
            System.arraycopy(combined, 12, encryptedBytes, 0, encryptedBytes.size)

            // Initialize cipher with AES-GCM
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            val gcmSpec = GCMParameterSpec(128, iv) // 128-bit authentication tag
            cipher.init(Cipher.DECRYPT_MODE, secretKey, gcmSpec)

            // Decrypt data
            val decryptedBytes = cipher.doFinal(encryptedBytes)
            return String(decryptedBytes, StandardCharsets.UTF_8)
        } catch (e: Exception) {
            throw Exception("Failed to decrypt data: ${e.message}")
        }
    }

    /**
     * Save device ID to persistent storage (survives app uninstall) First tries
     * EncryptedSharedPreferences, then falls back to persistent external storage
     */
    private fun saveDeviceId(deviceId: Int) {
        try {
            // Try EncryptedSharedPreferences first (for current session)
            val prefs = getEncryptedPrefs()
            prefs.edit().putString(DEVICE_ID_KEY, deviceId.toString()).apply()

            // Also try to save to persistent external storage (survives uninstall)
            // If this fails, we still have EncryptedSharedPreferences
            try {
                saveToPersistentStorage(DEVICE_ID_KEY, deviceId.toString())
            } catch (e: Exception) {
                // Log but don't fail - EncryptedSharedPreferences is sufficient
                android.util.Log.w(
                        "HardwareKeyStore",
                        "Failed to save to persistent storage, using EncryptedSharedPreferences only: ${e.message}"
                )
            }
        } catch (e: Exception) {
            throw Exception("Failed to save device ID to hardware storage: ${e.message}")
        }
    }

    /**
     * Get device ID from persistent storage First tries EncryptedSharedPreferences, then falls back
     * to persistent external storage This ensures data persists even after app uninstall If no
     * saved device ID exists, returns Android ID as fallback (always available)
     */
    private fun getDeviceId(): String? {
        return try {
            // Try EncryptedSharedPreferences first
            val prefs = getEncryptedPrefs()
            val deviceId = prefs.getString(DEVICE_ID_KEY, null)

            if (deviceId != null) {
                return deviceId
            }

            // Fall back to persistent external storage (for after uninstall/reinstall)
            val persistentDeviceId = readFromPersistentStorage(DEVICE_ID_KEY)
            if (persistentDeviceId != null) {
                return persistentDeviceId
            }

            // If no saved device ID exists, return Android ID as fallback
            // Android ID is always available and persists across app uninstalls
            return getAndroidId()
        } catch (e: Exception) {
            // If all else fails, return Android ID as fallback
            // This ensures we always return a device identifier
            try {
                return getAndroidId()
            } catch (fallbackError: Exception) {
                // Last resort: return a default value (should never happen)
                return "unknown_android_id"
            }
        }
    }

    /**
     * Delete device ID from hardware-backed encrypted storage Deletes from both
     * EncryptedSharedPreferences and persistent external storage
     */
    private fun deleteDeviceId() {
        try {
            // Delete from EncryptedSharedPreferences
            val prefs = getEncryptedPrefs()
            prefs.edit().remove(DEVICE_ID_KEY).apply()

            // Also delete from persistent external storage
            try {
                val storageDir = getPersistentStorageDir()
                val file = File(storageDir, DEVICE_ID_KEY)
                if (file.exists()) {
                    file.delete()
                }
            } catch (e: Exception) {
                // Ignore errors when deleting from external storage
            }
        } catch (e: Exception) {
            // Ignore errors when deleting
        }
    }

    /**
     * Save key ID to persistent storage (survives app uninstall) First tries
     * EncryptedSharedPreferences, then falls back to persistent external storage
     */
    private fun saveKeyId(keyId: String) {
        try {
            // Try EncryptedSharedPreferences first (for current session)
            val prefs = getEncryptedPrefs()
            prefs.edit().putString(KEY_ID_KEY, keyId).apply()

            // Also try to save to persistent external storage (survives uninstall)
            // If this fails, we still have EncryptedSharedPreferences
            try {
                saveToPersistentStorage(KEY_ID_KEY, keyId)
            } catch (e: Exception) {
                // Log but don't fail - EncryptedSharedPreferences is sufficient
                android.util.Log.w(
                        "HardwareKeyStore",
                        "Failed to save to persistent storage, using EncryptedSharedPreferences only: ${e.message}"
                )
            }
        } catch (e: Exception) {
            throw Exception("Failed to save key ID to hardware storage: ${e.message}")
        }
    }

    /**
     * Get key ID from persistent storage First tries EncryptedSharedPreferences, then falls back to
     * persistent external storage This ensures data persists even after app uninstall
     */
    private fun getKeyId(): String? {
        return try {
            // Try EncryptedSharedPreferences first
            val prefs = getEncryptedPrefs()
            val keyId = prefs.getString(KEY_ID_KEY, null)

            if (keyId != null) {
                return keyId
            }

            // Fall back to persistent external storage (for after uninstall/reinstall)
            readFromPersistentStorage(KEY_ID_KEY)
        } catch (e: Exception) {
            // Try persistent storage as fallback
            readFromPersistentStorage(KEY_ID_KEY)
        }
    }

    /**
     * Delete key ID from hardware-backed encrypted storage Deletes from both
     * EncryptedSharedPreferences and persistent external storage
     */
    private fun deleteKeyId() {
        try {
            // Delete from EncryptedSharedPreferences
            val prefs = getEncryptedPrefs()
            prefs.edit().remove(KEY_ID_KEY).apply()

            // Also delete from persistent external storage
            try {
                val storageDir = getPersistentStorageDir()
                val file = File(storageDir, KEY_ID_KEY)
                if (file.exists()) {
                    file.delete()
                }
            } catch (e: Exception) {
                // Ignore errors when deleting from external storage
            }
        } catch (e: Exception) {
            // Ignore errors when deleting
        }
    }

    /** Save assignment ID to persistent storage */
    private fun saveAssignmentId(assignmentId: Int) {
        try {
            val prefs = getEncryptedPrefs()
            prefs.edit().putString(ASSIGNMENT_ID_KEY, assignmentId.toString()).apply()

            try {
                saveToPersistentStorage(ASSIGNMENT_ID_KEY, assignmentId.toString())
            } catch (e: Exception) {
                // Log but don't fail
            }
        } catch (e: Exception) {
            throw Exception("Failed to save assignment ID: ${e.message}")
        }
    }

    /** Get assignment ID from persistent storage */
    private fun getAssignmentId(): String? {
        return try {
            val prefs = getEncryptedPrefs()
            val id = prefs.getString(ASSIGNMENT_ID_KEY, null)
            if (id != null) return id

            readFromPersistentStorage(ASSIGNMENT_ID_KEY)
        } catch (e: Exception) {
            readFromPersistentStorage(ASSIGNMENT_ID_KEY)
        }
    }

    /** Delete assignment ID from persistent storage */
    private fun deleteAssignmentId() {
        try {
            val prefs = getEncryptedPrefs()
            prefs.edit().remove(ASSIGNMENT_ID_KEY).apply()

            try {
                val storageDir = getPersistentStorageDir()
                val file = File(storageDir, ASSIGNMENT_ID_KEY)
                if (file.exists()) file.delete()
            } catch (e: Exception) { }
        } catch (e: Exception) { }
    }

    /**
     * Generate a new ECDSA key pair in Android Keystore with attestation
     *
     * [challenge]
     * - Challenge string from backend for attestation Returns: Map containing 'publicKey',
     * 'signature', and 'certificateChain'
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

        // Try with StrongBox if available (Android P+)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
            try {
                val strongBoxSpec =
                        KeyGenParameterSpec.Builder(
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
            val regularSpec =
                    KeyGenParameterSpec.Builder(
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
     * SPKI format structure: SEQUENCE { SEQUENCE {
     * ```
     *     OBJECT IDENTIFIER 1.2.840.10045.2.1 (id-ecPublicKey)
     *     OBJECT IDENTIFIER 1.2.840.10045.3.1.7 (secp256r1)
     * ```
     * } BIT STRING (uncompressedPoint: 0x04 + x + y) }
     */
    private fun encodePublicKeyToSPKI(keyPair: KeyPair): String {
        val publicKey = keyPair.public
        // Android Keystore's publicKey.encoded is already in SPKI format
        // This matches the format we manually build in iOS
        val encoded = publicKey.encoded
        return Base64.encodeToString(encoded, Base64.NO_WRAP)
    }

    /** Check if key exists in Keystore */
    private fun hasKey(): Boolean {
        return keyStore.containsAlias(KEY_ALIAS)
    }

    /**
     * Get public key from Keystore Returns: Base64 encoded public key in SPKI format (same format
     * as generateKeyPair)
     *
     * Note: We use certificate.publicKey which should give the same SPKI format as
     * keyPair.public.encoded from generateKeyPair
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
     * Sign data using the private key stored in Keystore The private key never leaves the hardware
     *
     * Algorithm: SHA256withECDSA (ES256)
     * - Automatically hashes the input data with SHA-256
     * - Signs the hash using ECDSA with P-256 curve
     * - Returns DER-encoded signature (SEQUENCE of two INTEGERs: r, s)
     *
     * Note: Android Keystore's Signature.sign() returns DER-encoded signature which is the standard
     * format expected by most backends
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

    /** Delete key from Keystore */
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
                "saveDeviceId" -> {
                    val deviceId = call.argument<Int>("deviceId")
                    if (deviceId == null) {
                        result.error("INVALID_ARGUMENT", "DeviceId parameter is required", null)
                        return
                    }
                    try {
                        saveDeviceId(deviceId)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("KEYSTORE_ERROR", e.message, e.toString())
                    }
                }
                "getDeviceId" -> {
                    val deviceId = getDeviceId()
                    result.success(deviceId)
                }
                "deleteDeviceId" -> {
                    deleteDeviceId()
                    result.success(null)
                }
                "saveKeyId" -> {
                    val keyId = call.argument<String>("keyId")
                    if (keyId == null) {
                        result.error("INVALID_ARGUMENT", "KeyId parameter is required", null)
                        return
                    }
                    try {
                        saveKeyId(keyId)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("KEYSTORE_ERROR", e.message, e.toString())
                    }
                }
                "getKeyId" -> {
                    val keyId = getKeyId()
                    result.success(keyId)
                }
                "deleteKeyId" -> {
                    deleteKeyId()
                    result.success(null)
                }
                "saveAssignmentId" -> {
                    val assignmentId = call.argument<Int>("assignmentId")
                    if (assignmentId == null) {
                        result.error("INVALID_ARGUMENT", "AssignmentId parameter is required", null)
                        return
                    }
                    try {
                        saveAssignmentId(assignmentId)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("KEYSTORE_ERROR", e.message, e.toString())
                    }
                }
                "getAssignmentId" -> {
                    val assignmentId = getAssignmentId()
                    result.success(assignmentId)
                }
                "deleteAssignmentId" -> {
                    deleteAssignmentId()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            result.error("KEYSTORE_ERROR", e.message, e.toString())
        }
    }
}
