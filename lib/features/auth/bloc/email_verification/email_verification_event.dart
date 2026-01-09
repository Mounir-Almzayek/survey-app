part of 'email_verification_bloc.dart';

abstract class EmailVerificationEvent {}

class UpdateEmail extends EmailVerificationEvent {
  final String email;
  UpdateEmail(this.email);
}

class UpdateCode extends EmailVerificationEvent {
  final String code;
  UpdateCode(this.code);
}

class VerifyEmail extends EmailVerificationEvent {}

class ResendCode extends EmailVerificationEvent {}
