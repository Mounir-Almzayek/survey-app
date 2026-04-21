import 'package:equatable/equatable.dart';

import '../../enums/survey_enums.dart';
import '../../utils/json_parser.dart';

class ConditionAction extends Equatable {
  final int id;
  final int? conditionalLogicId;
  final ActionTargetType? targetType;
  final int? targetId;
  final ActionType? actionType;
  final Map<String, dynamic>? params;
  final int? order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConditionAction({
    required this.id,
    this.conditionalLogicId,
    this.targetType,
    this.targetId,
    this.actionType,
    this.params,
    this.order,
    this.createdAt,
    this.updatedAt,
  });

  factory ConditionAction.fromJson(Map<String, dynamic> json) {
    return ConditionAction(
      id: JsonParser.asInt(json['id']),
      conditionalLogicId: JsonParser.asIntOrNull(json['conditional_logic_id']),
      targetType: json['target_type'] != null
          ? ActionTargetType.fromJson(json['target_type'])
          : null,
      targetId: JsonParser.asIntOrNull(json['target_id']),
      actionType: json['action_type'] != null
          ? ActionType.fromJson(json['action_type'])
          : null,
      params: JsonParser.asMapOrNull(json['params']),
      order: JsonParser.asIntOrNull(json['order']),
      createdAt: JsonParser.asDateTimeOrNull(json['created_at']),
      updatedAt: JsonParser.asDateTimeOrNull(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conditional_logic_id': conditionalLogicId,
      'target_type': targetType?.toJson(),
      'target_id': targetId,
      'action_type': actionType?.toJson(),
      'params': params,
      'order': order,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    conditionalLogicId,
    targetType,
    targetId,
    actionType,
    params,
    order,
    createdAt,
    updatedAt,
  ];
}
