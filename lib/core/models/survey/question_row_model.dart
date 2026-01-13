import 'package:equatable/equatable.dart';

class QuestionRow extends Equatable {
  final int id;
  final int? questionId;
  final String? label;
  final String? value;
  final int? order;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const QuestionRow({
    required this.id,
    this.questionId,
    this.label,
    this.value,
    this.order,
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
