package com.rs4it.king_abdulaziz_center_survey_app

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.nio.charset.StandardCharsets
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.MessageDigest
import java.security.Signature
import java.security.spec.ECGenParameterSpec

class HardwareKeyStoreHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val KEYSTORE_PROVIDER = "AndroidKeyStore"
        private const val KEY_ALIAS = "device_bound_key_alias"
        private const val SIGNATURE_ALGORITHM = "SHA256withECDSA"
    }

    private val keyStore: KeyStore = KeyStore.getInstance(KEYSTORE_PROVIDER).apply { load(null) }

    private fun getUniqueDeviceKeyId(): String {
        val androidId =
                android.provider.Settings.Secure.getString(
                        context.contentResolver,
                        android.provider.Settings.Secure.ANDROID_ID
                )
                        ?: "unknown_android_id"
        val input = "device_key_$androidId"
        val digest = MessageDigest.getInstance("SHA-256")
        val hash = digest.digest(input.toByteArray(StandardCharsets.UTF_8))
        return hash.joinToString("") { "%02x".format(it) }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "generateKeyPair" -> {
                    val challenge = call.argument<String>("challenge")
                    if (challenge == null) {
                        result.error("INVALID_ARGUMENT", "Challenge is required", null)
                        return
                    }
                    generateAndSignChallenge(challenge, result)
                }
                "signPayload" -> {
                    val payload = call.argument<String>("payload")
                    if (payload == null) {
                        result.error("INVALID_ARGUMENT", "Payload is required", null)
                        return
                    }
                    signPayload(payload, result)
                }
                "hasKey" -> result.success(keyStore.containsAlias(KEY_ALIAS))
                "getPublicKey" -> getPublicKey(result)
                "deleteKey" -> {
                    keyStore.deleteEntry(KEY_ALIAS)
                    result.success(null)
                }
                "getKeyId" -> {
                    if (keyStore.containsAlias(KEY_ALIAS)) {
                        result.success(getUniqueDeviceKeyId())
                    } else {
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("KEYSTORE_ERROR", e.message, e.toString())
        }
    }

    private fun generateAndSignChallenge(challenge: String, result: MethodChannel.Result) {
        try {
            // 1. Delete old key if exists
            keyStore.deleteEntry(KEY_ALIAS)

            // ... (rest of the code remains same until result.success)

            // 2. Try to generate with StrongBox first (highest security)
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    generateKeyInternal(challenge, useStrongBox = true)
                } else {
                    generateKeyInternal(challenge, useStrongBox = false)
                }
            } catch (e: Exception) {
                // If StrongBox fails or is not available, fallback to TEE
                keyStore.deleteEntry(KEY_ALIAS)
                generateKeyInternal(challenge, useStrongBox = false)
            }

            // 3. Key should be generated now, get it from KeyStore
            val entry = keyStore.getEntry(KEY_ALIAS, null) as KeyStore.PrivateKeyEntry
            val privateKey = entry.privateKey
            val publicKey = entry.certificate.publicKey

            // 4. Sign the challenge (Proof of Possession)
            val signer = Signature.getInstance(SIGNATURE_ALGORITHM)
            signer.initSign(privateKey)
            signer.update(challenge.toByteArray())
            val signature = signer.sign()

            // 5. Get Certificate Chain for Attestation
            val certificates = keyStore.getCertificateChain(KEY_ALIAS)
            val certChainBase64 =
                    certificates?.map { cert ->
                        Base64.encodeToString(cert.encoded, Base64.NO_WRAP)
                    }
                            ?: emptyList<String>()

            val publicKeyBase64 = Base64.encodeToString(publicKey.encoded, Base64.NO_WRAP)

            result.success(
                    mapOf(
                            "publicKey" to publicKeyBase64,
                            "signature" to Base64.encodeToString(signature, Base64.NO_WRAP),
                            "keyId" to getUniqueDeviceKeyId(),
                            "certificateChain" to certChainBase64
                    )
            )
        } catch (e: Exception) {
            result.error(
                    "KEYSTORE_ERROR",
                    "Failed to generate key pair: ${e.message}",
                    e.toString()
            )
        }
    }

    private fun generateKeyInternal(challenge: String, useStrongBox: Boolean) {
        val kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, KEYSTORE_PROVIDER)
        val builder =
                KeyGenParameterSpec.Builder(
                                KEY_ALIAS,
                                KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
                        )
                        .run {
                            setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
                            setDigests(KeyProperties.DIGEST_SHA256)
                            setAttestationChallenge(challenge.toByteArray())
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                setIsStrongBoxBacked(useStrongBox)
                            }
                            build()
                        }
        kpg.initialize(builder)
        kpg.generateKeyPair()
    }

    private fun signPayload(payload: String, result: MethodChannel.Result) {
        val entry = keyStore.getEntry(KEY_ALIAS, null) as? KeyStore.PrivateKeyEntry
        if (entry == null) {
            result.error("KEY_NOT_FOUND", "No key found for alias $KEY_ALIAS", null)
            return
        }

        val signer = Signature.getInstance(SIGNATURE_ALGORITHM)
        signer.initSign(entry.privateKey)
        signer.update(payload.toByteArray())
        val signature = signer.sign()

        result.success(Base64.encodeToString(signature, Base64.NO_WRAP))
    }

    private fun getPublicKey(result: MethodChannel.Result) {
        val certificate = keyStore.getCertificate(KEY_ALIAS)
        if (certificate == null) {
            result.success(null)
            return
        }
        val publicKeyBase64 = Base64.encodeToString(certificate.publicKey.encoded, Base64.NO_WRAP)
        result.success(publicKeyBase64)
    }
}
