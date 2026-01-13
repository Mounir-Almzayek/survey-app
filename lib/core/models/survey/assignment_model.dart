import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';
import 'survey_model.dart';
import 'response_model.dart';

class Assignment extends Equatable {
  final int id;
  final int? surveyId;
  final int? physicalDeviceId;
  final int? assignedUserId;
  final AssignmentStatus? status;
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
    this.surveyId,
    this.physicalDeviceId,
    this.assignedUserId,
    this.status,
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
      surveyId: json['survey_id'],
      physicalDeviceId: json['physical_device_id'],
      assignedUserId: json['assigned_user_id'],
      status: json['status'] != null
          ? AssignmentStatus.fromJson(json['status'].toString())
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'].toString())
          : null,
      survey: json['survey'] != null ? Survey.fromJson(json['survey']) : null,
      responses: (json['responses'] as List?)
          ?.map((e) => Response.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'physical_device_id': physicalDeviceId,
      'assigned_user_id': assignedUserId,
      'status': status?.toJson(),
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
