import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';
import 'survey_model.dart';
import 'response_model.dart';
import 'researcher_quota_model.dart';
import 'physical_device_model.dart';

class Assignment extends Equatable {
  final int id;
  final int? surveyId;
  final int? physicalDeviceId;
  final int? zoneId;
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
  final List<ResearcherQuota>? researcherQuotas;
  final List<PhysicalDeviceLog>? physicalDeviceLogs;

  const Assignment({
    required this.id,
    this.surveyId,
    this.physicalDeviceId,
    this.zoneId,
    this.assignedUserId,
    this.status,
    this.startedAt,
    this.endedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.survey,
    this.responses,
    this.researcherQuotas,
    this.physicalDeviceLogs,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as int? ?? 0,
      surveyId: json['survey_id'],
      physicalDeviceId: json['physical_device_id'],
      zoneId: json['zone_id'],
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
      researcherQuotas: (json['researcher_quotas'] as List?)
          ?.map((e) => ResearcherQuota.fromJson(e))
          .toList(),
      physicalDeviceLogs: (json['physical_device_logs'] as List?)
          ?.map((e) => PhysicalDeviceLog.fromJson(e))
          .toList(),
    );
  }

  Assignment copyWith({
    int? id,
    int? surveyId,
    int? physicalDeviceId,
    int? zoneId,
    int? assignedUserId,
    AssignmentStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    Survey? survey,
    List<Response>? responses,
    List<ResearcherQuota>? researcherQuotas,
    List<PhysicalDeviceLog>? physicalDeviceLogs,
  }) {
    return Assignment(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      physicalDeviceId: physicalDeviceId ?? this.physicalDeviceId,
      zoneId: zoneId ?? this.zoneId,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      survey: survey ?? this.survey,
      responses: responses ?? this.responses,
      researcherQuotas: researcherQuotas ?? this.researcherQuotas,
      physicalDeviceLogs: physicalDeviceLogs ?? this.physicalDeviceLogs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'physical_device_id': physicalDeviceId,
      'zone_id': zoneId,
      'assigned_user_id': assignedUserId,
      'status': status?.toJson(),
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'survey': survey?.toJson(),
      'responses': responses?.map((e) => e.toJson()).toList(),
      'researcher_quotas': researcherQuotas?.map((e) => e.toJson()).toList(),
      'physical_device_logs': physicalDeviceLogs
          ?.map((e) => e.toJson())
          .toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    surveyId,
    physicalDeviceId,
    zoneId,
    assignedUserId,
    status,
    startedAt,
    endedAt,
    createdAt,
    updatedAt,
    deletedAt,
    survey,
    responses,
    researcherQuotas,
    physicalDeviceLogs,
  ];
}
