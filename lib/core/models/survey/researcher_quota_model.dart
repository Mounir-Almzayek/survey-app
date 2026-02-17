import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';
import '../../l10n/generated/l10n.dart';
import 'assignment_model.dart';

/// ResearcherQuota Model - For quota tracking
class ResearcherQuota extends Equatable {
  final int id;
  final int assignmentId;
  final Gender gender;
  final AgeGroup ageGroup;
  final int target;
  final int progress;
  final int collected;
  final num progressPercent;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final Assignment? assignment;

  const ResearcherQuota({
    required this.id,
    required this.assignmentId,
    required this.gender,
    required this.ageGroup,
    required this.target,
    this.progress = 0,
    this.collected = 0,
    this.progressPercent = 0,
    required this.createdAt,
    required this.updatedAt,
    this.assignment,
  });

  ResearcherQuota copyWith({
    int? id,
    int? assignmentId,
    Gender? gender,
    AgeGroup? ageGroup,
    int? target,
    int? progress,
    int? collected,
    num? progressPercent,
    DateTime? createdAt,
    DateTime? updatedAt,
    Assignment? assignment,
  }) {
    return ResearcherQuota(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      collected: collected ?? this.collected,
      progressPercent: progressPercent ?? this.progressPercent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignment: assignment ?? this.assignment,
    );
  }

  factory ResearcherQuota.fromJson(Map<String, dynamic> json) {
    return ResearcherQuota(
      id: json['id'] as int? ?? 0,
      assignmentId: json['assignment_id'] as int? ?? 0,
      gender: Gender.fromJson(json['gender']),
      ageGroup: AgeGroup.fromJson(json['age_group']),
      target: json['target'] as int? ?? 0,
      progress: json['progress'] as int? ?? 0,
      collected: json['collected'] as int? ?? 0,
      progressPercent: (json['progress_percent'] as num?) ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      assignment: json['assignment'] != null
          ? Assignment.fromJson(json['assignment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'gender': gender.toJson(),
      'age_group': ageGroup.toJson(),
      'target': target,
      'progress': progress,
      'collected': collected,
      'progress_percent': progressPercent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'assignment': assignment?.toJson(),
    };
  }

  /// Get remaining quota
  int get remaining => target - progress;

  /// Check if quota is completed
  bool get isCompleted => progress >= target;

  /// Get completion percentage
  double get completionPercentage => target > 0 ? (progress / target) * 100 : 0;

  /// Check if quota is nearly complete (>= 80%)
  bool get isNearlyComplete => completionPercentage >= 80;

  /// Get quota status description
  String get statusDescription {
    if (isCompleted) return 'Completed';
    if (isNearlyComplete) return 'Nearly Complete';
    if (progress > 0) return 'In Progress';
    return 'Not Started';
  }

  /// Get localized quota status description
  String localizedStatusDescription(S s) {
    if (isCompleted) return s.completed;
    if (isNearlyComplete) return s.nearly_complete;
    if (progress > 0) return s.in_progress;
    return s.not_started;
  }

  /// Opacity (0.0–1.0) for primary color in progress UI based on state.
  double get progressDisplayAlpha {
    if (isCompleted) return 1.0;
    if (isNearlyComplete) return 0.85;
    if (progress > 0) return 0.65;
    return 0.45;
  }

  /// Get demographic description
  String get demographicDescription {
    String genderText = gender == Gender.male ? 'Male' : 'Female';
    String ageText = ageGroup
        .toJson()
        .replaceAll('AGE_', '')
        .replaceAll('_', '-')
        .replaceAll('PLUS', '+');
    return '$genderText ($ageText)';
  }

  /// Get localized demographic description
  String localizedDemographicDescription(S s) {
    return '${gender.localized(s)} (${ageGroup.localized(s)})';
  }

  @override
  List<Object?> get props => [
    id,
    assignmentId,
    gender,
    ageGroup,
    target,
    progress,
    collected,
    progressPercent,
    createdAt,
    updatedAt,
    assignment,
  ];
}
