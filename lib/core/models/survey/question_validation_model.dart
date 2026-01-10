import 'package:equatable/equatable.dart';
import 'validation_model.dart';

class QuestionValidation extends Equatable {
  final int id;
  final int questionId;
  final int validationId;
  final Map<String, dynamic>? values;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Validation? validation;

  const QuestionValidation({
    required this.id,
    required this.questionId,
    required this.validationId,
    this.values,
    this.createdAt,
    this.updatedAt,
    this.validation,
  });

  factory QuestionValidation.fromJson(Map<String, dynamic> json) {
    return QuestionValidation(
      id: json['id'],
      questionId: json['question_id'],
      validationId: json['validation_id'],
      values: json['values'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      validation: json['validation'] != null
          ? Validation.fromJson(json['validation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'validation_id': validationId,
      'values': values,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'validation': validation?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    questionId,
    validationId,
    values,
    createdAt,
    updatedAt,
    validation,
  ];
}
