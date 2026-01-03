import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/device_info_util.dart';
import '../../../../core/services/passkey_service.dart';
import '../../../profile/models/user.dart';
import '../../models/researcher_login_initiate_request.dart';
import '../../models/researcher_login_initiate_response.dart';
import '../../models/researcher_login_verify_request.dart';
import '../../repository/auth_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final PasskeyService _passkeyService = PasskeyService();

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

    try {
      final fingerprint = await DeviceInfoUtil.getFingerprint();

      final request = ResearcherLoginInitiateRequest(
        email: state.email,
        password: state.password,
        os: DeviceInfoUtil.getOS(),
        browser: DeviceInfoUtil.getBrowser(),
        fingerprint: fingerprint,
      );

      final response = await AuthRepository.initiateResearcherLogin(
        request: request,
      );

      emit(
        LoginInitiateSuccess(
          response: response,
          email: state.email,
          password: state.password,
        ),
      );
    } catch (e) {
      emit(
        LoginFailure(
          error: e.toString(),
          email: state.email,
          password: state.password,
        ),
      );
    }
  }

  Future<void> _onSendVerifyLogin(
    SendVerifyLogin event,
    Emitter<LoginState> emit,
  ) async {
    final currentState = state;
    dynamic passkeyCredentials;

    // If we just had a successful initiate and the method is webauthn
    if (currentState is LoginInitiateSuccess &&
        currentState.response.method == 'webauthn') {
      emit(LoginLoading(email: state.email, password: state.password));
      try {
        final options = currentState.response.options;
        if (options != null) {
          passkeyCredentials = await _passkeyService.authenticate(options);
        }
      } catch (e) {
        emit(
          LoginFailure(
            error: "Biometric authentication failed: $e",
            email: state.email,
            password: state.password,
          ),
        );
        return;
      }
    } else {
      emit(LoginLoading(email: state.email, password: state.password));
    }

    try {
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
        finalCredentials = passkeyCredentials;
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

      final response = await AuthRepository.verifyResearcherLogin(
        request: request,
      );

      emit(
        LoginSuccess(
          user: response.user,
          token: response.accessToken,
          email: state.email,
          password: state.password,
        ),
      );
    } catch (e) {
      emit(
        LoginFailure(
          error: e.toString(),
          email: state.email,
          password: state.password,
        ),
      );
    }
  }
}
