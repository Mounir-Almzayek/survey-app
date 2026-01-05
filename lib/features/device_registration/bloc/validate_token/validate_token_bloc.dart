import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../repository/device_registration_repository.dart';
import '../../models/validate_token_request.dart';
import '../../models/validate_token_response.dart';
import 'validate_token_event.dart';
import 'validate_token_state.dart';

class ValidateTokenBloc extends Bloc<ValidateTokenEvent, ValidateTokenState> {
  final AsyncRunner<ValidateTokenResponse> _validationRunner =
      AsyncRunner<ValidateTokenResponse>();

  ValidateTokenBloc() : super(ValidateTokenInitial()) {
    on<ValidateToken>(_onValidateToken);
  }

  Future<void> _onValidateToken(
    ValidateToken event,
    Emitter<ValidateTokenState> emit,
  ) async {
    final request = ValidateTokenRequest(token: event.token);
    emit(ValidateTokenLoading(request));

    await _validationRunner.run(
      onlineTask: (_) async {
        return await DeviceRegistrationRepository.validateToken(
          request: request,
        );
      },
      checkConnectivity: true,
      onSuccess: (response) {
        if (!emit.isDone) {
          emit(
            ValidateTokenSuccess(
              request: request,
              response: response,
              fingerprint: event.fingerprint,
            ),
          );
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(
            ValidateTokenFailure(request: request, message: error.toString()),
          );
        }
      },
    );
  }
}
