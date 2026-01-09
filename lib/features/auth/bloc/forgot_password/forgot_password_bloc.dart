import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../models/forgot_password_request.dart';
import '../../models/reset_password_request.dart';
import '../../models/message_response.dart';
import '../../repository/auth_repository.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AsyncRunner<MessageResponse> _requestRunner =
      AsyncRunner<MessageResponse>();
  final AsyncRunner<MessageResponse> _resetRunner =
      AsyncRunner<MessageResponse>();

  ForgotPasswordBloc()
    : super(
        ForgotPasswordInitial(
          request: ForgotPasswordRequest(),
          resetRequest: ResetPasswordRequest(),
        ),
      ) {
    on<UpdateEmail>(_onUpdateEmail);
    on<UpdateCode>(_onUpdateCode);
    on<UpdateNewPassword>(_onUpdateNewPassword);
    on<RequestResetCode>(_onRequestResetCode);
    on<ResetPassword>(_onResetPassword);
    on<ChangeStep>(_onChangeStep);
  }

  void _onUpdateEmail(UpdateEmail event, Emitter<ForgotPasswordState> emit) {
    emit(
      ForgotPasswordInitial(
        request: ForgotPasswordRequest(email: event.email),
        resetRequest: state.resetRequest.copyWith(email: event.email),
        step: state.step,
      ),
    );
  }

  void _onUpdateCode(UpdateCode event, Emitter<ForgotPasswordState> emit) {
    emit(
      ForgotPasswordInitial(
        request: state.request,
        resetRequest: state.resetRequest.copyWith(code: event.code),
        step: state.step,
      ),
    );
  }

  void _onUpdateNewPassword(
    UpdateNewPassword event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(
      ForgotPasswordInitial(
        request: state.request,
        resetRequest: state.resetRequest.copyWith(password: event.password),
        step: state.step,
      ),
    );
  }

  void _onChangeStep(ChangeStep event, Emitter<ForgotPasswordState> emit) {
    emit(
      ForgotPasswordInitial(
        request: state.request,
        resetRequest: state.resetRequest,
        step: event.step,
      ),
    );
  }

  Future<void> _onRequestResetCode(
    RequestResetCode event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    if (state.email.isEmpty) {
      emit(
        ForgotPasswordFailure(
          error: "Email is required",
          request: state.request,
          resetRequest: state.resetRequest,
          step: state.step,
        ),
      );
      return;
    }

    emit(
      ForgotPasswordLoading(
        request: state.request,
        resetRequest: state.resetRequest,
        step: state.step,
      ),
    );

    await _requestRunner.run(
      onlineTask: (_) async {
        return await AuthRepository.requestPasswordReset(state.request);
      },
      checkConnectivity: true,
      onSuccess: (_) {
        if (!emit.isDone) {
          emit(
            ForgotPasswordCodeSent(
              request: state.request,
              resetRequest: state.resetRequest,
            ),
          );
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(
            ForgotPasswordFailure(
              error: error.toString(),
              request: state.request,
              resetRequest: state.resetRequest,
              step: state.step,
            ),
          );
        }
      },
    );
  }

  Future<void> _onResetPassword(
    ResetPassword event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    if (state.code.isEmpty || state.newPassword.isEmpty) {
      emit(
        ForgotPasswordFailure(
          error: "Code and new password are required",
          request: state.request,
          resetRequest: state.resetRequest,
          step: state.step,
        ),
      );
      return;
    }

    emit(
      ForgotPasswordLoading(
        request: state.request,
        resetRequest: state.resetRequest,
        step: state.step,
      ),
    );

    await _resetRunner.run(
      onlineTask: (_) async {
        return await AuthRepository.resetPassword(state.resetRequest);
      },
      checkConnectivity: true,
      onSuccess: (_) {
        if (!emit.isDone) {
          emit(
            ForgotPasswordSuccess(
              request: state.request,
              resetRequest: state.resetRequest,
              step: state.step,
            ),
          );
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(
            ForgotPasswordFailure(
              error: error.toString(),
              request: state.request,
              resetRequest: state.resetRequest,
              step: state.step,
            ),
          );
        }
      },
    );
  }
}
