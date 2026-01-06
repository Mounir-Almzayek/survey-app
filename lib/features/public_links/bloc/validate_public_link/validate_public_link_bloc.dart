import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../models/public_link.dart';
import '../../repository/public_links_online_repository.dart';
import 'validate_public_link_event.dart';
import 'validate_public_link_state.dart';

/// Bloc for validating public links
/// Uses AsyncRunner for all operations
class ValidatePublicLinkBloc extends Bloc<ValidatePublicLinkEvent, ValidatePublicLinkState> {
  final AsyncRunner<PublicLink> _validateLinkRunner = AsyncRunner<PublicLink>();

  ValidatePublicLinkBloc() : super(const ValidatePublicLinkInitial()) {
    on<ValidatePublicLink>(_onValidatePublicLink);
  }

  Future<void> _onValidatePublicLink(
    ValidatePublicLink event,
    Emitter<ValidatePublicLinkState> emit,
  ) async {
    emit(const ValidatePublicLinkLoading());

    await _validateLinkRunner.run(
      onlineTask: (_) async {
        return await PublicLinksOnlineRepository.validatePublicLink(event.shortCode);
      },
      checkConnectivity: true,
      onSuccess: (link) {
        if (!emit.isDone) {
          emit(ValidatePublicLinkSuccess(link));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(ValidatePublicLinkError(error.toString()));
        }
      },
    );
  }
}

