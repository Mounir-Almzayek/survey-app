import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';
import '../../utils/json_parser.dart';
import 'question_option_model.dart';
import 'question_row_model.dart';
import 'question_validation_model.dart';

class Question extends Equatable {
  final int id;
  final int? sectionId;
  final QuestionType? type;
  final String? label;
  final String? helpText;
  final bool? isRequired;
  final int? order;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  final List<QuestionOption>? questionOptions;
  final List<QuestionRow>? questionRows;
  final List<QuestionValidation>? questionValidations;

  const Question({
    required this.id,
    this.sectionId,
    this.type,
    this.label,
    this.helpText,
    this.isRequired,
    this.order,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.questionOptions,
    this.questionRows,
    this.questionValidations,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: JsonParser.asInt(json['id']),
      sectionId: JsonParser.asIntOrNull(json['section_id']),
      type: json['type'] != null ? QuestionType.fromJson(json['type']) : null,
      label: JsonParser.asStringOrNull(json['label']),
      helpText: JsonParser.asStringOrNull(json['help_text']),
      isRequired: json['is_required'] is bool
          ? json['is_required'] as bool
          : null,
      order: JsonParser.asIntOrNull(json['order']),
      createdAt: JsonParser.asDateTimeOrNull(json['created_at']),
      updatedAt: JsonParser.asDateTimeOrNull(json['updated_at']),
      deletedAt: JsonParser.asDateTimeOrNull(json['deleted_at']),
      questionOptions: JsonParser.parseList(
        json['question_options'],
        QuestionOption.fromJson,
      ),
      questionRows: JsonParser.parseList(
        json['question_rows'],
        QuestionRow.fromJson,
      ),
      questionValidations: JsonParser.parseList(
        json['question_validations'],
        QuestionValidation.fromJson,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'type': type?.toJson(),
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

  Question copyWith({
    int? id,
    int? sectionId,
    QuestionType? type,
    String? label,
    String? helpText,
    bool? isRequired,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<QuestionOption>? questionOptions,
    List<QuestionRow>? questionRows,
    List<QuestionValidation>? questionValidations,
  }) {
    return Question(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      type: type ?? this.type,
      label: label ?? this.label,
      helpText: helpText ?? this.helpText,
      isRequired: isRequired ?? this.isRequired,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      questionOptions: questionOptions ?? this.questionOptions,
      questionRows: questionRows ?? this.questionRows,
      questionValidations: questionValidations ?? this.questionValidations,
    );
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
