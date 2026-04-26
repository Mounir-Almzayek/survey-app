import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/survey_enums.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/queue/services/request_queue_manager.dart';
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
      // 1. Fetch surveys from local storage
      final localSurveys = await AssignmentLocalRepository.getSurveys();

      final now = DateTime.now();
      int activeSurveys = 0;
      int expiredSurveys = 0;
      int upcomingSurveys = 0;
      int draftResponses = 0;

      for (var survey in localSurveys) {
        final start = survey.availabilityStartAt;
        final end = survey.availabilityEndAt;

        if (start != null && start.isAfter(now)) {
          upcomingSurveys++;
        } else if (end != null && end.isBefore(now)) {
          expiredSurveys++;
        } else {
          activeSurveys++;
        }

        draftResponses += survey.localResponseIds?.length ?? 0;
      }

      // 2. Pending sync count
      final queueStatus = await RequestQueueManager().getStatus();
      final pendingSyncResponses = queueStatus.queueLength;

      // 3. Persistent synced count
      final syncedResponses =
          await AssignmentLocalRepository.getSyncedResponsesCount();

      // 4. Per-survey quota breakdown (replaces gender/age aggregation)
      final surveysWithQuotas = <Survey>[];
      final breakdownBySurveyId = <int, List<QuotaBreakdownEntry>>{};

      for (final survey in localSurveys) {
        final assignments = survey.assignments;
        if (assignments == null || assignments.isEmpty) continue;
        final quotas = assignments.first.researcherQuotas;
        if (quotas == null || quotas.isEmpty) continue;

        surveysWithQuotas.add(survey);
        breakdownBySurveyId[survey.id] = _buildBreakdown(survey);
      }

      final stats = SurveyStatsModel(
        totalSurveys: localSurveys.length,
        activeSurveys: activeSurveys,
        expiredSurveys: expiredSurveys,
        upcomingSurveys: upcomingSurveys,
        draftResponses: draftResponses,
        pendingSyncResponses: pendingSyncResponses,
        syncedResponses: syncedResponses,
        surveysWithQuotas: surveysWithQuotas,
        breakdownBySurveyId: breakdownBySurveyId,
      );

      emit(HomeStatsLoaded(stats));
    } catch (e) {
      emit(HomeStatsError(e.toString()));
    }
  }

  /// Build the breakdown rows for a single survey.
  /// TEST_MODE surveys contribute zero rows (server returns 0; mirror locally).
  static List<QuotaBreakdownEntry> _buildBreakdown(Survey survey) {
    if (survey.status == SurveyStatus.testMode) return const [];
    final assignment = survey.assignments?.firstOrNull;
    if (assignment == null) return const [];
    final quotas = assignment.researcherQuotas;
    if (quotas == null || quotas.isEmpty) return const [];

    final entries = <QuotaBreakdownEntry>[];
    for (final q in quotas) {
      if (q.quotaTargetId == null) continue;
      entries.add(QuotaBreakdownEntry(
        quotaTargetId: q.quotaTargetId,
        displayLabel: q.displayLabel,
        progress: q.progress,
        target: q.target,
        progressPercent: q.completionPercentage,
      ));
    }
    entries.sort((a, b) {
      final cmp = b.progressPercent.compareTo(a.progressPercent);
      if (cmp != 0) return cmp;
      return a.displayLabel.compareTo(b.displayLabel);
    });
    return entries;
  }
}
