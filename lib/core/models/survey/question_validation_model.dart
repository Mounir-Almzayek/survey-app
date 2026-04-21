import 'package:equatable/equatable.dart';

import '../../utils/json_parser.dart';
import 'validation_model.dart';

/// Per-question instance of a [Validation] rule, with the concrete parameter
/// values supplied for that question (e.g. `{"min": 10}`).
class QuestionValidation extends Equatable {
  final int id;
  final int? questionId;
  final int? validationId;

  /// Parameter values for the validation (e.g. `{"min": 10, "max": 100}`).
  /// Object on the wire — defended against rogue list/scalar shapes.
  final Map<String, dynamic> values;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Validation? validation;

  const QuestionValidation({
    required this.id,
    this.questionId,
    this.validationId,
    this.values = const {},
    this.createdAt,
    this.updatedAt,
    this.validation,
  });

  factory QuestionValidation.fromJson(Map<String, dynamic> json) {
    return QuestionValidation(
      id: JsonParser.asInt(json['id']),
      questionId: JsonParser.asIntOrNull(json['question_id']),
      validationId: JsonParser.asIntOrNull(json['validation_id']),
      values: JsonParser.asMap(json['values']),
      createdAt: JsonParser.asDateTimeOrNull(json['created_at']),
      updatedAt: JsonParser.asDateTimeOrNull(json['updated_at']),
      validation: JsonParser.parseObject(
        json['validation'],
        Validation.fromJson,
      ),
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
