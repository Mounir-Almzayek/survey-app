part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordEvent {}

class UpdateEmail extends ForgotPasswordEvent {
  final String email;
  UpdateEmail(this.email);
}

class UpdateCode extends ForgotPasswordEvent {
  final String code;
  UpdateCode(this.code);
}

class UpdateNewPassword extends ForgotPasswordEvent {
  final String password;
  UpdateNewPassword(this.password);
}

class RequestResetCode extends ForgotPasswordEvent {}

class ResetPassword extends ForgotPasswordEvent {}

class ChangeStep extends ForgotPasswordEvent {
  final ForgotPasswordStep step;
  ChangeStep(this.step);
}
