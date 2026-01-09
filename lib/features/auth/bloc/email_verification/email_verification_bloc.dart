import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../models/email_verification_request.dart';
import '../../models/resend_verification_request.dart';
import '../../models/message_response.dart';
import '../../repository/auth_repository.dart';

part 'email_verification_event.dart';
part 'email_verification_state.dart';

class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  final AsyncRunner<MessageResponse> _verifyRunner =
      AsyncRunner<MessageResponse>();
  final AsyncRunner<MessageResponse> _resendRunner =
      AsyncRunner<MessageResponse>();

  EmailVerificationBloc()
    : super(EmailVerificationInitial(request: EmailVerificationRequest())) {
    on<UpdateEmail>(_onUpdateEmail);
    on<UpdateCode>(_onUpdateCode);
    on<VerifyEmail>(_onVerifyEmail);
    on<ResendCode>(_onResendCode);
  }

  void _onUpdateEmail(UpdateEmail event, Emitter<EmailVerificationState> emit) {
    emit(
      EmailVerificationInitial(
        request: state.request.copyWith(email: event.email),
      ),
    );
  }

  void _onUpdateCode(UpdateCode event, Emitter<EmailVerificationState> emit) {
    emit(
      EmailVerificationInitial(
        request: state.request.copyWith(code: event.code),
      ),
    );
  }

  Future<void> _onVerifyEmail(
    VerifyEmail event,
    Emitter<EmailVerificationState> emit,
  ) async {
    if (state.email.isEmpty || state.code.isEmpty) {
      emit(
        EmailVerificationFailure(
          error: "Email and code are required",
          request: state.request,
        ),
      );
      return;
    }

    emit(EmailVerificationLoading(request: state.request));

    await _verifyRunner.run(
      onlineTask: (_) async {
        return await AuthRepository.verifyEmail(state.request);
      },
      checkConnectivity: true,
      onSuccess: (_) {
        if (!emit.isDone) {
          emit(EmailVerificationSuccess(request: state.request));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(
            EmailVerificationFailure(
              error: error.toString(),
              request: state.request,
            ),
          );
        }
      },
    );
  }

  Future<void> _onResendCode(
    ResendCode event,
    Emitter<EmailVerificationState> emit,
  ) async {
    if (state.email.isEmpty) {
      emit(
        EmailVerificationFailure(
          error: "Email is required",
          request: state.request,
        ),
      );
      return;
    }

    emit(EmailVerificationLoading(request: state.request));

    await _resendRunner.run(
      onlineTask: (_) async {
        final request = ResendVerificationRequest(email: state.email);
        return await AuthRepository.resendVerificationCode(request);
      },
      checkConnectivity: true,
      onSuccess: (_) {
        if (!emit.isDone) {
          emit(CodeResendSuccess(request: state.request));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(
            EmailVerificationFailure(
              error: error.toString(),
              request: state.request,
            ),
          );
        }
      },
    );
  }
}
