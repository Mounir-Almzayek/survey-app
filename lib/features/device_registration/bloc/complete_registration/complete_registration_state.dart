import 'package:equatable/equatable.dart';
import '../../models/registration_method.dart';
import '../../models/complete_registration_response.dart';

abstract class CompleteRegistrationState extends Equatable {
  const CompleteRegistrationState();

  @override
  List<Object?> get props => [];
}

class CompleteRegistrationInitial extends CompleteRegistrationState {}

class CompleteRegistrationLoading extends CompleteRegistrationState {
  final RegistrationMethod method;

  const CompleteRegistrationLoading(this.method);

  @override
  List<Object?> get props => [method];
}

class WebAuthnChallengeLoading extends CompleteRegistrationState {
  const WebAuthnChallengeLoading();
}

class WebAuthnSigning extends CompleteRegistrationState {
  const WebAuthnSigning();
}

class WebAuthnFallbackToCookie extends CompleteRegistrationState {
  const WebAuthnFallbackToCookie();
}

class CompleteRegistrationSuccess extends CompleteRegistrationState {
  final CompleteRegistrationResponse response;

  const CompleteRegistrationSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class CompleteRegistrationFailure extends CompleteRegistrationState {
  final String message;

  const CompleteRegistrationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

