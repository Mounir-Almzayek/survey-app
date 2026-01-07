import 'package:equatable/equatable.dart';

import 'survey.dart';

/// Assignment status enum matching backend AssignmentStatusSchema
/// Values: 'PENDING','IN_PROGRESS','COMPLETED'
enum AssignmentStatus {
  pending,
  inProgress,
  completed,
}

extension AssignmentStatusX on AssignmentStatus {
  static AssignmentStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return AssignmentStatus.pending;
      case 'IN_PROGRESS':
        return AssignmentStatus.inProgress;
      case 'COMPLETED':
        return AssignmentStatus.completed;
      default:
        return AssignmentStatus.pending;
    }
  }

  String get apiValue {
    switch (this) {
      case AssignmentStatus.pending:
        return 'PENDING';
      case AssignmentStatus.inProgress:
        return 'IN_PROGRESS';
      case AssignmentStatus.completed:
        return 'COMPLETED';
    }
  }

  bool get isPending => this == AssignmentStatus.pending;
  bool get isInProgress => this == AssignmentStatus.inProgress;
  bool get isCompleted => this == AssignmentStatus.completed;
}

/// Assignment model matching backend AssignmentWithRelations (simplified)
class Assignment extends Equatable {
  final int id;
  final int surveyId;
  final int physicalDeviceId;
  final int? assignedUserId;
  final AssignmentStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Optional related survey for convenience when API includes it
  final Survey? survey;

  /// Optional count of responses for this assignment (when provided)
  final int? responsesCount;

  const Assignment({
    required this.id,
    required this.surveyId,
    required this.physicalDeviceId,
    required this.assignedUserId,
    required this.status,
    required this.startedAt,
    required this.endedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.survey,
    this.responsesCount,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as int,
      surveyId: json['survey_id'] as int,
      physicalDeviceId: json['physical_device_id'] as int,
      assignedUserId: json['assigned_user_id'] as int?,
      status: AssignmentStatusX.fromString(json['status'] as String? ?? 'PENDING'),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      survey: json['survey'] is Map<String, dynamic>
          ? Survey.fromJson(json['survey'] as Map<String, dynamic>)
          : null,
      responsesCount: json['responses_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'physical_device_id': physicalDeviceId,
      'assigned_user_id': assignedUserId,
      'status': status.apiValue,
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      if (survey != null) 'survey': survey!.toJson(),
      if (responsesCount != null) 'responses_count': responsesCount,
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        physicalDeviceId,
        assignedUserId,
        status,
        startedAt,
        endedAt,
        createdAt,
        updatedAt,
        deletedAt,
        survey,
        responsesCount,
      ];
}


