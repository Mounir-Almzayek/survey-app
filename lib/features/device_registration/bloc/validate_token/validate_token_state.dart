import 'package:equatable/equatable.dart';
import '../../models/validate_token_request.dart';
import '../../models/validate_token_response.dart';
import '../../../../core/models/fingerprint.dart';

abstract class ValidateTokenState extends Equatable {
  final ValidateTokenRequest request;

  const ValidateTokenState(this.request);

  @override
  List<Object?> get props => [request];
}

class ValidateTokenInitial extends ValidateTokenState {
  const ValidateTokenInitial() : super(const ValidateTokenRequest(token: ''));
}

class ValidateTokenLoading extends ValidateTokenState {
  const ValidateTokenLoading(ValidateTokenRequest request) : super(request);
}

class ValidateTokenSuccess extends ValidateTokenState {
  final ValidateTokenResponse response;
  final Fingerprint fingerprint;

  const ValidateTokenSuccess({
    required ValidateTokenRequest request,
    required this.response,
    required this.fingerprint,
  }) : super(request);

  @override
  List<Object?> get props => [request, response, fingerprint];
}

class ValidateTokenFailure extends ValidateTokenState {
  final String message;

  const ValidateTokenFailure({
    required ValidateTokenRequest request,
    required this.message,
  }) : super(request);

  @override
  List<Object?> get props => [request, message];
}
