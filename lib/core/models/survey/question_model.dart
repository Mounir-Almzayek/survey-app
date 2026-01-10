import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';
import 'question_option_model.dart';
import 'question_row_model.dart';
import 'question_validation_model.dart';

class Question extends Equatable {
  final int id;
  final int? sectionId;
  final QuestionType type;
  final String label;
  final String helpText;
  final bool isRequired;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  final List<QuestionOption>? questionOptions;
  final List<QuestionRow>? questionRows;
  final List<QuestionValidation>? questionValidations;

  const Question({
    required this.id,
    this.sectionId,
    required this.type,
    required this.label,
    required this.helpText,
    this.isRequired = true,
    required this.order,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.questionOptions,
    this.questionRows,
    this.questionValidations,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      sectionId: json['section_id'],
      type: QuestionType.fromJson(json['type']),
      label: json['label'],
      helpText: json['help_text'],
      isRequired: json['is_required'] ?? true,
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
      questionOptions: (json['question_options'] as List?)
          ?.map((e) => QuestionOption.fromJson(e))
          .toList(),
      questionRows: (json['question_rows'] as List?)
          ?.map((e) => QuestionRow.fromJson(e))
          .toList(),
      questionValidations: (json['question_validations'] as List?)
          ?.map((e) => QuestionValidation.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'type': type.toJson(),
      'label': label,
      'help_text': helpText,
      'is_required': isRequired,
      'order': order,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'question_options': questionOptions?.map((e) => e.toJson()).toList(),
      'question_rows': questionRows?.map((e) => e.toJson()).toList(),
      'question_validations': questionValidations
          ?.map((e) => e.toJson())
          .toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    sectionId,
    type,
    label,
    helpText,
    isRequired,
    order,
    createdAt,
    updatedAt,
    deletedAt,
    questionOptions,
    questionRows,
    questionValidations,
  ];
}
