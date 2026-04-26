# QuotaTarget Migration — Design Spec

**Date:** 2026-04-26
**Scope:** Flutter client only — `lib/core/models/`, `lib/features/assignment/`, `lib/features/public_links/`, `lib/features/profile/`, `lib/features/responses/`, `lib/features/home/`. Backend changes are tracked separately and are assumed shipped (or shipping in lockstep) — see Anchors.

## Problem

The backend has replaced `gender`/`age_group` demographics with **scope-criterion coordinates**. A `QuotaTarget` is now identified by a set of `(scope_criterion_id, scope_criterion_category_id)` pairs, and quota matching happens server-side at FINAL_SUBMIT — not at start. The Flutter app's existing flow asks the user to pick gender + age group up front, sends those fields in the start body, optimistically increments local quotas using that pair, and renders quotas as "Male 18-29: 8/10". All of this must change:

- The pre-start `DemographicsDialog` is obsolete — demographics now come from inside the survey via questions bound to scope criteria.
- The start endpoints no longer accept `gender`/`age_group` in the body.
- Quota items returned by every researcher endpoint now carry `quota_target_id`, `display_label`, and `coordinates[]` instead of `gender`/`age_group`.
- A response can finalize with `quota_target_id = NULL` if its answers don't resolve cleanly.
- TEST_MODE responses are server-side invisible to quota — UI counters for test surveys show 0.

## Goal

Mirror the backend's quota-resolution logic on-device so that local quota counts increment optimistically (online and offline) as soon as a response is finalized, and reconcile against the server (the source of truth) on every successful sync or reconnection. Strip the demographic pre-screen entirely, render quotas as full coordinate display labels, and migrate cached state cleanly on first launch with the new app version.

## Non-Goals

- **Backend changes.** Backend ownership is separate. The new researcher/public-link endpoint shapes and the `SurveyQuotaCriterionBinding` field are assumed shipped. The mobile spec depends on `bindings: [{ source_question_id, scope_criterion_id }]` being added to `GET /researcher/assignment` and `GET /researcher/assignment/survey/:surveyId` responses (see Open Backend Coordination below).
- **NUMBER / DATE quota criteria matching on the client.** Production data is ENUM-only. The local matcher supports ENUM matching by `categoryValue === answer`. Any NUMBER/DATE criterion locally returns `null` (no match), the server matches authoritatively at FINAL_SUBMIT, and the client reconciles on refetch — graceful degradation, no breakage.
- **Localized `display_label`.** Server-built label is Arabic-only by design (single `label` field on `ScopeCriterionCategory`, no `Accept-Language` handling). The app renders it as-is in both English and Arabic UIs. If localization becomes a requirement later, it's a backend change.
- **Backfill of pre-migration data.** Cached surveys/profile and `ResponseMetadata` are wiped on first launch with the new schema version; queued start requests are sanitized of `gender`/`age_group` keys. Any in-progress local responses keep their data; their `gender`/`ageGroup` fields are silently ignored by the new parser.
- **Pre-start quota-full check.** Removed entirely. Quota is enforced at FINAL_SUBMIT server-side.
- **Survey-level demographic charts on Home.** The cross-survey gender/age aggregations on the Home dashboard are removed; replaced by per-survey Summary + collapsible Breakdown by `display_label`.

## Anchors (read before implementing)

