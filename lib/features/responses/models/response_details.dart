import 'package:equatable/equatable.dart';

import 'package:king_abdulaziz_center_survey_app/core/models/survey/quota_coordinate.dart';

import 'response_status.dart';

/// Answer details as returned by ResponseService.getDetails
class ResponseAnswerDetail extends Equatable {
  final int questionId;
  final String questionLabel;
  final String questionType;
  final String value;

  const ResponseAnswerDetail({
    required this.questionId,
    required this.questionLabel,
    required this.questionType,
    required this.value,
  });

  factory ResponseAnswerDetail.fromJson(Map<String, dynamic> json) {
    return ResponseAnswerDetail(
      questionId: json['question_id'] as int,
      questionLabel: json['question_label'] as String? ?? '',
      questionType: json['question_type'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [questionId, questionLabel, questionType, value];
}

/// Detailed response model matching ResponseService.getDetails shape.
class ResponseDetails extends Equatable {
  final int id;
  final ResponseStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationSec;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String ipAddress;

  final int? surveyId;
  final String? surveyTitle;

  final int? quotaTargetId;
  final String? displayLabel;
  final List<QuotaCoordinate>? coordinates;

  final List<ResponseAnswerDetail> answers;

  const ResponseDetails({
    required this.id,
    required this.status,
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    required this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    required this.ipAddress,
    required this.surveyId,
    required this.surveyTitle,
    this.quotaTargetId,
    this.displayLabel,
    this.coordinates,
    required this.answers,
  });

  factory ResponseDetails.fromJson(Map<String, dynamic> json) {
    final surveyJson = json['survey'];
    final coordsRaw = json['coordinates'];
    final coords = coordsRaw is List
        ? coordsRaw
            .whereType<Map<String, dynamic>>()
            .map(QuotaCoordinate.fromJson)
            .toList()
        : null;

    return ResponseDetails(
      id: json['id'] as int,
      status: ResponseStatusX.fromString(json['status'] as String? ?? 'DRAFT'),
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'].toString())
          : null,
      durationSec: json['duration_sec'] as int? ?? 0,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      ipAddress: json['ip_address'] as String? ?? '',
      surveyId: surveyJson is Map<String, dynamic>
          ? surveyJson['id'] as int?
          : null,
      surveyTitle: surveyJson is Map<String, dynamic>
          ? surveyJson['title'] as String?
          : null,
      quotaTargetId: (json['quota_target_id'] as num?)?.toInt(),
      displayLabel: json['display_label'] as String?,
      coordinates: coords,
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map((a) => ResponseAnswerDetail.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    startedAt,
    endedAt,
    durationSec,
    rejectionReason,
    createdAt,
    updatedAt,
    ipAddress,
    surveyId,
    surveyTitle,
    quotaTargetId,
    displayLabel,
    coordinates,
    answers,
  ];
}
