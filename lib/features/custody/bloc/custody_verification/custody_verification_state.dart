import 'package:equatable/equatable.dart';
import '../../models/custody_record.dart';

/// States for Custody Verification Bloc
abstract class CustodyVerificationState extends Equatable {
  const CustodyVerificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CustodyVerificationInitial extends CustodyVerificationState {
  const CustodyVerificationInitial();
}

/// Verifying state
class CustodyVerificationVerifying extends CustodyVerificationState {
  const CustodyVerificationVerifying();
}

/// Resending code state
class CustodyVerificationResending extends CustodyVerificationState {
  const CustodyVerificationResending();
}

/// Verification success state
class CustodyVerificationSuccess extends CustodyVerificationState {
  final CustodyRecord record;

  const CustodyVerificationSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

/// Resend success state
class CustodyVerificationResendSuccess extends CustodyVerificationState {
  final CustodyRecord record;

  const CustodyVerificationResendSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

/// Error state
class CustodyVerificationError extends CustodyVerificationState {
  final String message;

  const CustodyVerificationError(this.message);

  @override
  List<Object?> get props => [message];
}

