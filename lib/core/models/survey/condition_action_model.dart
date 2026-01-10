import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';

class ConditionAction extends Equatable {
  final int id;
  final int conditionalLogicId;
  final ActionTargetType targetType;
  final int targetId;
  final ActionType actionType;
  final Map<String, dynamic>? params;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConditionAction({
    required this.id,
    required this.conditionalLogicId,
    required this.targetType,
    required this.targetId,
    required this.actionType,
    this.params,
    required this.order,
    this.createdAt,
    this.updatedAt,
  });

  factory ConditionAction.fromJson(Map<String, dynamic> json) {
    return ConditionAction(
      id: json['id'],
      conditionalLogicId: json['conditional_logic_id'],
      targetType: ActionTargetType.fromJson(json['target_type']),
      targetId: json['target_id'],
      actionType: ActionType.fromJson(json['action_type']),
      params: json['params'],
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
      'target_type': targetType.toJson(),
      'target_id': targetId,
      'action_type': actionType.toJson(),
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
