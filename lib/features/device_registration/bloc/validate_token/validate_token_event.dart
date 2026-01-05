import 'package:equatable/equatable.dart';
import '../../../../core/models/fingerprint.dart';

abstract class ValidateTokenEvent extends Equatable {
  const ValidateTokenEvent();

  @override
  List<Object?> get props => [];
}

class ValidateToken extends ValidateTokenEvent {
  final String token;
  final Fingerprint fingerprint;

  const ValidateToken({required this.token, required this.fingerprint});

  @override
  List<Object?> get props => [token, fingerprint];
}
