import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../repository/device_registration_repository.dart';
import '../../models/verify_key_response.dart';
import 'verify_key_event.dart';
import 'verify_key_state.dart';

class VerifyKeyBloc extends Bloc<VerifyKeyEvent, VerifyKeyState> {
  final AsyncRunner<VerifyKeyResponse> _verifyRunner =
      AsyncRunner<VerifyKeyResponse>();

  VerifyKeyBloc() : super(VerifyKeyInitial()) {
    on<VerifyKey>(_onVerifyKey);
  }

  Future<void> _onVerifyKey(
    VerifyKey event,
    Emitter<VerifyKeyState> emit,
  ) async {
    if (kDebugMode) {
      print('VerifyKeyBloc: Starting verification for keyId: ${event.keyId}');
    }
    emit(VerifyKeyLoading());

    await _verifyRunner.run(
      onlineTask: (_) async {
        return await DeviceRegistrationRepository.verifyKey(
          keyId: event.keyId,
        );
      },
      checkConnectivity: true,
      onSuccess: (response) {
        if (kDebugMode) {
          print('VerifyKeyBloc: Verification successful. Valid: ${response.valid}');
        }
        if (!emit.isDone) {
          emit(VerifyKeySuccess(response: response));
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('VerifyKeyBloc: Verification failed: $error');
        }
        if (!emit.isDone) {
          emit(VerifyKeyFailure(message: error.toString()));
        }
      },
    );
  }
}

