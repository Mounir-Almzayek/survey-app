import 'package:king_abdulaziz_center_survey_app/core/models/survey/assignment_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/scope_criterion_binding.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/survey_model.dart';

/// Pure-function service that reconstructs (question_id → scope_criterion_id)
/// bindings from the survey's questions + the researcher's quota coordinates.
///
/// Inference rule: a question whose `question_options[*].value` set is a
/// superset of a criterion's category-value set (taken from the researcher's
/// quotas) is the unique candidate for that criterion. If 0 or >1 questions
/// match a criterion, no binding is emitted for it; the matcher will then
/// return `null` for any response that needs that criterion, and the server
/// will reconcile on refetch.
///
/// This is graceful degradation: ambiguity always defers to the server,
/// never produces an incorrect local match.
class BindingInferer {
  static List<ScopeCriterionBinding> infer({
    required Survey survey,
    required Assignment assignment,
  }) {
    // 1. Per-criterion category-value sets, taken from the researcher's quotas.
    final criterionToValues = <int, Set<String>>{};
    for (final quota in assignment.researcherQuotas ?? const []) {
      for (final c in quota.coordinates) {
        criterionToValues
            .putIfAbsent(c.scopeCriterionId, () => <String>{})
            .add(c.categoryValue);
      }
    }
    if (criterionToValues.isEmpty) return const [];

    // 2. Candidate questions: every question with at least one non-empty option value.
    final candidates = <_QCandidate>[];
    for (final section in survey.sections ?? const []) {
      for (final q in section.questions ?? const []) {
        final values = <String>{};
        for (final opt in q.questionOptions ?? const []) {
          final v = opt.value;
          if (v != null && v.isNotEmpty) values.add(v);
        }
        if (values.isEmpty) continue;
        candidates.add(_QCandidate(questionId: q.id, optionValues: values));
      }
    }

    // 3. For each criterion (sorted for determinism), find candidates whose
    //    option set is a superset of the criterion's category values.
    final out = <ScopeCriterionBinding>[];
    final sortedCriteria = criterionToValues.keys.toList()..sort();
    for (final cid in sortedCriteria) {
      final values = criterionToValues[cid]!;
      final matches = candidates
          .where((c) => values.every(c.optionValues.contains))
          .toList();
      if (matches.length == 1) {
        out.add(ScopeCriterionBinding(
          sourceQuestionId: matches.first.questionId,
          scopeCriterionId: cid,
        ));
      }
    }
    return out;
  }
}

class _QCandidate {
  final int questionId;
  final Set<String> optionValues;
  const _QCandidate({required this.questionId, required this.optionValues});
}
