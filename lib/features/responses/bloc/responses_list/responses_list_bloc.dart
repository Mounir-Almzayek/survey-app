import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_runner.dart';
import '../../../../features/assignment/repository/assignment_local_repository.dart';

part 'responses_list_event.dart';
part 'responses_list_state.dart';

class ResponsesListBloc extends Bloc<ResponsesListEvent, ResponsesListState> {
  final AsyncRunner<List<int>> _runner = AsyncRunner<List<int>>();

  ResponsesListBloc() : super(ResponsesListInitial()) {
    on<LoadResponsesForSurvey>(_onLoadResponses);
  }

  Future<void> _onLoadResponses(
    LoadResponsesForSurvey event,
    Emitter<ResponsesListState> emit,
  ) async {
    emit(ResponsesListLoading());

    await _runner.run(
      onlineTask: (_) async {
        // Fetch completed response IDs from local storage
        return await AssignmentLocalRepository.getCompletedResponses(
          event.surveyId,
        );
      },
      offlineTask: (_) async {
        return await AssignmentLocalRepository.getCompletedResponses(
          event.surveyId,
        );
      },
      onSuccess: (ids) {
        if (!emit.isDone) {
          emit(ResponsesListLoaded(ids));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(ResponsesListError(error.toString()));
        }
      },
      checkConnectivity: false,
    );
  }
}
