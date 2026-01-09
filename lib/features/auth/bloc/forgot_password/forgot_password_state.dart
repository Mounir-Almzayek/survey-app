part of 'forgot_password_bloc.dart';

enum ForgotPasswordStep { email, code }

abstract class ForgotPasswordState {
  final ForgotPasswordRequest request;
  final ResetPasswordRequest resetRequest;
  final ForgotPasswordStep step;

  ForgotPasswordState({
    required this.request,
    required this.resetRequest,
    this.step = ForgotPasswordStep.email,
  });

  String get email => request.email;
  String get code => resetRequest.code;
  String get newPassword => resetRequest.password;
}

class ForgotPasswordInitial extends ForgotPasswordState {
  ForgotPasswordInitial({
    required super.request,
    required super.resetRequest,
    super.step,
  });
}

class ForgotPasswordLoading extends ForgotPasswordState {
  ForgotPasswordLoading({
    required super.request,
    required super.resetRequest,
    super.step,
  });
}

class ForgotPasswordCodeSent extends ForgotPasswordState {
  ForgotPasswordCodeSent({
    required super.request,
    required super.resetRequest,
    super.step = ForgotPasswordStep.code,
  });
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  ForgotPasswordSuccess({
    required super.request,
    required super.resetRequest,
    super.step,
  });
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String error;
  ForgotPasswordFailure({
    required this.error,
    required super.request,
    required super.resetRequest,
    super.step,
  });
}