### Mobile (current code to change)
- Researcher assignment repo: [lib/features/assignment/repository/assignment_repository.dart:19](../../../lib/features/assignment/repository/assignment_repository.dart) (list/get/start) and `:124-186` (`_incrementLocalQuotaForCompletedResponse`)
- Start request DTO: [lib/features/assignment/models/start_response_request_model.dart:34](../../../lib/features/assignment/models/start_response_request_model.dart)
- Demographics dialog (to delete): [lib/features/assignment/presentation/widgets/demographics_dialog.dart](../../../lib/features/assignment/presentation/widgets/demographics_dialog.dart)
- Researcher start screen: [lib/features/assignment/presentation/screens/survey_answering_screen.dart:125](../../../lib/features/assignment/presentation/screens/survey_answering_screen.dart)
- Public-link start screen: [lib/features/public_links/presentation/public_link_answering_page.dart:96](../../../lib/features/public_links/presentation/public_link_answering_page.dart)
- ResearcherQuota model: [lib/core/models/survey/researcher_quota_model.dart:6](../../../lib/core/models/survey/researcher_quota_model.dart)
- Profile quota model: [lib/features/profile/models/researcher_profile_response_model.dart:184](../../../lib/features/profile/models/researcher_profile_response_model.dart)
- Response details model: [lib/features/responses/models/response_details.dart:6](../../../lib/features/responses/models/response_details.dart)
- Response model (gender/ageGroup): [lib/core/models/survey/response_model.dart:16](../../../lib/core/models/survey/response_model.dart)
- ResponseMetadata (to delete): [lib/features/assignment/models/response_metadata.dart](../../../lib/features/assignment/models/response_metadata.dart)
- StartResponse bloc: [lib/features/assignment/bloc/start_response/start_response_bloc.dart:80](../../../lib/features/assignment/bloc/start_response/start_response_bloc.dart)
- PublicLinkAnswering bloc: [lib/features/public_links/bloc/answering/public_link_answering_bloc.dart:64](../../../lib/features/public_links/bloc/answering/public_link_answering_bloc.dart)
- Home stats bloc: [lib/features/home/bloc/home_stats/home_stats_bloc.dart:56](../../../lib/features/home/bloc/home_stats/home_stats_bloc.dart)
- Home survey stats widget: [lib/features/home/presentation/widgets/survey_stats_widget.dart:40](../../../lib/features/home/presentation/widgets/survey_stats_widget.dart)
- Home quota summary list: [lib/features/home/presentation/widgets/quota_summary_list.dart](../../../lib/features/home/presentation/widgets/quota_summary_list.dart)
- Gender / AgeGroup enums (to delete): [lib/core/enums/survey_enums.dart:449](../../../lib/core/enums/survey_enums.dart)
- Storage service: [lib/core/services/storage_service.dart](../../../lib/core/services/storage_service.dart)

### Backend (read-only reference for matching parity)
- Quota matcher: `survey-system/src/services/quota-matching.service.ts:29-201` (`resolveQuotaTarget`)
- Researcher final submit invocation: `survey-system/src/routes/researcher/assignment/route.ts:1086-1089`
- Public-link final submit invocation: `survey-system/src/routes/public-link/route.ts:590-593`
- Quota count + enrichment: `survey-system/src/routes/researcher/researcher-survey-response-counts.ts:76-219`
- `display_label` builder: `survey-system/src/routes/researcher/researcher-survey-response-counts.ts:159-161`
- Schema (QuotaTarget, ScopeCriterion, bindings): `survey-system/prisma/schema/sampling-scope.prisma:46-122`, `survey-system/prisma/schema/survey.prisma:46-77`

## Open Backend Coordination

This spec depends on one backend addition that is not yet in the API:

> **`GET /researcher/assignment` and `GET /researcher/assignment/survey/:surveyId` must return `bindings: [{ source_question_id, scope_criterion_id }]` per survey** (or per assignment), populated from `SurveyQuotaCriterionBinding` rows.

Rationale: the local matcher needs the question→criterion mapping to know which answer feeds which scope criterion. Today this data is only exposed on admin endpoints. Until the field ships, the mobile-side matcher cannot run; the rest of this spec (model migration, dialog removal, UI changes) can land independently. The matcher hookup gates on this field's presence.

## Design decisions (locked)

### 1. Local matching algorithm (mirrors `resolveQuotaTarget`)

Pure static method on a new `QuotaMatcher` class in `lib/features/assignment/services/quota_matcher.dart`:

```dart
class QuotaMatcher {
  static int? match({
    required Survey survey,
    required Assignment assignment,
    required Map<int, String> answers, // questionId → raw answer value
  });
}
```

Procedure:

1. If `survey.status == SurveyStatus.testMode` → return `null`.
2. If `survey.bindings` is empty → return `null`.
3. For each binding `(sourceQuestionId, scopeCriterionId)`:
   - `answer = answers[sourceQuestionId]`. If `null`/empty → return `null`.
   - Across the union of `coordinates[]` from `assignment.researcherQuotas` where `coordinate.scopeCriterionId == binding.scopeCriterionId`, find the unique entry whose `categoryValue == answer`. If none → return `null`.
   - Collect `(scopeCriterionId, scopeCriterionCategoryId)` into `resolved`.
