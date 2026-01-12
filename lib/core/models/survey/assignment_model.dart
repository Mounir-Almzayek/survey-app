import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';
import 'survey_model.dart';
import 'response_model.dart';

class Assignment extends Equatable {
  final int id;
  final int surveyId;
  final int physicalDeviceId;
  final int? assignedUserId;
  final AssignmentStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  // Relations
  final Survey? survey;
  final List<Response>? responses;

  const Assignment({
    required this.id,
    required this.surveyId,
    required this.physicalDeviceId,
    this.assignedUserId,
    this.status = AssignmentStatus.pending,
    this.startedAt,
    this.endedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.survey,
    this.responses,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as int? ?? 0,
      surveyId: json['survey_id'] as int? ?? 0,
      physicalDeviceId: json['physical_device_id'] as int? ?? 0,
      assignedUserId: json['assigned_user_id'] as int?,
      status: json['status'] != null
          ? AssignmentStatus.fromJson(json['status'] as String)
          : AssignmentStatus.pending,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      survey: json['survey'] != null
          ? Survey.fromJson(json['survey'] as Map<String, dynamic>)
          : null,
      responses: (json['responses'] as List?)
          ?.map((e) => Response.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'physical_device_id': physicalDeviceId,
      'assigned_user_id': assignedUserId,
      'status': status.toJson(),
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'survey': survey?.toJson(),
      'responses': responses?.map((e) => e.toJson()).toList(),
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
    responses,
  ];
}
