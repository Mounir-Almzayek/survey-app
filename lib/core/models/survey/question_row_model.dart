import 'package:equatable/equatable.dart';

class QuestionRow extends Equatable {
  final int id;
  final int questionId;
  final String label;
  final String value;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const QuestionRow({
    required this.id,
    required this.questionId,
    required this.label,
    required this.value,
    required this.order,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory QuestionRow.fromJson(Map<String, dynamic> json) {
    return QuestionRow(
      id: json['id'],
      questionId: json['question_id'],
      label: json['label'],
      value: json['value'],
      order: json['order'],
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
      'question_id': questionId,
      'label': label,
      'value': value,
      'order': order,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    questionId,
    label,
    value,
    order,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
