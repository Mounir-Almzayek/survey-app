import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/response.dart';
import '../../repository/responses_local_repository.dart';
import '../../repository/responses_online_repository.dart';

part 'responses_list_event.dart';
part 'responses_list_state.dart';

class ResponsesListBloc
    extends Bloc<ResponsesListEvent, ResponsesListState> {
  ResponsesListBloc() : super(ResponsesListInitial()) {
    on<LoadResponsesForSurvey>(_onLoadResponses);
  }

  Future<void> _onLoadResponses(
    LoadResponsesForSurvey event,
    Emitter<ResponsesListState> emit,
  ) async {
    emit(ResponsesListLoading());

    try {
      if (!event.forceRefresh) {
        final cached =
            await ResponsesLocalRepository.getCachedSurveyResponses(
          event.surveyId,
        );
        if (cached.isNotEmpty) {
          emit(ResponsesListLoaded(cached));
        }
      }

      final online = await ResponsesOnlineRepository.getSurveyResponses(
        surveyId: event.surveyId,
      );
      await ResponsesLocalRepository.saveSurveyResponses(
        event.surveyId,
        online,
      );
      emit(ResponsesListLoaded(online));
    } catch (e) {
      if (state is! ResponsesListLoaded) {
        emit(ResponsesListError(e.toString()));
      }
    }
  }
}


