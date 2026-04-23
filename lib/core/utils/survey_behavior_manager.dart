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
    final visibilityMap = <String, bool>{};
    final requirementMap = <String, bool>{};
    final jumpMap = <int, int>{};

    // 1. Initialize visibility: Any question/section targeted by a SHOW action
    // is hidden by default until a SHOW rule matches it.
    for (final logic in logics) {
      if (logic.enabled == false || logic.actions == null) continue;
      for (final action in logic.actions!) {
        if (action.actionType == ActionType.show) {
          final targetKey =
              "${action.targetType?.name.toLowerCase()}_${action.targetId}";
          visibilityMap[targetKey] = false;
        }
      }
    }

    // 2. Fixed-point iteration (Max 10 passes to match backend)
    // This resolves dependencies where Logic A's output affects Logic B's input (visibility)
    int iterations = 0;
    bool changed = true;

    while (changed && iterations < 10) {
      iterations++;
      changed = false;

      final prevVisibility = Map<String, bool>.from(visibilityMap);
      final prevRequirement = Map<String, bool>.from(requirementMap);

      for (final logic in logics) {
        if (logic.enabled == false) continue;
        if (logic.conditionRules == null || logic.conditionRules!.isEmpty)
          continue;

        // Sort rules by order
        final sortedRules = List.from(logic.conditionRules!)
          ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

        // Evaluate sequential rules
        // Note: Backend considers hidden questions as "failing" conditions.
        bool isLogicTriggered = _evaluateWithVisibility(
          sortedRules[0],
          answers,
          visibilityMap,
        );

        for (int i = 1; i < sortedRules.length; i++) {
          final rule = sortedRules[i];
          final ruleResult = _evaluateWithVisibility(
            rule,
            answers,
            visibilityMap,
          );

          if (rule.joinType == ConditionJoinType.or) {
            isLogicTriggered = isLogicTriggered || ruleResult;
          } else {
            isLogicTriggered = isLogicTriggered && ruleResult;
          }
        }

        // Execute actions if triggered
        if (isLogicTriggered &&
            logic.actions != null &&
            logic.actions!.isNotEmpty) {
          for (ConditionAction action in logic.actions!) {
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
                // Jump logic usually triggers navigation, doesn't affect visibility/requirement maps directly
                // but we store it for the UI to handle.
                _processJump(action, sortedRules, jumpMap);
                break;
            }
          }
        }
      }

      // Check if maps changed
      if (!_mapEquals(prevVisibility, visibilityMap) ||
          !_mapEquals(prevRequirement, requirementMap)) {
        changed = true;
      }
    }

    return {
      'visibility': visibilityMap,
      'requirement': requirementMap,
      'jump': jumpMap,
    };
  }

  /// Evaluates a rule while respecting question visibility (hidden questions return false)
  static bool _evaluateWithVisibility(
    dynamic rule, // ConditionRule
    Map<int, dynamic> answers,
    Map<String, bool> visibilityMap,
  ) {
    final questionId = rule.questionId;
    final targetKey = "question_$questionId";

    // If question is explicitly hidden, it cannot trigger logic (matches backend)
    if (visibilityMap.containsKey(targetKey) && visibilityMap[targetKey] == false) {
      return false;
    }

    return SurveyLogicManager.evaluateRule(
      rule.operator ?? ConditionOperator.eq,
      rule.value,
      answers[questionId],
    );
  }

  static void _processJump(
    ConditionAction action,
    List<dynamic> sortedRules,
    Map<int, int> jumpMap,
  ) {
    dynamic jumpToId =
        action.params?['jump_to_section'] ??
        action.params?['jump_to_id'] ??
        action.params?['target_id'];

    if (jumpToId == null && action.targetId != null) {
      jumpToId = action.targetId;
    }

    if (jumpToId != null) {
      int? triggerQuestionId;
      if (sortedRules.isNotEmpty) {
        triggerQuestionId = sortedRules[0].questionId;
      }

      if (triggerQuestionId != null) {
        jumpMap[triggerQuestionId] = int.tryParse(jumpToId.toString()) ?? 0;
      }
    }
  }

  static bool _mapEquals(Map<String, bool> a, Map<String, bool> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (b[key] != a[key]) return false;
    }
    return true;
  }
}
