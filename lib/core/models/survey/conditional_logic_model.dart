import 'package:equatable/equatable.dart';

import '../../utils/json_parser.dart';
import 'condition_rule_model.dart';
import 'condition_action_model.dart';

class ConditionalLogic extends Equatable {
  final int id;
  final int? surveyId;
  final String? name;
  final bool? enabled;
  final int? order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<ConditionRule>? conditionRules;
  final List<ConditionAction>? actions;

  const ConditionalLogic({
    required this.id,
    this.surveyId,
    this.name,
    this.enabled,
    this.order,
    this.createdAt,
    this.updatedAt,
    this.conditionRules,
    this.actions,
  });

  factory ConditionalLogic.fromJson(Map<String, dynamic> json) {
    return ConditionalLogic(
      id: JsonParser.asInt(json['id']),
      surveyId: JsonParser.asIntOrNull(json['survey_id']),
      name: JsonParser.asStringOrNull(json['name']),
      enabled: json['enabled'] is bool ? json['enabled'] as bool : null,
      order: JsonParser.asIntOrNull(json['order']),
      createdAt: JsonParser.asDateTimeOrNull(json['created_at']),
      updatedAt: JsonParser.asDateTimeOrNull(json['updated_at']),
      conditionRules: JsonParser.parseList(
        json['condition_rules'],
        ConditionRule.fromJson,
      ),
      actions: JsonParser.parseList(
        json['actions'],
        ConditionAction.fromJson,
      ),
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
