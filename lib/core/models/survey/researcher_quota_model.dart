import 'package:equatable/equatable.dart';
import 'assignment_model.dart';
import 'quota_coordinate.dart';

/// ResearcherQuota — one cell of a researcher's assigned quota plan.
///
/// The bucket is identified by [quotaTargetId] (NULL when no target is
/// resolved yet). [coordinates] describe the bucket's `(criterion, category)`
/// axes; [displayLabel] is a server-built human-readable summary in Arabic.
class ResearcherQuota extends Equatable {
  /// Backend quota row id (may mirror [id] when API sends `quota_id`).
  final int quotaId;
  final int id;
  final int assignmentId;

  /// Identifier of the matching `QuotaTarget`. `null` when no target is yet
  /// resolved for this row (e.g., placeholder before assignment).
  final int? quotaTargetId;

  final int target;
  final int progress;
  final int collected;
  final num progressPercent;

  /// When set, reflects the API `remaining` value (authoritative over [target]-[progress]).
  final int? serverRemaining;

  /// Optional per-bucket count from API (`responses_count`).
  final int? responsesCountInCategory;

  /// Server-built display label, joined from coordinate labels with `" • "`.
  /// Always rendered as-is (Arabic).
  final String displayLabel;

  /// Coordinates that identify this quota bucket.
  final List<QuotaCoordinate> coordinates;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final Assignment? assignment;

  const ResearcherQuota({
    this.quotaId = 0,
    required this.id,
    required this.assignmentId,
    this.quotaTargetId,
    required this.target,
    this.progress = 0,
    this.collected = 0,
    this.progressPercent = 0,
    this.serverRemaining,
    this.responsesCountInCategory,
    this.displayLabel = '',
    this.coordinates = const [],
    required this.createdAt,
    required this.updatedAt,
    this.assignment,
  });

  ResearcherQuota copyWith({
    int? quotaId,
    int? id,
    int? assignmentId,
    int? quotaTargetId,
    bool clearQuotaTargetId = false,
    int? target,
    int? progress,
    int? collected,
    num? progressPercent,
    int? serverRemaining,
    bool clearServerRemaining = false,
    int? responsesCountInCategory,
    bool clearResponsesCountInCategory = false,
    String? displayLabel,
    List<QuotaCoordinate>? coordinates,
    DateTime? createdAt,
    DateTime? updatedAt,
    Assignment? assignment,
  }) {
    return ResearcherQuota(
      quotaId: quotaId ?? this.quotaId,
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      quotaTargetId: clearQuotaTargetId ? null : (quotaTargetId ?? this.quotaTargetId),
      target: target ?? this.target,
      progress: progress ?? this.progress,
      collected: collected ?? this.collected,
      progressPercent: progressPercent ?? this.progressPercent,
      serverRemaining: clearServerRemaining ? null : (serverRemaining ?? this.serverRemaining),
      responsesCountInCategory: clearResponsesCountInCategory
          ? null
          : (responsesCountInCategory ?? this.responsesCountInCategory),
      displayLabel: displayLabel ?? this.displayLabel,
      coordinates: coordinates ?? this.coordinates,
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

    final coordsRaw = json['coordinates'];
    final coords = coordsRaw is List
        ? coordsRaw
            .whereType<Map<String, dynamic>>()
            .map(QuotaCoordinate.fromJson)
            .toList()
        : <QuotaCoordinate>[];

    return ResearcherQuota(
      quotaId: quotaIdVal,
      id: idVal,
      assignmentId: json['assignment_id'] as int? ?? 0,
      quotaTargetId: parseOptionalInt(json['quota_target_id']),
      target: targetVal,
      progress: progressVal,
      collected: collectedVal,
      progressPercent: (json['progress_percent'] as num?) ?? 0,
      serverRemaining: parseOptionalInt(json['remaining']),
      responsesCountInCategory: parseOptionalInt(json['responses_count']),
      displayLabel: (json['display_label'] as String?) ?? '',
      coordinates: coords,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      assignment: json['assignment'] != null
          ? Assignment.fromJson(json['assignment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'quota_id': quotaId,
    'id': id,
    'assignment_id': assignmentId,
    if (quotaTargetId != null) 'quota_target_id': quotaTargetId,
    'target': target,
    'progress': progress,
    'collected': collected,
    'progress_percent': progressPercent,
    if (serverRemaining != null) 'remaining': serverRemaining,
    if (responsesCountInCategory != null)
      'responses_count': responsesCountInCategory,
    'display_label': displayLabel,
    'coordinates': coordinates.map((c) => c.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'assignment': assignment?.toJson(),
  };

  /// Remaining slots: prefers API [serverRemaining] when present.
  int get remaining {
    if (serverRemaining != null) return serverRemaining!;
    if (target <= 0) return 0;
    final diff = target - progress;
    return diff < 0 ? 0 : diff;
  }

  /// True when this bucket cannot accept more responses (server-first).
  bool get isQuotaFull {
    if (target <= 0) return false;
    if (serverRemaining != null) return serverRemaining! <= 0;
    return progress >= target;
  }

  bool get isCompleted => isQuotaFull;

  /// Get completion percentage (prefers API [progressPercent] when non-zero).
  double get completionPercentage {
    if (target <= 0) return 0;
    if (progressPercent > 0) return progressPercent.toDouble().clamp(0, 100);
    return ((progress / target) * 100).clamp(0, 100);
  }

  bool get isNearlyComplete => completionPercentage >= 80;

  /// Opacity (0.0–1.0) for primary color in progress UI based on state.
  double get progressDisplayAlpha {
    if (isCompleted) return 1.0;
    if (isNearlyComplete) return 0.85;
    if (progress > 0) return 0.65;
    return 0.45;
  }

  @override
  List<Object?> get props => [
    quotaId,
    id,
    assignmentId,
    quotaTargetId,
    target,
    progress,
    collected,
    progressPercent,
    serverRemaining,
    responsesCountInCategory,
    displayLabel,
    coordinates,
    createdAt,
    updatedAt,
    assignment,
  ];
}
