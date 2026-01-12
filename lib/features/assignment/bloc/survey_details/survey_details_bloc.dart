import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/assignment_response_model.dart';
import '../../repository/assignment_repository.dart';
import '../../repository/assignment_local_repository.dart';
import '../../../../core/utils/async_runner.dart';

part 'survey_details_event.dart';
part 'survey_details_state.dart';

class SurveyDetailsBloc extends Bloc<SurveyDetailsEvent, SurveyDetailsState> {
  final AsyncRunner<GetSurveyAssignmentResponse> _runner =
      AsyncRunner<GetSurveyAssignmentResponse>();

  SurveyDetailsBloc() : super(SurveyDetailsInitial()) {
    on<UpdateSurveyIdForDetails>(_onUpdateSurveyId);
    on<LoadSurveyDetails>(_onLoadSurveyDetails);
  }

  void _onUpdateSurveyId(
    UpdateSurveyIdForDetails event,
    Emitter<SurveyDetailsState> emit,
  ) {
    emit(SurveyDetailsInitial(surveyId: event.surveyId));
  }

  Future<void> _onLoadSurveyDetails(
    LoadSurveyDetails event,
    Emitter<SurveyDetailsState> emit,
  ) async {
    final surveyId = state.surveyId;
    if (surveyId == null) {
      emit(SurveyDetailsError("Survey ID is required", surveyId: null));
      return;
    }

    emit(SurveyDetailsLoading(surveyId: surveyId));

    await _runner.run(
      onlineTask: (_) async =>
          await AssignmentRepository.getSurveyDetails(surveyId),
      offlineTask: (_) async {
        final local = await AssignmentLocalRepository.getSurveyById(surveyId);
        if (local == null) throw Exception("Survey data not available offline");
        return GetSurveyAssignmentResponse(success: true, survey: local);
      },
      checkConnectivity: true,
      onSuccess: (response) async {
        await AssignmentLocalRepository.updateSurvey(response.survey);
        if (!emit.isDone) {
          emit(SurveyDetailsLoaded(response, surveyId: surveyId));
        }
      },
      onOffline: (response) {
        if (!emit.isDone) {
          emit(SurveyDetailsLoaded(response, surveyId: surveyId));
        }
      },
      onError: (error) {
        if (!emit.isDone && state is! SurveyDetailsLoaded) {
          emit(SurveyDetailsError(error.toString(), surveyId: surveyId));
        }
      },
    );
  }
}
