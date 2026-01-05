import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/device_info_util.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../core/services/passkey_service.dart';
import '../../../../core/services/device_bound_key_service.dart';
import '../../../device_registration/repository/device_cookie_repository.dart';
import '../../../profile/models/user.dart';
import '../../models/researcher_login_initiate_request.dart';
import '../../models/researcher_login_initiate_response.dart';
import '../../models/researcher_login_verify_request.dart';
import '../../models/researcher_login_verify_response.dart';
import '../../repository/auth_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final PasskeyService _passkeyService = PasskeyService();
  final DeviceBoundKeyService _deviceBoundKeyService = DeviceBoundKeyService();
  final AsyncRunner<ResearcherLoginInitiateResponse> _initiateRunner =
      AsyncRunner<ResearcherLoginInitiateResponse>();
  final AsyncRunner<ResearcherLoginVerifyResponse> _verifyRunner =
      AsyncRunner<ResearcherLoginVerifyResponse>();

  LoginBloc() : super(LoginInitial()) {
    on<UpdateEmail>(_onUpdateEmail);
    on<UpdatePassword>(_onUpdatePassword);
    on<SendInitiateLogin>(_onSendInitiateLogin);
    on<SendVerifyLogin>(_onSendVerifyLogin);
    on<ResetState>(_onResetState);
  }

  void _onUpdateEmail(UpdateEmail event, Emitter<LoginState> emit) {
    emit(LoginInitial(email: event.email, password: state.password));
  }

  void _onUpdatePassword(UpdatePassword event, Emitter<LoginState> emit) {
    emit(LoginInitial(email: state.email, password: event.password));
  }

  void _onResetState(ResetState event, Emitter<LoginState> emit) {
    emit(LoginInitial());
  }

  Future<void> _onSendInitiateLogin(
    SendInitiateLogin event,
    Emitter<LoginState> emit,
  ) async {
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(
        LoginFailure(
          error: "Email and password are required",
          email: state.email,
          password: state.password,
        ),
      );
      return;
    }

    emit(LoginLoading(email: state.email, password: state.password));

    await _initiateRunner.run(
      onlineTask: (_) async {
        final fingerprint = await DeviceInfoUtil.getFingerprint();

        final request = ResearcherLoginInitiateRequest(
          email: state.email,
          password: state.password,
          os: DeviceInfoUtil.getOS(),
          browser: DeviceInfoUtil.getBrowser(),
          fingerprint: fingerprint,
          deviceToken: FirebaseService.fcmToken ?? '',
        );

        return await AuthRepository.initiateResearcherLogin(request: request);
      },
      checkConnectivity: true,
      onSuccess: (response) async {
        // Save device cookie if present
        if (response.cookie != null && response.cookie!.isNotEmpty) {
          await DeviceCookieRepository.saveDeviceCookie(response.cookie!);
        }

        if (!emit.isDone) {
          emit(
            LoginInitiateSuccess(
              response: response,
              email: state.email,
              password: state.password,
            ),
          );
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(
            LoginFailure(
              error: error.toString(),
              email: state.email,
              password: state.password,
            ),
          );
        }
      },
    );
  }

  Future<void> _onSendVerifyLogin(
    SendVerifyLogin event,
    Emitter<LoginState> emit,
  ) async {
    final currentState = state;
    dynamic credentials;

    // Handle different authentication methods
    if (currentState is LoginInitiateSuccess) {
      emit(LoginLoading(email: state.email, password: state.password));

      final loginMethod = currentState.response.loginMethod;

      try {
        switch (loginMethod) {
          case LoginMethod.webauthn:
            // Case 1: WebAuthn/Passkey authentication
            credentials = await _handleWebAuthnLogin(currentState.response);
            break;

          case LoginMethod.deviceBoundKey:
            // Case 2: Device-Bound Key authentication
            credentials = await _handleDeviceBoundKeyLogin(
              currentState.response,
            );
            break;

          case LoginMethod.cookieBased:
            // Case 3: Cookie-based authentication (no credentials needed)
            credentials = null;
            break;
        }
      } catch (e) {
        emit(
          LoginFailure(
            error: "Authentication failed: $e",
            email: state.email,
            password: state.password,
          ),
        );
        return;
      }
    } else {
      emit(LoginLoading(email: state.email, password: state.password));
    }

    await _verifyRunner.run(
      onlineTask: (_) async {
        final fingerprint = await DeviceInfoUtil.getFingerprint();

        // Determine credentials to use
        dynamic finalCredentials;
        if (event.credentials.isNotEmpty) {
          try {
            finalCredentials = jsonDecode(event.credentials);
          } catch (_) {
            finalCredentials = event.credentials;
          }
        } else {
          finalCredentials = credentials;
        }

        final request = ResearcherLoginVerifyRequest(
          email: state.email,
          password: state.password,
          os: DeviceInfoUtil.getOS(),
          browser: DeviceInfoUtil.getBrowser(),
          fingerprint: fingerprint,
          deviceToken: await DeviceInfoUtil.getDeviceToken(),
          timezone: await DeviceInfoUtil.getTimezone(),
          credentials: finalCredentials,
        );

        return await AuthRepository.verifyResearcherLogin(request: request);
      },
      checkConnectivity: true,
      onSuccess: (response) async {
        // Save device cookie if present (this is the final cookie and should take precedence)
        if (response.cookie != null && response.cookie!.isNotEmpty) {
          await DeviceCookieRepository.saveDeviceCookie(response.cookie!);
        }

        if (!emit.isDone) {
          emit(
            LoginSuccess(
              user: response.user,
              token: response.accessToken,
              email: state.email,
              password: state.password,
            ),
          );
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(
            LoginFailure(
              error: error.toString(),
              email: state.email,
              password: state.password,
            ),
          );
        }
      },
    );
  }

  /// Handle WebAuthn/Passkey login
  Future<Map<String, dynamic>> _handleWebAuthnLogin(
    ResearcherLoginInitiateResponse response,
  ) async {
    final options = response.webauthnOptions;
    if (options == null) {
      throw Exception('WebAuthn options not found');
    }

    return await _passkeyService.authenticate(
      options.toWebAuthnOptions(),
      allowCredentials: options.allowCredentialsList,
    );
  }

  /// Handle Device-Bound Key login
  Future<String> _handleDeviceBoundKeyLogin(
    ResearcherLoginInitiateResponse response,
  ) async {
    final options = response.deviceBoundKeyOptions;
    if (options == null) {
      throw Exception('Device-Bound Key options not found');
    }

    // Sign the challenge using device-bound key
    final signature = await _deviceBoundKeyService.signChallenge(
      options.challenge,
    );

    // Return signature as JSON string (will be parsed in verify request)
    return signature;
  }
}
