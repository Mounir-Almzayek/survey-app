import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/assignment.dart';
import '../../repository/surveys_local_repository.dart';
import '../../repository/surveys_online_repository.dart';

part 'assigned_surveys_event.dart';
part 'assigned_surveys_state.dart';

class AssignedSurveysBloc
    extends Bloc<AssignedSurveysEvent, AssignedSurveysState> {
  AssignedSurveysBloc() : super(AssignedSurveysInitial()) {
    on<LoadAssignedSurveys>(_onLoadAssignedSurveys);
  }

  Future<void> _onLoadAssignedSurveys(
    LoadAssignedSurveys event,
    Emitter<AssignedSurveysState> emit,
  ) async {
    emit(AssignedSurveysLoading());

    try {
      // Try local cache first (unless forceRefresh)
      if (!event.forceRefresh) {
        final cached = await SurveysLocalRepository.getCachedAssignments();
        if (cached.isNotEmpty) {
          emit(AssignedSurveysLoaded(cached));
        }
      }

      final online = await SurveysOnlineRepository.getResearcherAssignments();
      await SurveysLocalRepository.saveAssignments(online);
      emit(AssignedSurveysLoaded(online));
    } catch (e) {
      if (state is! AssignedSurveysLoaded) {
        emit(AssignedSurveysError(e.toString()));
      }
    }
  }
}


