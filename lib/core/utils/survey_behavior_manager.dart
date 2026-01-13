import '../models/survey/conditional_logic_model.dart';
import '../models/survey/condition_action_model.dart';
import '../enums/survey_enums.dart';
import 'survey_logic_manager.dart';

class SurveyBehaviorManager {
  /// Calculates the visibility and requirement state for questions and sections
  /// based on current answers.
  static Map<String, dynamic> calculateBehavior({
    required List<ConditionalLogic> logics,
    required Map<int, dynamic> answers, // questionId -> value
  }) {
    // Default states
    final visibilityMap =
        <String, bool>{}; // "question_5" or "section_2" -> bool
    final requirementMap = <String, bool>{};

    for (final logic in logics) {
      if (logic.enabled == false) continue;
      if (logic.conditionRules == null || logic.conditionRules!.isEmpty)
        continue;
      final ruleResults =
          logic.conditionRules?.map((rule) {
            final answer = answers[rule.questionId];
            return SurveyLogicManager.evaluateRule(
              rule.operator ?? ConditionOperator.eq,
              rule.value,
              answer,
            );
          }).toList() ??
          [];

      // We need to know the join type. Usually it's AND by default or from the first rule.
      // Prisma schema has join_type on ConditionRule.
      // For simplicity, let's assume the join type of the logic group is AND unless specified.
      final joinType = logic.conditionRules?.isNotEmpty == true
          ? logic.conditionRules!.first.joinType ?? ConditionJoinType.and
          : ConditionJoinType.and;

      final isLogicTriggered = SurveyLogicManager.evaluateRules(
        ruleResults,
        joinType,
      );

      if (isLogicTriggered &&
          logic.actions != null &&
          logic.actions!.isNotEmpty) {
        for (ConditionAction action in logic.actions ?? []) {
          final targetKey = "${action.targetType?.name}_${action.targetId}";
          if (action.actionType == null) continue;
          switch (action.actionType!) {
            case ActionType.show:
              visibilityMap[targetKey] = true;
              break;
            case ActionType.hide:
              visibilityMap[targetKey] = false;
              break;
            case ActionType.setRequired:
              requirementMap[targetKey] = true;
              break;
            case ActionType.unsetRequired:
              requirementMap[targetKey] = false;
              break;
            case ActionType.jump:
              // JUMP logic is usually handled by the flow controller
              break;
          }
        }
      }
    }

    return {'visibility': visibilityMap, 'requirement': requirementMap};
  }
}
