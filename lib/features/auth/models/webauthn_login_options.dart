import '../../device_registration/models/webauthn_challenge_response.dart';

/// WebAuthn options for login/authentication (different structure from registration)
class WebAuthnLoginOptions {
  final String rpId;
  final String challenge;
  final List<CredentialDescriptor> allowCredentials;
  final int timeout;
  final String userVerification;

  const WebAuthnLoginOptions({
    required this.rpId,
    required this.challenge,
    required this.allowCredentials,
    required this.timeout,
    required this.userVerification,
  });

  factory WebAuthnLoginOptions.fromJson(Map<String, dynamic> json) {
    return WebAuthnLoginOptions(
      rpId: json['rpId'] as String,
      challenge: json['challenge'] as String,
      allowCredentials: (json['allowCredentials'] as List? ?? [])
          .map((e) => CredentialDescriptor.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeout: json['timeout'] as int,
      userVerification: json['userVerification'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rpId': rpId,
      'challenge': challenge,
      'allowCredentials': allowCredentials.map((e) => e.toJson()).toList(),
      'timeout': timeout,
      'userVerification': userVerification,
    };
  }

  /// Convert to WebAuthnOptions format required by PasskeyService.authenticate
  WebAuthnOptions toWebAuthnOptions() {
    return WebAuthnOptions(
      challenge: challenge,
      rp: RelyingParty(name: 'SurveySystem', id: rpId),
      user: const WebAuthnUser(id: '', name: '', displayName: ''),
      pubKeyCredParams: [
        PubKeyCredParam(alg: -8, type: 'public-key'),
        PubKeyCredParam(alg: -7, type: 'public-key'),
        PubKeyCredParam(alg: -257, type: 'public-key'),
      ],
      timeout: timeout,
      attestation: 'none',
      excludeCredentials: [],
      authenticatorSelection: AuthenticatorSelection(
        residentKey: 'discouraged',
        requireResidentKey: false,
        authenticatorAttachment: 'platform',
        userVerification: userVerification,
      ),
      extensions: null,
      hints: [],
    );
  }

  /// Get allowCredentials for PasskeyService.authenticate
  List<CredentialDescriptor> get allowCredentialsList => allowCredentials;
}
