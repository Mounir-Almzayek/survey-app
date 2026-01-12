import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../models/public_link_active_response.dart';
import '../../repository/public_links_repository.dart';
import '../../repository/public_links_local_repository.dart';
import 'active_responses_event.dart';
import 'active_responses_state.dart';

class ActiveResponsesBloc extends Bloc<ActiveResponsesEvent, ActiveResponsesState> {
  final AsyncRunner<List<PublicLinkActiveResponse>> _runner =
      AsyncRunner<List<PublicLinkActiveResponse>>();

  ActiveResponsesBloc() : super(ActiveResponsesInitial()) {
    on<LoadActiveResponses>(_onLoadActiveResponses);
    on<RemoveActiveResponse>(_onRemoveActiveResponse);
  }

  Future<void> _onLoadActiveResponses(
    LoadActiveResponses event,
    Emitter<ActiveResponsesState> emit,
  ) async {
    emit(ActiveResponsesLoading());

    await _runner.run(
      onlineTask: (_) async => await PublicLinksRepository.getActiveResponses(),
      checkConnectivity: false, 
      onSuccess: (responses) {
        if (!emit.isDone) {
          emit(ActiveResponsesSuccess(responses));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(ActiveResponsesError(error.toString()));
        }
      },
    );
  }

  Future<void> _onRemoveActiveResponse(
    RemoveActiveResponse event,
    Emitter<ActiveResponsesState> emit,
  ) async {
    try {
      await PublicLinksLocalRepository.removeActiveResponse(event.shortCode);
      add(LoadActiveResponses());
    } catch (e) {
      if (!emit.isDone) {
        emit(ActiveResponsesError(e.toString()));
      }
    }
  }
}

