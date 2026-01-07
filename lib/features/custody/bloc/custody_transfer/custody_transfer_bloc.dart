import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../models/custody_record.dart';
import '../../repository/custody_online_repository.dart';
import '../../repository/custody_local_repository.dart';
import 'custody_transfer_event.dart';
import 'custody_transfer_state.dart';

/// Bloc for creating custody transfers
/// Uses AsyncRunner for all operations
class CustodyTransferBloc
    extends Bloc<CustodyTransferEvent, CustodyTransferState> {
  final AsyncRunner<CustodyRecord> _createTransferRunner =
      AsyncRunner<CustodyRecord>();

  CustodyTransferBloc() : super(const CustodyTransferInitial()) {
    on<CreateCustodyTransfer>(_onCreateCustodyTransfer);
    on<ResetCustodyTransfer>(_onResetCustodyTransfer);
  }

  Future<void> _onCreateCustodyTransfer(
    CreateCustodyTransfer event,
    Emitter<CustodyTransferState> emit,
  ) async {
    emit(const CustodyTransferLoading());

    await _createTransferRunner.run(
      onlineTask: (_) async {
        return await CustodyOnlineRepository.createCustodyTransfer(
          event.transfer,
        );
      },
      checkConnectivity: true,
      onSuccess: (record) async {
        // Save to local storage
        await CustodyLocalRepository.saveCustodyRecord(record);

        if (!emit.isDone) {
          emit(CustodyTransferSuccess(record));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(CustodyTransferError(error.toString()));
        }
      },
    );
  }

  Future<void> _onResetCustodyTransfer(
    ResetCustodyTransfer event,
    Emitter<CustodyTransferState> emit,
  ) async {
    emit(const CustodyTransferInitial());
  }

  @override
  Future<void> close() {
    _createTransferRunner.cancel();
    return super.close();
  }
}

