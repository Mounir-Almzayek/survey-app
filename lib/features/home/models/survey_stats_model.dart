import 'package:equatable/equatable.dart';
import '../../../core/models/survey/survey_model.dart';

/// One row of the per-survey breakdown shown on the Home dashboard.
/// Each row corresponds to a quota target the researcher is filling.
class QuotaBreakdownEntry extends Equatable {
  final int? quotaTargetId;
  final String displayLabel;
  final int progress;
  final int target;
  final num progressPercent;

  const QuotaBreakdownEntry({
    required this.quotaTargetId,
    required this.displayLabel,
    required this.progress,
    required this.target,
    required this.progressPercent,
  });

  @override
  List<Object?> get props =>
      [quotaTargetId, displayLabel, progress, target, progressPercent];
}

/// Aggregate stats shown on the Home dashboard.
class SurveyStatsModel extends Equatable {
  final int totalSurveys;
  final int activeSurveys;
  final int expiredSurveys;
  final int upcomingSurveys;
  final int draftResponses;
  final int pendingSyncResponses;
  final int syncedResponses;

  final List<Survey> surveysWithQuotas;

  /// Per-survey-card quota breakdown rows, keyed by `display_label` and
  /// sorted descending by `progressPercent` (tie-broken by displayLabel).
  /// Map key is the survey id; the value is the rows for that card.
  final Map<int, List<QuotaBreakdownEntry>> breakdownBySurveyId;

  const SurveyStatsModel({
    required this.totalSurveys,
    required this.activeSurveys,
    required this.expiredSurveys,
    required this.upcomingSurveys,
    required this.draftResponses,
    required this.pendingSyncResponses,
    required this.syncedResponses,
    this.surveysWithQuotas = const [],
    this.breakdownBySurveyId = const {},
  });

  factory SurveyStatsModel.empty() => const SurveyStatsModel(
    totalSurveys: 0,
    activeSurveys: 0,
    expiredSurveys: 0,
    upcomingSurveys: 0,
    draftResponses: 0,
    pendingSyncResponses: 0,
    syncedResponses: 0,
    surveysWithQuotas: [],
    breakdownBySurveyId: {},
  );

  @override
  List<Object?> get props => [
    totalSurveys,
    activeSurveys,
    expiredSurveys,
    upcomingSurveys,
    draftResponses,
    pendingSyncResponses,
    syncedResponses,
    surveysWithQuotas,
    breakdownBySurveyId,
  ];
}
