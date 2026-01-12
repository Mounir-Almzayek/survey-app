import 'package:equatable/equatable.dart';

import '../../../core/models/survey/survey_model.dart';
import 'response_status.dart';

/// Response summary model matching backend GetAllResponsesData item.
class ResponseSummary extends Equatable {
  final int id;
  final int surveyId;
  final int? assignmentId;
  final int? publicLinkId;
  final ResponseStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationSec;
  final String? rejectionReason;
  final String ipAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Minimal related data for list display
  final Survey? survey;

  const ResponseSummary({
    required this.id,
    required this.surveyId,
    required this.assignmentId,
    required this.publicLinkId,
    required this.status,
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    required this.rejectionReason,
    required this.ipAddress,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.survey,
  });

  factory ResponseSummary.fromJson(Map<String, dynamic> json) {
    return ResponseSummary(
      id: json['id'] as int,
      surveyId: json['survey_id'] as int,
      assignmentId: json['assignment_id'] as int?,
      publicLinkId: json['public_link_id'] as int?,
      status: ResponseStatusX.fromString(json['status'] as String? ?? 'DRAFT'),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      durationSec: json['duration_sec'] as int? ?? 0,
      rejectionReason: json['rejection_reason'] as String?,
      ipAddress: json['ip_address'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      survey: json['survey'] is Map<String, dynamic>
          ? Survey.fromJson(json['survey'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'assignment_id': assignmentId,
      'public_link_id': publicLinkId,
      'status': status.apiValue,
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration_sec': durationSec,
      'rejection_reason': rejectionReason,
      'ip_address': ipAddress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      if (survey != null) 'survey': survey!.toJson(),
    };
  }

  bool get isDeleted => deletedAt != null;

  @override
  List<Object?> get props => [
    id,
    surveyId,
    assignmentId,
    publicLinkId,
    status,
    startedAt,
    endedAt,
    durationSec,
    rejectionReason,
    ipAddress,
    createdAt,
    updatedAt,
    deletedAt,
    survey,
  ];
}
