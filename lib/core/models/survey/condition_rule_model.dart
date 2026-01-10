import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';

class ConditionRule extends Equatable {
  final int id;
  final int conditionalLogicId;
  final int questionId;
  final ConditionOperator operator;
  final dynamic value;
  final ConditionJoinType? joinType;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConditionRule({
    required this.id,
    required this.conditionalLogicId,
    required this.questionId,
    required this.operator,
    this.value,
    this.joinType,
    required this.order,
    this.createdAt,
    this.updatedAt,
  });

  factory ConditionRule.fromJson(Map<String, dynamic> json) {
    return ConditionRule(
      id: json['id'],
      conditionalLogicId: json['conditional_logic_id'],
      questionId: json['question_id'],
      operator: ConditionOperator.fromJson(json['operator']),
      value: json['value'],
      joinType: json['join_type'] != null
          ? ConditionJoinType.fromJson(json['join_type'])
          : null,
      order: json['order'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conditional_logic_id': conditionalLogicId,
      'question_id': questionId,
      'operator': operator.toJson(),
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
