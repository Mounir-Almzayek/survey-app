import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_runner.dart';
import '../../models/validated_public_link.dart';
import '../../repository/public_links_repository.dart';
import 'validate_public_link_event.dart';
import 'validate_public_link_state.dart';

/// Bloc for validating public links
/// Uses AsyncRunner for all operations
class ValidatePublicLinkBloc
    extends Bloc<ValidatePublicLinkEvent, ValidatePublicLinkState> {
  final AsyncRunner<ValidatedPublicLink> _validateLinkRunner =
      AsyncRunner<ValidatedPublicLink>();

  ValidatePublicLinkBloc() : super(const ValidatePublicLinkInitial()) {
    on<ValidatePublicLink>(_onValidatePublicLink);
  }

  Future<void> _onValidatePublicLink(
    ValidatePublicLink event,
    Emitter<ValidatePublicLinkState> emit,
  ) async {
    emit(ValidatePublicLinkLoading(shortCode: event.shortCode));

    await _validateLinkRunner.run(
      onlineTask: (_) async {
        return await PublicLinksRepository.validatePublicLink(
          event.shortCode,
        );
      },
      checkConnectivity: true,
      onSuccess: (link) {
        if (!emit.isDone) {
          emit(ValidatePublicLinkSuccess(link, shortCode: event.shortCode));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(ValidatePublicLinkError(error.toString(), shortCode: event.shortCode));
        }
      },
    );
  }
}
