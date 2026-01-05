import 'package:equatable/equatable.dart';
import '../../../../core/models/fingerprint.dart';
import '../../models/registration_method.dart';

abstract class CompleteRegistrationEvent extends Equatable {
  const CompleteRegistrationEvent();

  @override
  List<Object?> get props => [];
}

class CompleteRegistration extends CompleteRegistrationEvent {
  final String token;
  final Fingerprint fingerprint;
  final RegistrationMethod method;

  const CompleteRegistration({
    required this.token,
    required this.fingerprint,
    required this.method,
  });

  @override
  List<Object?> get props => [token, fingerprint, method];
}

