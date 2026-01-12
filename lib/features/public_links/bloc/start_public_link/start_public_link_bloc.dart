import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_runner.dart';
import '../../models/start_public_link_response.dart';
import '../../models/start_public_link_request.dart';
import '../../repository/public_links_repository.dart';
import 'start_public_link_event.dart';
import 'start_public_link_state.dart';

/// Bloc for starting public link responses
/// Uses AsyncRunner for all operations
class StartPublicLinkBloc
    extends Bloc<StartPublicLinkEvent, StartPublicLinkState> {
  final AsyncRunner<StartPublicLinkResponse> _startResponseRunner =
      AsyncRunner<StartPublicLinkResponse>();

  StartPublicLinkBloc() : super(const StartPublicLinkInitial()) {
    on<StartPublicLinkResponseEvent>(_onStartPublicLinkResponse);
  }

  Future<void> _onStartPublicLinkResponse(
    StartPublicLinkResponseEvent event,
    Emitter<StartPublicLinkState> emit,
  ) async {
    final request = event.request ?? const StartPublicLinkRequest();

    emit(StartPublicLinkLoading(shortCode: event.shortCode, request: request));

    await _startResponseRunner.run(
      onlineTask: (_) async {
        // Use the main Repository which handles both Online API and Local Active Response Index
        return await PublicLinksRepository.startPublicLinkResponse(
          event.shortCode,
          request: event.request,
        );
      },
      checkConnectivity: true,
      onSuccess: (response) {
        if (!emit.isDone) {
          emit(
            StartPublicLinkSuccess(
              response,
              shortCode: event.shortCode,
              request: request,
            ),
          );
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(
            StartPublicLinkError(
              error.toString(),
              shortCode: event.shortCode,
              request: request,
            ),
          );
        }
      },
    );
  }
}
