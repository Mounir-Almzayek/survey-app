import 'package:equatable/equatable.dart';

class SurveyStatsModel extends Equatable {
  final int totalSurveys;
  final int activeSurveys;
  final int expiredSurveys;
  final int upcomingSurveys;
  final int draftResponses;
  final int pendingSyncResponses;
  final int syncedResponses;

  const SurveyStatsModel({
    required this.totalSurveys,
    required this.activeSurveys,
    required this.expiredSurveys,
    required this.upcomingSurveys,
    required this.draftResponses,
    required this.pendingSyncResponses,
    required this.syncedResponses,
  });

  factory SurveyStatsModel.empty() {
    return const SurveyStatsModel(
      totalSurveys: 0,
      activeSurveys: 0,
      expiredSurveys: 0,
      upcomingSurveys: 0,
      draftResponses: 0,
      pendingSyncResponses: 0,
      syncedResponses: 0,
    );
  }

  @override
  List<Object?> get props => [
    totalSurveys,
    activeSurveys,
    expiredSurveys,
    upcomingSurveys,
    draftResponses,
    pendingSyncResponses,
    syncedResponses,
  ];
}
