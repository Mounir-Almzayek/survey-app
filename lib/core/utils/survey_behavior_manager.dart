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

      // 1. Sort rules by order to match web logic
      final sortedRules = List.from(logic.conditionRules!)
        ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

      // 2. Sequential evaluation (Sequential Join)
      bool isLogicTriggered = SurveyLogicManager.evaluateRule(
        sortedRules[0].operator ?? ConditionOperator.eq,
        sortedRules[0].value,
        answers[sortedRules[0].questionId],
      );

      for (int i = 1; i < sortedRules.length; i++) {
        final rule = sortedRules[i];
        final ruleResult = SurveyLogicManager.evaluateRule(
          rule.operator ?? ConditionOperator.eq,
          rule.value,
          answers[rule.questionId],
        );

        if (rule.joinType == ConditionJoinType.or) {
          isLogicTriggered = isLogicTriggered || ruleResult;
        } else {
          isLogicTriggered = isLogicTriggered && ruleResult;
        }
      }

      // 3. Execution of actions
      if (isLogicTriggered &&
          logic.actions != null &&
          logic.actions!.isNotEmpty) {
        // Sort actions by order
        final sortedActions = List.from(logic.actions!)
          ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

        for (ConditionAction action in sortedActions) {
          final targetKey =
              "${action.targetType?.name.toLowerCase()}_${action.targetId}";
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
              // Jump logic handled in navigation bloc, but we could add to a jumpMap if needed
              break;
          }
        }
      }
    }

    return {'visibility': visibilityMap, 'requirement': requirementMap};
  }
}
