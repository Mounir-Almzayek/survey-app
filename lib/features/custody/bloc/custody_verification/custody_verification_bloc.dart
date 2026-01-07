import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../models/custody_record.dart';
import '../../repository/custody_online_repository.dart';
import '../../repository/custody_local_repository.dart';
import 'custody_verification_event.dart';
import 'custody_verification_state.dart';

/// Bloc for verifying custody and resending codes
/// Uses AsyncRunner for all operations
class CustodyVerificationBloc
    extends Bloc<CustodyVerificationEvent, CustodyVerificationState> {
  final AsyncRunner<CustodyRecord> _verifyRunner =
      AsyncRunner<CustodyRecord>();
  final AsyncRunner<CustodyRecord> _resendRunner =
      AsyncRunner<CustodyRecord>();

  CustodyVerificationBloc() : super(const CustodyVerificationInitial()) {
    on<VerifyCustody>(_onVerifyCustody);
    on<ResendVerificationCode>(_onResendVerificationCode);
    on<ResetCustodyVerification>(_onResetCustodyVerification);
  }

  Future<void> _onVerifyCustody(
    VerifyCustody event,
    Emitter<CustodyVerificationState> emit,
  ) async {
    emit(const CustodyVerificationVerifying());

    await _verifyRunner.run(
      onlineTask: (_) async {
        return await CustodyOnlineRepository.verifyCustody(
          id: event.custodyId,
          verificationCode: event.verificationCode,
          notes: event.notes,
        );
      },
      checkConnectivity: true,
      onSuccess: (record) async {
        // Save to local storage
        await CustodyLocalRepository.saveCustodyRecord(record);

        if (!emit.isDone) {
          emit(CustodyVerificationSuccess(record));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(CustodyVerificationError(error.toString()));
        }
      },
    );
  }

  Future<void> _onResendVerificationCode(
    ResendVerificationCode event,
    Emitter<CustodyVerificationState> emit,
  ) async {
    emit(const CustodyVerificationResending());

    await _resendRunner.run(
      onlineTask: (_) async {
        return await CustodyOnlineRepository.resendVerificationCode(
          event.custodyId,
        );
      },
      checkConnectivity: true,
      onSuccess: (record) async {
        // Save to local storage
        await CustodyLocalRepository.saveCustodyRecord(record);

        if (!emit.isDone) {
          emit(CustodyVerificationResendSuccess(record));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(CustodyVerificationError(error.toString()));
        }
      },
    );
  }

  Future<void> _onResetCustodyVerification(
    ResetCustodyVerification event,
    Emitter<CustodyVerificationState> emit,
  ) async {
    emit(const CustodyVerificationInitial());
  }

  @override
  Future<void> close() {
    _verifyRunner.cancel();
    _resendRunner.cancel();
    return super.close();
  }
}

