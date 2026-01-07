import 'package:equatable/equatable.dart';
import '../../models/verify_key_response.dart';

abstract class VerifyKeyState extends Equatable {
  const VerifyKeyState();

  @override
  List<Object?> get props => [];
}

class VerifyKeyInitial extends VerifyKeyState {}

class VerifyKeyLoading extends VerifyKeyState {}

class VerifyKeySuccess extends VerifyKeyState {
  final VerifyKeyResponse response;

  const VerifyKeySuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class VerifyKeyFailure extends VerifyKeyState {
  final String message;

  const VerifyKeyFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