4. Find quotas in `assignment.researcherQuotas` whose `coordinates.length == resolved.length` AND every `(criterionId, categoryId)` pair in `resolved` is present in the quota's coordinates.
5. If exactly one match → return its `quotaTargetId`. Otherwise → return `null`.

**Idempotency:** the matcher is never called when `Response.quotaTargetId != null`. The caller short-circuits.

**Datatype scope:** ENUM only. NUMBER/DATE criteria fall through to `null` and reconcile from the server on refetch.

### 2. Where the matcher runs

In `AssignmentRepository.saveSectionAnswers()` and `enqueueSaveSectionAnswers()`, **only when the section save sets `isComplete = true`**:

```
if (result.isComplete && response.quotaTargetId == null) {
  response.quotaTargetId = QuotaMatcher.match(
    survey: survey,
    assignment: assignment,
    answers: collectedAnswers,
  );
  await _localRepo.updateResponse(response);
  if (response.quotaTargetId != null) {
    _incrementLocalQuotaForCompletedResponse(response.id);
  }
}
```

Same code path online and offline — matcher runs locally regardless. The result lives on `Response.quotaTargetId` until reconciliation.

### 3. Reconciliation strategy

Server is source of truth. Refetch points:

| Event | Action |
|---|---|
| Successful online section save with `isComplete=true` | `getSurveyDetails(surveyId)` → replace cached survey |
| Offline → online queue drain completes | `listAssignments()` → replace all cached surveys |
| Pull-to-refresh on Home or Responses | `listAssignments()` |

A divergence between local prediction and server truth (rare; typically only when a NUMBER/DATE criterion is involved or the binding data is stale) resolves at refetch — server values overwrite local.

### 4. Local quota increment

Replace the existing `_incrementLocalQuotaForCompletedResponse(responseId)` body with a `quotaTargetId`-driven version:

```dart
void _incrementLocalQuotaForCompletedResponse(int responseId) {
  final response = _localRepo.getResponse(responseId);
  if (response.quotaTargetId == null) return;

  final survey = _localRepo.getSurvey(response.surveyId);
  if (survey.status == SurveyStatus.testMode) return;

  final quota = survey.assignments[0].researcherQuotas
      .firstWhereOrNull((q) => q.quotaTargetId == response.quotaTargetId);
  if (quota == null) return;

  quota.progress += 1;
  quota.collected += 1;
  quota.responsesCount += 1;
  // remaining and progress_percent are derived in the UI

  _localRepo.updateSurvey(survey);
  _profileLocalRepo.incrementQuota(quota.id);
}
```

The TEST_MODE early-return guarantees test surveys always show 0 used locally, matching server behavior.

### 5. Cache migration on schema bump

Bump `currentSchemaVersion` to `2`. On first launch with the new version, before any survey/profile read:

1. Clear surveys cache box.
2. Clear profile cache box.
3. Clear ResponseMetadata box (entire box; the type is being deleted).
4. Iterate the request queue; for each item with a JSON body, remove `gender` and `age_group` keys if present and persist.
5. Set `schema_version = 2`.

**Response cache is preserved** — the new `Response` parser silently ignores `gender`/`ageGroup` keys. In-progress responses survive the upgrade.

**Failure handling:** any exception during migration is logged; the app continues booting without bumping `schema_version`, so the next launch retries. Migration is idempotent.

### 6. Demographics removal (UI)

- `DemographicsDialog` deleted entirely. No replacement.
- `SurveyAnsweringScreen` and `PublicLinkAnsweringPage` start the survey directly with `location` only.
- All `UpdateGender` / `UpdateAgeGroup` events, the `isDemographicQuotaFull` state flag, and the pre-start quota-full snackbar are removed from `start_response_bloc` and `public_link_answering_bloc`.

### 7. Home stats — Summary + Breakdown

Replace cross-survey gender/age aggregation with:

