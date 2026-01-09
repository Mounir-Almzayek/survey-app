import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/surveys_online_repository.dart';
import 'assigned_surveys_event.dart';
import 'assigned_surveys_state.dart';

class AssignedSurveysBloc
    extends Bloc<AssignedSurveysEvent, AssignedSurveysState> {
  AssignedSurveysBloc() : super(AssignedSurveysInitial()) {
    on<LoadAssignedSurveys>(_onLoadAssignedSurveys);
    on<RefreshAssignedSurveys>(_onLoadAssignedSurveys);
  }

  Future<void> _onLoadAssignedSurveys(
    AssignedSurveysEvent event,
    Emitter<AssignedSurveysState> emit,
  ) async {
    if (event is LoadAssignedSurveys) {
      emit(AssignedSurveysLoading());
    }

    try {
      final surveys = await SurveysOnlineRepository.getAssignedSurveys();
      emit(AssignedSurveysLoaded(surveys));
    } catch (e) {
      emit(AssignedSurveysError(e.toString()));
    }
  }
}
