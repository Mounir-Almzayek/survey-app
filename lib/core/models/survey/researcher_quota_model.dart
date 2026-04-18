import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';
import '../../l10n/generated/l10n.dart';
import 'assignment_model.dart';

/// ResearcherQuota Model - For quota tracking
class ResearcherQuota extends Equatable {
  /// Backend quota row id (may mirror [id] when API sends `quota_id`).
  final int quotaId;
  final int id;
  final int assignmentId;
  final Gender gender;
  final AgeGroup ageGroup;
  final int target;
  final int progress;
  final int collected;
  final num progressPercent;
  /// When set, reflects the API `remaining` value (authoritative over [target]-[progress]).
  final int? serverRemaining;
  /// Optional per-demographic count from API (`responses_count`).
  final int? responsesCountInCategory;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final Assignment? assignment;

  const ResearcherQuota({
    this.quotaId = 0,
    required this.id,
    required this.assignmentId,
    required this.gender,
    required this.ageGroup,
    required this.target,
    this.progress = 0,
    this.collected = 0,
    this.progressPercent = 0,
    this.serverRemaining,
    this.responsesCountInCategory,
    required this.createdAt,
    required this.updatedAt,
    this.assignment,
  });

  ResearcherQuota copyWith({
    int? quotaId,
    int? id,
    int? assignmentId,
    Gender? gender,
    AgeGroup? ageGroup,
    int? target,
    int? progress,
    int? collected,
    num? progressPercent,
    int? serverRemaining,
    bool clearServerRemaining = false,
    int? responsesCountInCategory,
    bool clearResponsesCountInCategory = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    Assignment? assignment,
  }) {
    return ResearcherQuota(
      quotaId: quotaId ?? this.quotaId,
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      collected: collected ?? this.collected,
      progressPercent: progressPercent ?? this.progressPercent,
      serverRemaining: clearServerRemaining ? null : (serverRemaining ?? this.serverRemaining),
      responsesCountInCategory: clearResponsesCountInCategory
          ? null
          : (responsesCountInCategory ?? this.responsesCountInCategory),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignment: assignment ?? this.assignment,
    );
  }

  factory ResearcherQuota.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'] as int? ?? json['quota_id'] as int? ?? 0;
    final quotaIdVal = json['quota_id'] as int? ?? idVal;
    final targetVal = json['target'] as int? ?? json['limit'] as int? ?? 0;
    final progressVal = json['progress'] as int? ?? json['used'] as int? ?? 0;
    final collectedVal =
        json['collected'] as int? ?? json['used'] as int? ?? progressVal;
    int? parseOptionalInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.round();
      return int.tryParse(v.toString());
    }

    final serverRem = parseOptionalInt(json['remaining']);
    final respCount = parseOptionalInt(json['responses_count']);

    return ResearcherQuota(
      quotaId: quotaIdVal,
      id: idVal,
      assignmentId: json['assignment_id'] as int? ?? 0,
      gender: Gender.fromJson(json['gender']),
      ageGroup: AgeGroup.fromJson(json['age_group']),
      target: targetVal,
      progress: progressVal,
      collected: collectedVal,
      progressPercent: (json['progress_percent'] as num?) ?? 0,
      serverRemaining: serverRem,
      responsesCountInCategory: respCount,
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
      'quota_id': quotaId,
      'id': id,
      'assignment_id': assignmentId,
      'gender': gender.toJson(),
      'age_group': ageGroup.toJson(),
      'target': target,
      'progress': progress,
      'collected': collected,
      'progress_percent': progressPercent,
      if (serverRemaining != null) 'remaining': serverRemaining,
      if (responsesCountInCategory != null)
        'responses_count': responsesCountInCategory,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'assignment': assignment?.toJson(),
    };
  }

  /// Remaining slots: prefers API [serverRemaining] when present.
  int get remaining {
    if (serverRemaining != null) return serverRemaining!;
    if (target <= 0) return 0;
    final diff = target - progress;
    return diff < 0 ? 0 : diff;
  }

  /// True when this demographic bucket cannot accept more responses (server-first).
  bool get isQuotaFull {
    if (target <= 0) return false;
    if (serverRemaining != null) return serverRemaining! <= 0;
    return progress >= target;
  }

  /// Check if quota is completed
  bool get isCompleted => isQuotaFull;

  /// Get completion percentage (prefers API [progressPercent] when non-zero).
  double get completionPercentage {
    if (target <= 0) return 0;
    if (progressPercent > 0) {
      return progressPercent.toDouble().clamp(0, 100);
    }
    return ((progress / target) * 100).clamp(0, 100);
  }

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
    quotaId,
    id,
    assignmentId,
    gender,
    ageGroup,
    target,
    progress,
    collected,
    progressPercent,
    serverRemaining,
    responsesCountInCategory,
    createdAt,
    updatedAt,
    assignment,
  ];
}
