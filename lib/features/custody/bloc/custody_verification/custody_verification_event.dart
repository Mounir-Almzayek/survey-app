import 'package:equatable/equatable.dart';

/// Events for Custody Verification Bloc
abstract class CustodyVerificationEvent extends Equatable {
  const CustodyVerificationEvent();

  @override
  List<Object?> get props => [];
}

/// Verify custody with code
class VerifyCustody extends CustodyVerificationEvent {
  final int custodyId;
  final String verificationCode;
  final String? notes;

  const VerifyCustody({
    required this.custodyId,
    required this.verificationCode,
    this.notes,
  });

  @override
  List<Object?> get props => [custodyId, verificationCode, notes];
}

/// Resend verification code
class ResendVerificationCode extends CustodyVerificationEvent {
  final int custodyId;

  const ResendVerificationCode(this.custodyId);

  @override
  List<Object?> get props => [custodyId];
}

/// Reset verification state
class ResetCustodyVerification extends CustodyVerificationEvent {
  const ResetCustodyVerification();
}

