import 'package:king_abdulaziz_center_survey_app/core/models/survey/assignment_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/scope_criterion_binding.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/survey_model.dart';

/// Pure-function service that reconstructs (question_id → scope_criterion_id)
/// bindings from the survey's questions + the researcher's quota coordinates.
///
/// **Inference rule (v2)**: for each scope criterion (with category-value set
/// `C` taken from the researcher's quotas), score every candidate question by
/// the overlap between its option-value set `O` and `C`, after normalizing
/// both sides (trim + lowercase). Pick the question with the strictly largest
/// overlap that's not already used by another criterion. Ties at the top
/// (and "no overlap > 0" at all) yield no binding for that criterion — the
/// matcher will then return `null`, and the server reconciles on refetch.
///
/// This is more permissive than the v1 strict-superset rule: it handles case
/// mismatches, whitespace, and the case where a question offers more or
/// fewer options than the researcher's quotas reference, **as long as the
/// best-overlap candidate is unique**. Ambiguity always defers to the server.
class BindingInferer {
  static List<ScopeCriterionBinding> infer({
    required Survey survey,
    required Assignment assignment,
  }) {
    final criterionToValues = <int, Set<String>>{};
    for (final quota in assignment.researcherQuotas ?? const []) {
      for (final c in quota.coordinates) {
        criterionToValues
            .putIfAbsent(c.scopeCriterionId, () => <String>{})
            .add(_normalize(c.categoryValue));
      }
    }
    if (criterionToValues.isEmpty) return const [];

    final candidates = <_QCandidate>[];
    for (final section in survey.sections ?? const []) {
      for (final q in section.questions ?? const []) {
        final values = <String>{};
        for (final opt in q.questionOptions ?? const []) {
          final v = opt.value;
          if (v != null && v.isNotEmpty) values.add(_normalize(v));
        }
        if (values.isEmpty) continue;
        candidates.add(_QCandidate(questionId: q.id, optionValues: values));
      }
    }

    final out = <ScopeCriterionBinding>[];
    final used = <int>{};
    final sortedCriteria = criterionToValues.keys.toList()..sort();

    for (final cid in sortedCriteria) {
      final values = criterionToValues[cid]!;

      // Score each unused candidate by overlap size.
      final scored = candidates
          .where((c) => !used.contains(c.questionId))
          .map((c) => _Scored(c, values.where(c.optionValues.contains).length))
          .where((s) => s.score > 0)
          .toList();
      if (scored.isEmpty) continue;

      scored.sort((a, b) => b.score.compareTo(a.score));

      // Need a unique top scorer.
      if (scored.length > 1 && scored[0].score == scored[1].score) continue;

      final best = scored.first.candidate;
      out.add(ScopeCriterionBinding(
        sourceQuestionId: best.questionId,
        scopeCriterionId: cid,
      ));
      used.add(best.questionId);
    }
    return out;
  }

  static String _normalize(String s) => s.trim().toLowerCase();
}

class _QCandidate {
  final int questionId;
  final Set<String> optionValues;
  const _QCandidate({required this.questionId, required this.optionValues});
}

class _Scored {
  final _QCandidate candidate;
  final int score;
  const _Scored(this.candidate, this.score);
}
