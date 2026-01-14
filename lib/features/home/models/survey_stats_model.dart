import 'package:equatable/equatable.dart';

class SurveyStatsModel extends Equatable {
  final int totalAssignments;
  final int offlineDrafts;
  final int syncedResponses;
  final double completionRate;

  const SurveyStatsModel({
    required this.totalAssignments,
    required this.offlineDrafts,
    required this.syncedResponses,
    required this.completionRate,
  });

  factory SurveyStatsModel.empty() {
    return const SurveyStatsModel(
      totalAssignments: 0,
      offlineDrafts: 0,
      syncedResponses: 0,
      completionRate: 0.0,
    );
  }

  @override
  List<Object?> get props => [
        totalAssignments,
        offlineDrafts,
        syncedResponses,
        completionRate,
      ];
}