- **Summary** (existing per-survey card): total `progress / target` across the survey's quotas — unchanged.
- **Breakdown** (new collapsible section under each card): list of quota rows showing `display_label` and `progress / target` and a thin progress bar. Sorted descending by `progress_percent` (closest-to-full first). Top 5 with a "show more" toggle.

`SurveyStatsModel.genderProgress` and `.ageGroupProgress` deleted. `DemographicCharts` widget deleted.

### 8. Response details

`ResponseDetails` gains `quotaTargetId: int?`, `displayLabel: String?`, `coordinates: List<QuotaCoordinate>?`. The presentation layer renders one row "الكوتا: <displayLabel>" when `quotaTargetId != null`, or "الكوتا: غير محدد" when `null`. Coordinates are not surfaced in the UI in v1; the display label is sufficient.

## Components

### `QuotaCoordinate` (new model)

Path: `lib/core/models/survey/quota_coordinate.dart`

```dart
class QuotaCoordinate {
  final int scopeCriterionId;
  final String criterionName;
  final int scopeCriterionCategoryId;
  final String categoryLabel;
  final String categoryValue;
  final int order;
}
```

`fromJson` / `toJson` round-trip with snake_case keys matching the API.

### `ScopeCriterionBinding` (new model)

Path: `lib/core/models/survey/scope_criterion_binding.dart`

```dart
class ScopeCriterionBinding {
  final int sourceQuestionId;
  final int scopeCriterionId;
}
```

Lives on `Survey` as `List<ScopeCriterionBinding> bindings` (parsed from the new API field — see Open Backend Coordination).

### `ResearcherQuota` (modified)

Path: `lib/core/models/survey/researcher_quota_model.dart`

Removed: `gender`, `ageGroup`, `isDemographicQuotaFull`, `demographicDescription`, `localizedDemographicDescription()`.

Added: `quotaTargetId: int?`, `displayLabel: String`, `coordinates: List<QuotaCoordinate>`.

`fromJson` ignores the legacy `gender` / `age_group` keys silently (lenient parse for in-progress cached data).

### `ResearcherQuotaModel` in profile (modified)

Path: `lib/features/profile/models/researcher_profile_response_model.dart`

Same field changes as `ResearcherQuota`. Both models stay in sync; they parse the same wire shape.

### `Response` (modified)

Path: `lib/core/models/survey/response_model.dart`

Removed: `gender`, `ageGroup`. Added: `quotaTargetId: int?`. `fromJson` ignores legacy keys.

### `ResponseDetails` (modified)

Path: `lib/features/responses/models/response_details.dart`

Added: `quotaTargetId: int?`, `displayLabel: String?`, `coordinates: List<QuotaCoordinate>?`.

### `StartResponseRequest` (modified)

Path: `lib/features/assignment/models/start_response_request_model.dart`

Removed fields: `gender`, `ageGroup`. Body shape now: `{ location?, created_at }`.

### Public-link start body (modified)

Path: `lib/features/public_links/repository/public_links_online_repository.dart`

Inline body drops `gender` and `age_group`. Shape: `{ location?, created_at }`.

### `QuotaMatcher` (new service)

Path: `lib/features/assignment/services/quota_matcher.dart`

Pure static `match(...)` per Decision 1. No external dependencies; takes plain models in, returns `int?` out. Fully unit-testable.

### `AssignmentRepository` (modified)

Path: `lib/features/assignment/repository/assignment_repository.dart`

- `saveSectionAnswers` and `enqueueSaveSectionAnswers`: invoke matcher when `isComplete` and `Response.quotaTargetId == null`; write result; increment locally if non-null.
- `_incrementLocalQuotaForCompletedResponse`: rewritten per Decision 4 to key off `quotaTargetId` instead of gender/ageGroup.
- New method `refreshAllAssignments()`: thin wrapper around `listAssignments()` that also replaces the local cache. Called from queue-drain hook.
- All references to `saveResponseMetadata`, `getResponseMetadata`, and `ResponseMetadata` deleted.

### `StartResponseBloc` (modified)

Path: `lib/features/assignment/bloc/start_response/start_response_bloc.dart`

