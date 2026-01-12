import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/start_response_model.dart';
import '../../repository/assignment_repository.dart';
import '../../repository/assignment_local_repository.dart';
import '../../../../core/utils/async_runner.dart';

part 'start_response_event.dart';
part 'start_response_state.dart';

class StartResponseBloc extends Bloc<StartResponseEvent, StartResponseState> {
  final AsyncRunner<StartResponseResponse> _runner =
      AsyncRunner<StartResponseResponse>();

  StartResponseBloc() : super(StartResponseInitial()) {
    on<UpdateSurveyId>(_onUpdateSurveyId);
    on<StartSurveyResponse>(_onStartResponse);
  }

  void _onUpdateSurveyId(
    UpdateSurveyId event,
    Emitter<StartResponseState> emit,
  ) {
    emit(StartResponseInitial(surveyId: event.surveyId));
  }

  Future<void> _onStartResponse(
    StartSurveyResponse event,
    Emitter<StartResponseState> emit,
  ) async {
    final surveyId = state.surveyId;
    if (surveyId == null) {
      emit(StartResponseError("Survey ID is required", surveyId: null));
      return;
    }

    emit(StartResponseLoading(surveyId: surveyId));

    await _runner.run(
      onlineTask: (_) async =>
          await AssignmentRepository.startResponse(surveyId),
      checkConnectivity: true,
      onSuccess: (response) async {
        // Link the new response ID to the survey in local storage
        await AssignmentLocalRepository.linkResponseToSurvey(
          surveyId,
          response.response.id,
        );
        if (!emit.isDone) {
          emit(StartResponseSuccess(response, surveyId: surveyId));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(StartResponseError(error.toString(), surveyId: surveyId));
        }
      },
    );
  }
}
