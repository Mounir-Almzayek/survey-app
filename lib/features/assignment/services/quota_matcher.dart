import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/assignment_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/quota_coordinate.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/researcher_quota_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/survey_model.dart';

/// Pure-function service that mirrors the backend `resolveQuotaTarget`
/// algorithm. Returns the unique `quota_target_id` when the response's
/// answers resolve cleanly to exactly one target in the researcher's
/// assigned quotas; otherwise returns `null`.
///
/// The matcher is ENUM-only (matches by `categoryValue == answer`).
/// NUMBER/DATE criteria fall through to `null` and reconcile from the
/// server at FINAL_SUBMIT.
class QuotaMatcher {
  static int? match({
    required Survey survey,
    required Assignment assignment,
    required Map<int, String> answers,
  }) {
    if (survey.status == SurveyStatus.testMode) return null;

    final bindings = survey.bindings;
    if (bindings.isEmpty) return null;

    final quotas = assignment.researcherQuotas ?? const <ResearcherQuota>[];
    if (quotas.isEmpty) return null;

    // Phase 1 — resolve each binding to a (criterionId, categoryId) pair.
    final resolved = <int, int>{};
    for (final b in bindings) {
      final answer = answers[b.sourceQuestionId];
      if (answer == null || answer.isEmpty) return null;

      QuotaCoordinate? hit;
      for (final q in quotas) {
        for (final c in q.coordinates) {
          if (c.scopeCriterionId != b.scopeCriterionId) continue;
          if (c.categoryValue == answer) {
            if (hit != null && hit.scopeCriterionCategoryId != c.scopeCriterionCategoryId) {
              return null; // ambiguous within criterion
            }
            hit = c;
          }
        }
      }
      if (hit == null) return null;
      resolved[b.scopeCriterionId] = hit.scopeCriterionCategoryId;
    }

    // Phase 2 — find quota target whose coordinate set matches exactly.
    final candidates = quotas.where((q) {
      if (q.quotaTargetId == null) return false;
      if (q.coordinates.length != resolved.length) return false;
      for (final c in q.coordinates) {
        if (resolved[c.scopeCriterionId] != c.scopeCriterionCategoryId) {
          return false;
        }
      }
      return true;
    }).toList();

    if (candidates.length != 1) return null;
    return candidates.first.quotaTargetId;
  }
}
