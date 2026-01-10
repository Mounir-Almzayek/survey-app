import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';

class AnswerItem extends Equatable {
  final int id;
  final int responseId;
  final int questionId;
  final String value;
  final AnswerItemStatus status;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const AnswerItem({
    required this.id,
    required this.responseId,
    required this.questionId,
    required this.value,
    this.status = AnswerItemStatus.accepted,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory AnswerItem.fromJson(Map<String, dynamic> json) {
    return AnswerItem(
      id: json['id'],
      responseId: json['response_id'],
      questionId: json['question_id'],
      value: json['value'],
      status: AnswerItemStatus.fromJson(json['status']),
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'response_id': responseId,
      'question_id': questionId,
      'value': value,
      'status': status.toJson(),
      'rejection_reason': rejectionReason,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    responseId,
    questionId,
    value,
    status,
    rejectionReason,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
