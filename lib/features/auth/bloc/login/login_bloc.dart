import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/device_info_util.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../core/services/device_bound_key_service.dart';
import '../../../device_registration/repository/device_cookie_repository.dart';
import '../../models/login_method_type.dart';
import '../../models/researcher_login_initiate_request.dart';
import '../../models/researcher_login_initiate_response.dart';
import '../../models/researcher_login_verify_request.dart';
import '../../models/researcher_login_verify_response.dart';
import '../../../../core/models/pending_custody.dart';
import '../../repository/auth_repository.dart';
import '../../repository/auth_local_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
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
        // Always get keyId - it will be generated deterministically if not exists
        final deviceKeyId = await _deviceBoundKeyService.getKeyId();

        final request = ResearcherLoginInitiateRequest(
          email: state.email,
          password: state.password,
          os: DeviceInfoUtil.getOS(),
          browser: DeviceInfoUtil.getBrowser(),
          fingerprint: fingerprint,
          deviceToken: '1592', //FirebaseService.fcmToken ?? '',
          deviceKeyId: deviceKeyId,
        );

        return await AuthRepository.initiateResearcherLogin(request: request);
      },
      checkConnectivity: true,
      onSuccess: (response) async {
        // Save device cookie if present
        if (response.cookie != null && response.cookie!.isNotEmpty) {
          await DeviceCookieRepository.saveDeviceCookie(response.cookie!);
        }

        // Unbounded auth: backend returned accessToken directly (no verify step)
        if (response.isUnboundAuth && response.accessToken != null) {
          await AuthLocalRepository.saveToken(response.accessToken!);
          await AuthLocalRepository.saveLoginMethod(LoginMethodType.emailOnly);

          // Save custody verification state
          await AuthLocalRepository.saveCustodyVerificationState(
            shouldVerify: false,
            pendingCustody: null,
          );

          if (!emit.isDone) {
            emit(
              LoginSuccess(
                token: response.accessToken!,
                email: state.email,
                password: state.password,
                shouldVerifyCustody: false,
                pendingCustody: null,
              ),
            );
          }
          return;
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
          case LoginMethod.deviceBoundKey:
            // Device-Bound Key authentication
            credentials = await _handleDeviceBoundKeyLogin(
              currentState.response,
            );
            break;

          case LoginMethod.cookieBased:
            // Cookie-based authentication (no credentials needed)
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

        await AuthLocalRepository.saveLoginMethod(LoginMethodType.challenge);

        // Save custody verification state
        await AuthLocalRepository.saveCustodyVerificationState(
          shouldVerify: response.should_verify_custody,
          pendingCustody: response.pending_custody,
        );

        // Fetch the user profile that was saved by AuthRepository.verifyResearcherLogin
        if (!emit.isDone) {
          emit(
            LoginSuccess(
              token: response.accessToken,
              email: state.email,
              password: state.password,
              shouldVerifyCustody: response.should_verify_custody,
              pendingCustody: response.pending_custody,
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

  /// Handle Device-Bound Key login
  Future<Map<String, dynamic>> _handleDeviceBoundKeyLogin(
    ResearcherLoginInitiateResponse response,
  ) async {
    final options = response.deviceBoundKeyOptions;
    if (options == null) {
      throw Exception('Device-Bound Key options not found');
    }

    // Get stored keyId for this device
    final keyId = await _deviceBoundKeyService.getKeyId();
    if (keyId == null || keyId.isEmpty) {
      throw Exception('Device key ID not found. Please register device first.');
    }

    // Timestamp for replay protection (must match backend expectation)
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Backend builds payload as: `${challenge}|${keyId}|${timestamp}`
    final payload = '${options.challenge}|$keyId|$timestamp';

    // Sign the payload using device-bound key (require biometric for login)
    final signature = await _deviceBoundKeyService.signPayload(payload);

    // Credentials object expected by backend
    return {
      'signature': signature,
      'keyId': keyId,
      'timestamp': timestamp,
      'challenge': options.challenge,
    };
  }
}
