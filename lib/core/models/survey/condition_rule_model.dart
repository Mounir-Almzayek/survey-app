import 'package:equatable/equatable.dart';

import '../../enums/survey_enums.dart';
import '../../utils/json_parser.dart';

class ConditionRule extends Equatable {
  final int id;
  final int? conditionalLogicId;
  final int? questionId;
  final ConditionOperator? operator;
  final dynamic value;
  final ConditionJoinType? joinType;
  final int? order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConditionRule({
    required this.id,
    this.conditionalLogicId,
    this.questionId,
    this.operator,
    this.value,
    this.joinType,
    this.order,
    this.createdAt,
    this.updatedAt,
  });

  factory ConditionRule.fromJson(Map<String, dynamic> json) {
    return ConditionRule(
      id: JsonParser.asInt(json['id']),
      conditionalLogicId: JsonParser.asIntOrNull(json['conditional_logic_id']),
      questionId: JsonParser.asIntOrNull(json['question_id']),
      operator: json['operator'] != null
          ? ConditionOperator.fromJson(json['operator'])
          : null,
      value: json['value'],
      joinType: json['join_type'] != null
          ? ConditionJoinType.fromJson(json['join_type'])
          : null,
      order: JsonParser.asIntOrNull(json['order']),
      createdAt: JsonParser.asDateTimeOrNull(json['created_at']),
      updatedAt: JsonParser.asDateTimeOrNull(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conditional_logic_id': conditionalLogicId,
      'question_id': questionId,
      'operator': operator?.toJson(),
      'value': value,
      'join_type': joinType?.toJson(),
      'order': order,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    conditionalLogicId,
    questionId,
    operator,
    value,
    joinType,
    order,
    createdAt,
    updatedAt,
  ];
}
