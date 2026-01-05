import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../core/services/passkey_service.dart';
import '../../repository/device_registration_repository.dart';
import '../../repository/device_cookie_repository.dart';
import '../../models/registration_method.dart';
import '../../models/webauthn_challenge_request.dart';
import '../../models/webauthn_challenge_response.dart';
import '../../models/webauthn_complete_request.dart';
import '../../models/cookie_based_complete_request.dart';
import '../../models/complete_registration_response.dart';
import 'complete_registration_event.dart';
import 'complete_registration_state.dart';

class CompleteRegistrationBloc
    extends Bloc<CompleteRegistrationEvent, CompleteRegistrationState> {
  final AsyncRunner<WebAuthnChallengeResponse> _challengeRunner =
      AsyncRunner<WebAuthnChallengeResponse>();
  final AsyncRunner<CompleteRegistrationResponse> _registrationRunner =
      AsyncRunner<CompleteRegistrationResponse>();

  CompleteRegistrationBloc() : super(CompleteRegistrationInitial()) {
    on<CompleteRegistration>(_onCompleteRegistration);
  }

  Future<void> _onCompleteRegistration(
    CompleteRegistration event,
    Emitter<CompleteRegistrationState> emit,
  ) async {
    if (event.method == RegistrationMethod.webauthn) {
      await _handleWebAuthnRegistration(event, emit);
    } else {
      await _handleCookieBasedRegistration(event, emit);
    }
  }

  Future<void> _handleWebAuthnRegistration(
    CompleteRegistration event,
    Emitter<CompleteRegistrationState> emit,
  ) async {
    final challengeRequest = WebAuthnChallengeRequest(
      token: event.token,
      browser: event.fingerprint.browser,
      os: event.fingerprint.os,
      fingerprint: event.fingerprint.toJson(),
    );

    WebAuthnChallengeResponse? challengeResponse;

    await _challengeRunner.run(
      onlineTask: (_) async {
        return await DeviceRegistrationRepository.getWebAuthnChallenge(
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

    final passkeyService = PasskeyService();
    Map<String, dynamic> credentials;

    try {
      credentials = await passkeyService.register(challengeResponse!.options);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('CompleteRegistrationBloc: Passkey registration failed');
        print('CompleteRegistrationBloc: Error: $e');
        print('CompleteRegistrationBloc: Stack trace: $stackTrace');
      }
      if (!emit.isDone) {
        emit(CompleteRegistrationFailure(e.toString()));
      }
      return;
    }

    // Step 3: Complete Registration
    await _registrationRunner.run(
      onlineTask: (_) async {
        final completeRequest = WebAuthnCompleteRequest(
          token: event.token,
          credentials: credentials,
        );

        return await DeviceRegistrationRepository.completeWebAuthnRegistration(
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
}
