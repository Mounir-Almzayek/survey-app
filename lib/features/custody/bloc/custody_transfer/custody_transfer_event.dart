import 'package:equatable/equatable.dart';
import '../../models/custody_transfer.dart';

/// Events for Custody Transfer Bloc
abstract class CustodyTransferEvent extends Equatable {
  const CustodyTransferEvent();

  @override
  List<Object?> get props => [];
}

/// Create custody transfer
class CreateCustodyTransfer extends CustodyTransferEvent {
  final CustodyTransfer transfer;

  const CreateCustodyTransfer(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

/// Reset transfer state
class ResetCustodyTransfer extends CustodyTransferEvent {
  const ResetCustodyTransfer();
}
