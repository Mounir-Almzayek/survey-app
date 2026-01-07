import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../core/services/device_bound_key_service.dart';
import '../../repository/device_registration_repository.dart';
import '../../repository/device_cookie_repository.dart';
import '../../models/registration_method.dart';
import '../../models/cookie_based_complete_request.dart';
import '../../models/complete_registration_response.dart';
import '../../models/device_bound_key_challenge_request.dart';
import '../../models/device_bound_key_challenge_response.dart';
import '../../models/device_bound_key_complete_request.dart';
import 'complete_registration_event.dart';
import 'complete_registration_state.dart';

class CompleteRegistrationBloc
    extends Bloc<CompleteRegistrationEvent, CompleteRegistrationState> {
  final AsyncRunner<DeviceBoundKeyChallengeResponse>
  _deviceBoundKeyChallengeRunner =
      AsyncRunner<DeviceBoundKeyChallengeResponse>();
  final AsyncRunner<CompleteRegistrationResponse> _registrationRunner =
      AsyncRunner<CompleteRegistrationResponse>();

  CompleteRegistrationBloc() : super(CompleteRegistrationInitial()) {
    on<CompleteRegistration>(_onCompleteRegistration);
  }

  Future<void> _onCompleteRegistration(
    CompleteRegistration event,
    Emitter<CompleteRegistrationState> emit,
  ) async {
    switch (event.method) {
      case RegistrationMethod.deviceBoundKey:
        await _handleDeviceBoundKeyRegistration(event, emit);
        break;
      case RegistrationMethod.cookieBased:
        await _handleCookieBasedRegistration(event, emit);
        break;
    }
  }

  Future<void> _handleCookieBasedRegistration(
    CompleteRegistration event,
    Emitter<CompleteRegistrationState> emit,
  ) async {
    emit(CompleteRegistrationLoading(RegistrationMethod.cookieBased));

    await _registrationRunner.run(
      onlineTask: (_) async {
        final request = CookieBasedCompleteRequest(
          token: event.token,
          browser: event.fingerprint.browser,
          os: event.fingerprint.os,
          fingerprint: event.fingerprint.toJson(),
        );

        return await DeviceRegistrationRepository.completeCookieBasedRegistration(
          request: request,
        );
      },
      checkConnectivity: true,
      onSuccess: (response) {
        if (!emit.isDone) {
          if (response.success) {
            // Save device cookie if present
            if (response.cookie != null && response.cookie!.isNotEmpty) {
              DeviceCookieRepository.saveDeviceCookie(response.cookie!);
            }
            emit(CompleteRegistrationSuccess(response));
          } else {
            emit(
              CompleteRegistrationFailure(
                response.errorMessage ?? 'Registration failed',
              ),
            );
          }
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(CompleteRegistrationFailure(error.toString()));
        }
      },
    );
  }

  Future<void> _handleDeviceBoundKeyRegistration(
    CompleteRegistration event,
    Emitter<CompleteRegistrationState> emit,
  ) async {
    emit(CompleteRegistrationLoading(RegistrationMethod.deviceBoundKey));

    final challengeRequest = DeviceBoundKeyChallengeRequest(
      token: event.token,
      os: event.fingerprint.os,
      fingerprint: event.fingerprint,
    );

    DeviceBoundKeyChallengeResponse? challengeResponse;

    await _deviceBoundKeyChallengeRunner.run(
      onlineTask: (_) async {
        return await DeviceRegistrationRepository.getDeviceBoundKeyChallenge(
          request: challengeRequest,
        );
      },
      checkConnectivity: true,
      onSuccess: (response) {
        challengeResponse = response;
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(CompleteRegistrationFailure(error.toString()));
        }
      },
    );

    if (challengeResponse == null) {
      return;
    }

    // Save initial cookie if present
    if (challengeResponse!.cookie != null &&
        challengeResponse!.cookie!.isNotEmpty) {
      DeviceCookieRepository.saveDeviceCookie(challengeResponse!.cookie!);
    }

    final deviceBoundKeyService = DeviceBoundKeyService();
    Map<String, dynamic> keyPair;
    String signature;

    try {
      // Generate device-bound key pair with challenge for attestation
      // This will generate the key, sign the challenge, and return signature + attestation
      keyPair = await deviceBoundKeyService.generateKeyPair(
        challengeResponse!.challenge,
      );

      // Use the signature from key generation (Proof of Possession)
      signature = keyPair['signature'] as String;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('CompleteRegistrationBloc: Device-Bound Key registration failed');
        print('CompleteRegistrationBloc: Error: $e');
        print('CompleteRegistrationBloc: Stack trace: $stackTrace');
      }
      if (!emit.isDone) {
        emit(CompleteRegistrationFailure(e.toString()));
      }
      return;
    }

    // Signature is already a base64 string (not JSON)
    final signatureString = signature;

    // Complete Registration
    await _registrationRunner.run(
      onlineTask: (_) async {
        // Extract attestation if available
        Attestation? attestation;
        if (keyPair['attestation'] != null) {
          final attestationData =
              keyPair['attestation'] as Map<String, dynamic>;
          final certificateChain =
              attestationData['certificateChain'] as List<dynamic>?;
          if (certificateChain != null && certificateChain.isNotEmpty) {
            attestation = Attestation(
              certificateChain: certificateChain
                  .map((c) => c.toString())
                  .toList(),
            );
          }
        }

        final completeRequest = DeviceBoundKeyCompleteRequest(
          token: event.token,
          publicKey: keyPair['publicKey'] as String,
          keyId: keyPair['keyId'] as String,
          signature: signatureString,
          algorithm: 'ES256',
          attestation: attestation,
        );

        return await DeviceRegistrationRepository.completeDeviceBoundKeyRegistration(
          request: completeRequest,
        );
      },
      checkConnectivity: true,
      onSuccess: (response) {
        if (!emit.isDone) {
          if (response.success) {
            // Save device cookie if present
            if (response.cookie != null && response.cookie!.isNotEmpty) {
              DeviceCookieRepository.saveDeviceCookie(response.cookie!);
            }
            emit(CompleteRegistrationSuccess(response));
          } else {
            emit(
              CompleteRegistrationFailure(
                response.errorMessage ?? 'Registration failed',
              ),
            );
          }
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(CompleteRegistrationFailure(error.toString()));
        }
      },
    );
  }
}
