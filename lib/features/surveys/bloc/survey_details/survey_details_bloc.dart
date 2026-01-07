import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/survey.dart';
import '../../repository/surveys_local_repository.dart';
import '../../repository/surveys_online_repository.dart';

part 'survey_details_event.dart';
part 'survey_details_state.dart';

class SurveyDetailsBloc
    extends Bloc<SurveyDetailsEvent, SurveyDetailsState> {
  SurveyDetailsBloc() : super(SurveyDetailsInitial()) {
    on<LoadSurveyDetails>(_onLoadSurveyDetails);
  }

  Future<void> _onLoadSurveyDetails(
    LoadSurveyDetails event,
    Emitter<SurveyDetailsState> emit,
  ) async {
    emit(SurveyDetailsLoading());

    try {
      if (!event.forceRefresh) {
        final cached =
            await SurveysLocalRepository.getCachedSurvey(event.surveyId);
        if (cached != null) {
          emit(SurveyDetailsLoaded(cached));
        }
      }

      final online =
          await SurveysOnlineRepository.getSurveyDetails(event.surveyId);
      await SurveysLocalRepository.saveSurvey(online);
      emit(SurveyDetailsLoaded(online));
    } catch (e) {
      if (state is! SurveyDetailsLoaded) {
        emit(SurveyDetailsError(e.toString()));
      }
    }
  }
}


