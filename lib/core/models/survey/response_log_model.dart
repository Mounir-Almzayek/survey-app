import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';

class ResponseLog extends Equatable {
  final int id;
  final int responseId;
  final ResponseLogEventType eventType;
  final double? latitude;
  final double? longitude;
  final ResponseStatus status;
  final int? surveyPolicyId;
  final String? message;
  final Map<String, dynamic>? meta;
  final DateTime? createdAt;

  const ResponseLog({
    required this.id,
    required this.responseId,
    required this.eventType,
    this.latitude,
    this.longitude,
    required this.status,
    this.surveyPolicyId,
    this.message,
    this.meta,
    this.createdAt,
  });

  factory ResponseLog.fromJson(Map<String, dynamic> json) {
    return ResponseLog(
      id: json['id'],
      responseId: json['response_id'],
      eventType: ResponseLogEventType.fromJson(json['event_type']),
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      status: ResponseStatus.fromJson(json['status']),
      surveyPolicyId: json['survey_policy_id'],
      message: json['message'],
      meta: json['meta'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'response_id': responseId,
      'event_type': eventType.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'status': status.toJson(),
      'survey_policy_id': surveyPolicyId,
      'message': message,
      'meta': meta,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    responseId,
    eventType,
    latitude,
    longitude,
    status,
    surveyPolicyId,
    message,
    meta,
    createdAt,
  ];
}
