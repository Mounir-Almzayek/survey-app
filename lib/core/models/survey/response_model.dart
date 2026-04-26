import 'package:equatable/equatable.dart';
import 'answer_item_model.dart';
import 'response_log_model.dart';
import 'survey_model.dart';
import '../../enums/survey_enums.dart' show ResponseStatus;

class Response extends Equatable {
  final int id;
  final int? surveyId;
  final int? assignmentId;
  final int? publicLinkId;
  final ResponseStatus? status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationSec;
  final int? quotaTargetId;
  final String? rejectionReason;
  final String? ipAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  final List<ResponseLog>? responseLogs;
  final List<AnswerItem>? answerItems;
  final Survey? survey;

  const Response({
    required this.id,
    this.surveyId,
    this.assignmentId,
    this.publicLinkId,
    this.status,
    this.startedAt,
    this.endedAt,
    this.durationSec,
    this.quotaTargetId,
    this.rejectionReason,
    this.ipAddress,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.responseLogs,
    this.answerItems,
    this.survey,
  });

  Response copyWith({
    int? id,
    int? surveyId,
    int? assignmentId,
    int? publicLinkId,
    ResponseStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSec,
    int? quotaTargetId,
    bool clearQuotaTargetId = false,
    String? rejectionReason,
    String? ipAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<ResponseLog>? responseLogs,
    List<AnswerItem>? answerItems,
    Survey? survey,
  }) {
    return Response(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      assignmentId: assignmentId ?? this.assignmentId,
      publicLinkId: publicLinkId ?? this.publicLinkId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSec: durationSec ?? this.durationSec,
      quotaTargetId: clearQuotaTargetId ? null : (quotaTargetId ?? this.quotaTargetId),
      rejectionReason: rejectionReason ?? this.rejectionReason,
      ipAddress: ipAddress ?? this.ipAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      responseLogs: responseLogs ?? this.responseLogs,
      answerItems: answerItems ?? this.answerItems,
      survey: survey ?? this.survey,
    );
  }

  factory Response.fromJson(Map<String, dynamic> json) {
    int? parseOptionalInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.round();
      return int.tryParse(v.toString());
    }

    return Response(
      id: json['id'],
      surveyId: json['survey_id'],
      assignmentId: json['assignment_id'],
      publicLinkId: json['public_link_id'],
      status: json['status'] != null
          ? ResponseStatus.fromJson(json['status'])
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'].toString())
          : null,
      durationSec: json['duration_sec'],
      quotaTargetId: parseOptionalInt(json['quota_target_id']),
      rejectionReason: json['rejection_reason'],
      ipAddress: json['ip_address'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'].toString())
          : null,
      responseLogs: (json['response_logs'] as List?)
          ?.map((e) => ResponseLog.fromJson(e))
          .toList(),
      answerItems: (json['answer_items'] as List?)
          ?.map((e) => AnswerItem.fromJson(e))
          .toList(),
      survey: json['survey'] != null ? Survey.fromJson(json['survey']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'assignment_id': assignmentId,
      'public_link_id': publicLinkId,
      'status': status?.toJson(),
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration_sec': durationSec,
      if (quotaTargetId != null) 'quota_target_id': quotaTargetId,
      'rejection_reason': rejectionReason,
      'ip_address': ipAddress,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'response_logs': responseLogs?.map((e) => e.toJson()).toList(),
      'answer_items': answerItems?.map((e) => e.toJson()).toList(),
      'survey': survey?.toJson(),
    };
  }

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
    quotaTargetId,
    rejectionReason,
    ipAddress,
    createdAt,
    updatedAt,
    deletedAt,
    responseLogs,
    answerItems,
    survey,
  ];
}
