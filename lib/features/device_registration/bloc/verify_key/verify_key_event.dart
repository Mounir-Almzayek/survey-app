import 'package:equatable/equatable.dart';

abstract class VerifyKeyEvent extends Equatable {
  const VerifyKeyEvent();

  @override
  List<Object?> get props => [];
}

class VerifyKey extends VerifyKeyEvent {
  final String keyId;

  const VerifyKey({required this.keyId});

  @override
  List<Object?> get props => [keyId];
}

