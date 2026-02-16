import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/queue/services/request_queue_manager.dart';
import '../../../assignment/repository/assignment_local_repository.dart';
import '../../models/survey_stats_model.dart';
import '../../../../core/models/survey/survey_model.dart';
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
      // 1. Fetch surveys from local storage
      final localSurveys = await AssignmentLocalRepository.getSurveys();

      final now = DateTime.now();
      int activeSurveys = 0;
      int expiredSurveys = 0;
      int upcomingSurveys = 0;
      int draftResponses = 0;

      for (var survey in localSurveys) {
        // Categorize by availability
        final start = survey.availabilityStartAt;
        final end = survey.availabilityEndAt;

        if (start != null && start.isAfter(now)) {
          upcomingSurveys++;
        } else if (end != null && end.isBefore(now)) {
          expiredSurveys++;
        } else {
          activeSurveys++;
        }

        // Count drafts
        draftResponses += survey.localResponseIds?.length ?? 0;
      }

      // 2. Get pending sync count from RequestQueueManager
      final queueStatus = await RequestQueueManager().getStatus();
      final pendingSyncResponses = queueStatus.queueLength;

      // 3. Get total synced responses from persistent counter
      final syncedResponses =
          await AssignmentLocalRepository.getSyncedResponsesCount();

      // 4. Calculate Quota and Demographic Stats
      List<Survey> surveysWithQuotas = [];
      Map<String, double> genderProgress = {};
      Map<String, double> ageGroupProgress = {};

      // Temporary counters for aggregation
      Map<String, int> genderTargets = {};
      Map<String, int> genderCollected = {};
      Map<String, int> ageTargets = {};
      Map<String, int> ageCollected = {};

      for (var survey in localSurveys) {
        if (survey.assignments != null &&
            survey.assignments!.isNotEmpty &&
            survey.assignments!.first.researcherQuotas != null &&
            survey.assignments!.first.researcherQuotas!.isNotEmpty) {
          surveysWithQuotas.add(survey);

          for (var quota in survey.assignments!.first.researcherQuotas!) {
            // Gender Stats
            String genderKey = quota.gender.name; // assuming Enum has name
            genderTargets[genderKey] =
                (genderTargets[genderKey] ?? 0) + quota.target;
            genderCollected[genderKey] =
                (genderCollected[genderKey] ?? 0) + quota.progress;

            // Age Group Stats
            String ageKey = quota.ageGroup.name; // assuming Enum has name
            ageTargets[ageKey] = (ageTargets[ageKey] ?? 0) + quota.target;
            ageCollected[ageKey] = (ageCollected[ageKey] ?? 0) + quota.progress;
          }
        }
      }

      // Calculate Percentages
      genderTargets.forEach((key, target) {
        if (target > 0) {
          genderProgress[key] = (genderCollected[key] ?? 0) / target;
        } else {
          genderProgress[key] = 0.0;
        }
      });

      ageTargets.forEach((key, target) {
        if (target > 0) {
          ageGroupProgress[key] = (ageCollected[key] ?? 0) / target;
        } else {
          ageGroupProgress[key] = 0.0;
        }
      });

      final stats = SurveyStatsModel(
        totalSurveys: localSurveys.length,
        activeSurveys: activeSurveys,
        expiredSurveys: expiredSurveys,
        upcomingSurveys: upcomingSurveys,
        draftResponses: draftResponses,
        pendingSyncResponses: pendingSyncResponses,
        syncedResponses: syncedResponses,
        surveysWithQuotas: surveysWithQuotas,
        genderProgress: genderProgress,
        ageGroupProgress: ageGroupProgress,
      );

      emit(HomeStatsLoaded(stats));
    } catch (e) {
      emit(HomeStatsError(e.toString()));
    }
  }
}