- Events `UpdateGender`, `UpdateAgeGroup` and their handlers deleted.
- `gender`, `ageGroup` fields removed from state.
- Pre-start `isDemographicQuotaFull` check + the `StartResponseError(isDemographicQuotaFull: true)` branch deleted.
- The `isDemographicQuotaFull` flag on `StartResponseError` deleted.

### `PublicLinkAnsweringBloc` (modified)

Path: `lib/features/public_links/bloc/answering/public_link_answering_bloc.dart`

- `StartAnswering` event drops `gender` / `ageGroup` parameters.
- Repository call drops the same arguments.

### `SurveyAnsweringScreen` (modified)

Path: `lib/features/assignment/presentation/screens/survey_answering_screen.dart`

Lines 125-175: the `DemographicsDialog` invocation, the gender/age dispatch chain, and the pre-start quota-full snackbar are removed. The "Start Survey" path becomes:

```
onStart() async {
  final loc = await LocationService.getCurrentLocation(); // non-blocking, optional
  if (loc != null) bloc.add(UpdateLocation(loc));
  bloc.add(StartSurveyResponse());
}
```

### `PublicLinkAnsweringPage` (modified)

Path: `lib/features/public_links/presentation/public_link_answering_page.dart`

Lines 96-139 (`_bootstrap`): drop the dialog. Conditionally capture location, then dispatch `StartAnswering(location: loc)`.

### `HomeStatsBloc` + `SurveyStatsModel` (modified)

Path: `lib/features/home/bloc/home_stats/home_stats_bloc.dart`, `lib/features/home/models/survey_stats_model.dart`

- `genderProgress` and `ageGroupProgress` aggregation logic and fields deleted.
- New per-survey breakdown: `List<QuotaBreakdownEntry>` where `QuotaBreakdownEntry = { displayLabel, progress, target, progressPercent }`. Sorted descending by `progressPercent`.
- TEST_MODE surveys contribute 0 to the breakdown (mirrors server behavior).

### `QuotaBreakdownList` (new widget)

Path: `lib/features/home/presentation/widgets/quota_breakdown_list.dart`

Collapsible list under each survey card. Renders top 5 entries; "show more" expands to all. Each row: `displayLabel` (Arabic, as-is), `progress/target`, thin progress bar.

### `SurveyStatsWidget` and `DemographicCharts` (modified / deleted)

- `DemographicCharts` widget deleted.
- `SurveyStatsWidget` lines 54-57 (`DemographicCharts` invocation) removed.
- The Survey-Analysis chart section (if it depends on the removed fields) is reviewed and updated to use `progress / target` and `displayLabel`.

### `ResponseDetailsPage` (modified)

Path: `lib/features/responses/presentation/...` (response details screen)

Add a row: "الكوتا: <displayLabel>" when `quotaTargetId != null`, or "الكوتا: غير محدد" when `null`.

### Schema migration (new)

Path: `lib/core/services/schema_migration_service.dart`

Single class with `Future<void> runIfNeeded()` per Decision 5. Called from `splash_routing_bloc` (or equivalent early startup hook) before any survey/profile read.

### Cleanup deletions

Files deleted:
- `lib/features/assignment/presentation/widgets/demographics_dialog.dart`
- `lib/features/assignment/models/response_metadata.dart`
- `lib/features/home/presentation/widgets/demographic_charts.dart` (if it exists as a separate file)

Hive adapter registrations removed for `ResponseMetadata`.

`Gender` and `AgeGroup` enums in `lib/core/enums/survey_enums.dart` deleted along with their `localized()` extensions, plus the unused l10n keys (`gender`, `gender_male`, `gender_female`, `select_gender`, `age_group`, `age_18_29`, `age_30_39`, `age_40_49`, `age_50_59`, `age_60_plus`, `select_age_group`, `demographic_quota_full_for_category`).

## Testing

### Unit — `QuotaMatcher`
File: `test/features/assignment/services/quota_matcher_test.dart`

- single-binding match (Gender)
- multi-binding match (Region + Gender + Age) with shuffled coordinate order
- TEST_MODE survey → null
- empty bindings → null
- empty researcherQuotas → null
- missing answer for a bound question → null
- answer doesn't match any category in the criterion → null
- answer accidentally matches a category in the wrong criterion → still null (criterion-scoped lookup)
- coordinate-count mismatch (target has more or fewer coordinates than resolved) → null
- two QuotaTargets share the resolved set → null
- idempotency: caller does not invoke matcher when `Response.quotaTargetId != null` (covered in repo tests)

