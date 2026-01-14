import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../assignment/repository/assignment_local_repository.dart';
import '../../models/survey_stats_model.dart';
import 'home_stats_event.dart';
import 'home_stats_state.dart';

class HomeStatsBloc extends Bloc<HomeStatsEvent, HomeStatsState> {
  HomeStatsBloc() : super(HomeStatsInitial()) {
    on<LoadHomeStats>(_onLoadHomeStats);
  }

  Future<void> _onLoadHomeStats(
    LoadHomeStats event,
    Emitter<HomeStatsState> emit,
  ) async {
    emit(HomeStatsLoading());

    try {
      // Fetch data from local storage only to ensure speed and offline capability
      final localSurveys = await AssignmentLocalRepository.getSurveys();

      int totalAssignments = localSurveys.length;
      int offlineDrafts = 0;

      // Calculate local drafts from the cached surveys list
      for (var survey in localSurveys) {
        offlineDrafts += survey.localResponseIds?.length ?? 0;
      }

      // Currently synced responses are assumed to be 0 or fetched from local logs if available in future
      int syncedResponses = 0;

      double completionRate = totalAssignments > 0
          ? (syncedResponses / totalAssignments) * 100
          : 0.0;

      final stats = SurveyStatsModel(
        totalAssignments: totalAssignments,
        offlineDrafts: offlineDrafts,
        syncedResponses: syncedResponses,
        completionRate: completionRate,
      );

      emit(HomeStatsLoaded(stats));
    } catch (e) {
      emit(HomeStatsError(e.toString()));
    }
  }
}
