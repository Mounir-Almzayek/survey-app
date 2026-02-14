import 'package:equatable/equatable.dart';

class AnswerItem extends Equatable {
  final int id;
  final int? responseId;
  final int? questionId;
  final String? value;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const AnswerItem({
    required this.id,
    this.responseId,
    this.questionId,
    this.value,
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
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'response_id': responseId,
      'question_id': questionId,
      'value': value,
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
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
