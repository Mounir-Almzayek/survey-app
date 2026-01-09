part of 'email_verification_bloc.dart';

abstract class EmailVerificationState {
  final EmailVerificationRequest request;

  EmailVerificationState({required this.request});

  String get email => request.email;
  String get code => request.code;
}

class EmailVerificationInitial extends EmailVerificationState {
  EmailVerificationInitial({required super.request});
}

class EmailVerificationLoading extends EmailVerificationState {
  EmailVerificationLoading({required super.request});
}

class EmailVerificationSuccess extends EmailVerificationState {
  EmailVerificationSuccess({required super.request});
}

class EmailVerificationFailure extends EmailVerificationState {
  final String error;
  EmailVerificationFailure({required this.error, required super.request});
}

class CodeResendSuccess extends EmailVerificationState {
  CodeResendSuccess({required super.request});
}
