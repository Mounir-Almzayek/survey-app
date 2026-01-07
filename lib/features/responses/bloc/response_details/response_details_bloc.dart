import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/response_details.dart';
import '../../repository/responses_local_repository.dart';
import '../../repository/responses_online_repository.dart';

part 'response_details_event.dart';
part 'response_details_state.dart';

class ResponseDetailsBloc
    extends Bloc<ResponseDetailsEvent, ResponseDetailsState> {
  ResponseDetailsBloc() : super(ResponseDetailsInitial()) {
    on<LoadResponseDetails>(_onLoadDetails);
  }

  Future<void> _onLoadDetails(
    LoadResponseDetails event,
    Emitter<ResponseDetailsState> emit,
  ) async {
    emit(ResponseDetailsLoading());

    try {
      if (!event.forceRefresh) {
        final cached =
            await ResponsesLocalRepository.getCachedResponseDetails(
          event.responseId,
        );
        if (cached != null) {
          emit(ResponseDetailsLoaded(cached));
        }
      }

      final online =
          await ResponsesOnlineRepository.getResponseDetails(
        event.responseId,
      );
      await ResponsesLocalRepository.saveResponseDetails(online);
      emit(ResponseDetailsLoaded(online));
    } catch (e) {
      if (state is! ResponseDetailsLoaded) {
        emit(ResponseDetailsError(e.toString()));
      }
    }
  }
}


