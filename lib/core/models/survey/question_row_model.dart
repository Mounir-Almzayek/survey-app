import 'package:equatable/equatable.dart';

import '../../utils/json_parser.dart';

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
      id: JsonParser.asInt(json['id']),
      questionId: JsonParser.asIntOrNull(json['question_id']),
      label: JsonParser.asStringOrNull(json['label']),
      value: JsonParser.asStringOrNull(json['value']),
      order: JsonParser.asIntOrNull(json['order']),
      createdAt: JsonParser.asDateTimeOrNull(json['created_at']),
      updatedAt: JsonParser.asDateTimeOrNull(json['updated_at']),
      deletedAt: JsonParser.asDateTimeOrNull(json['deleted_at']),
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
