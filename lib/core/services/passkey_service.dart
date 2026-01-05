import 'package:flutter/foundation.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import '../../features/device_registration/models/webauthn_challenge_response.dart';

class PasskeyService {
  static final PasskeyService _instance = PasskeyService._internal();
  factory PasskeyService() => _instance;
  PasskeyService._internal();

  final _authenticator = PasskeyAuthenticator();

  Future<Map<String, dynamic>> authenticate(
    WebAuthnOptions options, {
    List<CredentialDescriptor>? allowCredentials,
  }) async {
    try {
      final request = AuthenticateRequestType(
        relyingPartyId: options.rp.id,
        challenge: options.challenge,
        timeout: options.timeout,
        userVerification: options.authenticatorSelection.userVerification,
        mediation: MediationType.Optional,
        preferImmediatelyAvailableCredentials: false,
        allowCredentials:
            allowCredentials
                ?.map(
                  (e) => CredentialType(
                    id: e.id,
                    type: e.type,
                    transports: e.transports ?? [],
                  ),
                )
                .toList() ??
            [],
      );

      final response = await _authenticator.authenticate(request);

      return response.toJson();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(WebAuthnOptions options) async {
    try {
      final request = RegisterRequestType(
        excludeCredentials: options.excludeCredentials
            .map(
              (e) => CredentialType(
                id: e.id,
                type: e.type,
                transports: e.transports ?? [],
              ),
            )
            .toList(),
        authSelectionType: AuthenticatorSelectionType(
          authenticatorAttachment:
              options.authenticatorSelection.authenticatorAttachment,
          residentKey: options.authenticatorSelection.residentKey,
          requireResidentKey: options.authenticatorSelection.requireResidentKey,
          userVerification: options.authenticatorSelection.userVerification,
        ),
        attestation: options.attestation,
        timeout: options.timeout,
        relyingParty: RelyingPartyType(
          name: options.rp.name,
          id: options.rp.id,
        ),
        user: UserType(
          displayName: options.user.displayName,
          name: options.user.name,
          id: options.user.id,
        ),
        challenge: options.challenge,
        pubKeyCredParams: options.pubKeyCredParams
            .map((e) => PubKeyCredParamType(alg: e.alg, type: e.type))
            .toList(),
      );

      final response = await _authenticator.register(request);

      return response.toJson();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('PasskeyService: Registration error: $e');
        print('PasskeyService: Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<bool> isSupported() async {
    try {
      return await _authenticator.canAuthenticate();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isSupportedStatic() async {
    return await _instance.isSupported();
  }
}
