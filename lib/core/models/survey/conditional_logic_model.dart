import 'package:equatable/equatable.dart';
import 'condition_rule_model.dart';
import 'condition_action_model.dart';

class ConditionalLogic extends Equatable {
  final int id;
  final int surveyId;
  final String name;
  final bool enabled;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<ConditionRule>? conditionRules;
  final List<ConditionAction>? actions;

  const ConditionalLogic({
    required this.id,
    required this.surveyId,
    required this.name,
    this.enabled = true,
    required this.order,
    this.createdAt,
    this.updatedAt,
    this.conditionRules,
    this.actions,
  });

  factory ConditionalLogic.fromJson(Map<String, dynamic> json) {
    return ConditionalLogic(
      id: json['id'],
      surveyId: json['survey_id'],
      name: json['name'],
      enabled: json['enabled'] ?? true,
      order: json['order'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      conditionRules: (json['condition_rules'] as List?)
          ?.map((e) => ConditionRule.fromJson(e))
          .toList(),
      actions: (json['actions'] as List?)
          ?.map((e) => ConditionAction.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'name': name,
      'enabled': enabled,
      'order': order,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'condition_rules': conditionRules?.map((e) => e.toJson()).toList(),
      'actions': actions?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    surveyId,
    name,
    enabled,
    order,
    createdAt,
    updatedAt,
    conditionRules,
    actions,
  ];
}
