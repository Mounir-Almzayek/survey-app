import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';
import 'answer_item_model.dart';
import 'response_log_model.dart';
import 'survey_model.dart';

class Response extends Equatable {
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
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  final List<ResponseLog>? responseLogs;
  final List<AnswerItem>? answerItems;
  final Survey? survey;

  const Response({
    required this.id,
    required this.surveyId,
    this.assignmentId,
    this.publicLinkId,
    this.status = ResponseStatus.draft,
    this.startedAt,
    this.endedAt,
    required this.durationSec,
    this.rejectionReason,
    required this.ipAddress,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.responseLogs,
    this.answerItems,
    this.survey,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      id: json['id'],
      surveyId: json['survey_id'],
      assignmentId: json['assignment_id'],
      publicLinkId: json['public_link_id'],
      status: ResponseStatus.fromJson(json['status']),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'])
          : null,
      durationSec: json['duration_sec'] ?? 0,
      rejectionReason: json['rejection_reason'],
      ipAddress: json['ip_address'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      responseLogs: (json['response_logs'] as List?)
          ?.map((e) => ResponseLog.fromJson(e))
          .toList(),
      answerItems: (json['answer_items'] as List?)
          ?.map((e) => AnswerItem.fromJson(e))
          .toList(),
      survey: json['survey'] != null
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
      'status': status.toJson(),
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration_sec': durationSec,
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
