import 'package:equatable/equatable.dart';
import '../../models/custody_record.dart';

/// States for Custody Transfer Bloc
abstract class CustodyTransferState extends Equatable {
  const CustodyTransferState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CustodyTransferInitial extends CustodyTransferState {
  const CustodyTransferInitial();
}

/// Loading state
class CustodyTransferLoading extends CustodyTransferState {
  const CustodyTransferLoading();
}

/// Success state
class CustodyTransferSuccess extends CustodyTransferState {
  final CustodyRecord record;

  const CustodyTransferSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

/// Error state
class CustodyTransferError extends CustodyTransferState {
  final String message;

  const CustodyTransferError(this.message);

  @override
  List<Object?> get props => [message];
}