### Unit — Models
File: `test/core/models/researcher_quota_model_test.dart`

- new JSON parses correctly with all new fields
- coordinates list parses ordered by `order`
- legacy JSON with `gender` + `age_group` parses without error and ignores them
- `displayLabel` Arabic content round-trips byte-exact

File: `test/features/responses/models/response_details_test.dart`

- `quotaTargetId == null` + `displayLabel == null` + `coordinates == null` parse cleanly
- `quotaTargetId != null` parses with displayLabel and coordinates

### Unit — Repository
File: `test/features/assignment/repository/assignment_repository_test.dart`

- `saveSectionAnswers` with `isComplete=true` invokes matcher exactly once
- matcher returns int → local quota progress/collected/responsesCount each `+1`
- matcher returns null → local quota unchanged, Response keeps `quotaTargetId=null`
- TEST_MODE survey + matcher returning int → local counters unchanged (early return)
- successful online final save triggers `getSurveyDetails(surveyId)` for refetch
- `enqueueSaveSectionAnswers` runs matcher locally and increments optimistically
- `Response.quotaTargetId != null` already → matcher not invoked

### Unit — Blocs
File: `test/features/assignment/bloc/start_response/start_response_bloc_test.dart`

- `StartSurveyResponse` no longer requires gender/ageGroup state
- `StartResponseRequest` body excludes `gender` and `age_group`
- no `isDemographicQuotaFull` branch is reachable

File: `test/features/public_links/bloc/answering/public_link_answering_bloc_test.dart`

- `StartAnswering` event has no gender/ageGroup parameters
- public-link start body excludes the two fields

File: `test/features/home/bloc/home_stats/home_stats_bloc_test.dart`

- per-survey total progress computed from sum of quotas
- breakdown sorted descending by `progressPercent`
- TEST_MODE survey contributes 0

### Unit — Migration
File: `test/core/services/schema_migration_service_test.dart`

- `schema_version=null` → full migration → `schema_version=2`
- `schema_version=2` → no-op
- surveys cache + profile cache + ResponseMetadata box all cleared
- queue start request body `{gender, age_group, location}` → `{location}` after sanitize
- queue section request body unchanged
- queue item with no body unchanged
- exception during migration is logged and `schema_version` is not bumped (next launch retries)

### Widget
- `SurveyAnsweringScreen` does not show `DemographicsDialog`
- `PublicLinkAnsweringPage` does not show `DemographicsDialog`
- `QuotaSummaryList` shows `displayLabel` in expanded breakdown
- breakdown order is descending by `progressPercent`
- `ResponseDetailsPage` shows "غير محدد" when `quotaTargetId == null`
- `ResponseDetailsPage` shows the `displayLabel` row when `quotaTargetId != null`

### Integration / scenario
- **Online happy path:** login → start survey → answer all sections including bound questions → finalize → local quota +1 → refetch → server-truth equals local
- **Offline → online:** disconnect → start + answer + finalize → local quota +1 → reconnect → queue drains → refetch → counts match server
- **NULL match:** survey has bound NUMBER question (or stale binding) → local matcher returns null → no local increment → server matches at FINAL_SUBMIT → refetch shows count +1

## Risks

- **Backend bindings field not yet shipped.** Without it the matcher cannot run. Mitigation: land all non-matcher work first (model migration, dialog removal, UI changes, schema migration); merge the matcher hookup once the backend ships.
- **Stale local prediction vs server truth.** The local matcher knows only ENUM matching against the researcher's assigned coordinates. Any case the server resolves but the client doesn't (NUMBER/DATE, or coordinates outside the researcher's quotas) shows up as a transient `null` locally and reconciles on refetch — minor UX latency, no incorrect count persisted.
- **Cache wipe on first launch** loses the cached surveys; users must be online to see their assignments. Acceptable per Q6 (smart wipe chosen over migration).
- **Tests for the home breakdown sort order** must use stable progressPercent values to avoid flakiness with ties; tie-break by `displayLabel` string comparison.
