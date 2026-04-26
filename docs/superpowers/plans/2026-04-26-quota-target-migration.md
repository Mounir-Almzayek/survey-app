# QuotaTarget Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `gender`/`age_group` demographics with on-device scope-criterion matching that mirrors the backend `resolveQuotaTarget` algorithm. Local quota counts increment optimistically (online + offline) at FINAL_SUBMIT and reconcile against the server (source of truth) on every successful sync. The Sprint-6 demographic pre-screen is removed from both researcher and public-link flows.

**Architecture:** Two new pure-function services (`BindingInferer`, `QuotaMatcher`) in `lib/features/assignment/services/`. Inferer reconstructs `(question_id → scope_criterion_id)` bindings from the survey's `question_options` and the assignment's quota coordinates — runs once per survey fetch. Matcher walks those inferred bindings, resolves answers to categories, finds the unique `QuotaTarget` whose coordinates match exactly. Repository wires both services into the existing online + offline flows; on completion it writes `Response.quotaTargetId` and bumps local quota counters. A schema-version bump + Hive migration wipes incompatible cache and sanitizes queued requests on first launch with the new client.

**Tech Stack:** Flutter 3.9+, Dart 3, `flutter_bloc`, `dio`, `hive`, `equatable`, `shared_preferences`, `flutter_test`, `bloc_test`, `mocktail`.

**Spec:** [docs/superpowers/specs/2026-04-26-quota-target-migration-design.md](../specs/2026-04-26-quota-target-migration-design.md)

---

## File Structure

### Create
- `lib/core/models/survey/quota_coordinate.dart` — coordinate value object on a quota
- `lib/core/models/survey/scope_criterion_binding.dart` — inferred `(question_id → scope_criterion_id)` link, lives on `Survey`
- `lib/features/assignment/services/binding_inferer.dart` — `BindingInferer.infer(survey, assignment)` pure static
- `lib/features/assignment/services/quota_matcher.dart` — `QuotaMatcher.match(survey, assignment, answers)` pure static
- `lib/core/services/schema_migration_service.dart` — first-launch migration runner
- `lib/features/home/presentation/widgets/quota_breakdown_list.dart` — collapsible list of `display_label` rows
- `test/core/models/quota_coordinate_test.dart`
- `test/core/models/scope_criterion_binding_test.dart`
- `test/core/models/researcher_quota_model_test.dart`
- `test/core/models/response_model_test.dart`
- `test/features/responses/models/response_details_test.dart`
- `test/features/profile/models/researcher_profile_response_model_test.dart`
- `test/features/assignment/services/binding_inferer_test.dart`
- `test/features/assignment/services/quota_matcher_test.dart`
- `test/features/assignment/repository/assignment_repository_quota_test.dart`
- `test/features/assignment/bloc/start_response_bloc_test.dart`
- `test/features/public_links/bloc/public_link_answering_bloc_test.dart`
- `test/features/home/bloc/home_stats_bloc_test.dart`
- `test/core/services/schema_migration_service_test.dart`

### Modify
- `lib/core/models/survey/researcher_quota_model.dart` — drop gender/ageGroup, add quotaTargetId/displayLabel/coordinates
- `lib/features/profile/models/researcher_profile_response_model.dart` — same shape change on the inner quota model
- `lib/core/models/survey/response_model.dart` — drop gender/ageGroup, add quotaTargetId
- `lib/features/responses/models/response_details.dart` — add quotaTargetId/displayLabel/coordinates
- `lib/core/models/survey/survey_model.dart` — add `bindings: List<ScopeCriterionBinding>`
- `lib/features/assignment/models/start_response_request_model.dart` — drop gender/ageGroup
- `lib/features/public_links/repository/public_links_online_repository.dart` — drop gender/ageGroup from start body
- `lib/features/assignment/repository/assignment_repository.dart` — run inferer on fetch, run matcher on completion, rewrite `_incrementLocalQuotaForCompletedResponse`, add `refreshAllAssignments`
- `lib/features/assignment/bloc/start_response/start_response_bloc.dart` — drop UpdateGender/UpdateAgeGroup events + isDemographicQuotaFull check
- `lib/features/assignment/bloc/start_response/start_response_state.dart` — drop gender/ageGroup fields and isDemographicQuotaFull flag
- `lib/features/public_links/bloc/answering/public_link_answering_bloc.dart` — drop gender/ageGroup from StartAnswering event + handler
- `lib/features/home/bloc/home_stats/home_stats_bloc.dart` — replace gender/age aggregation with breakdown list
- `lib/features/home/models/survey_stats_model.dart` — replace genderProgress/ageGroupProgress with `breakdown: List<QuotaBreakdownEntry>`
- `lib/features/assignment/presentation/screens/survey_answering_screen.dart` — remove demographics dialog call
- `lib/features/public_links/presentation/public_link_answering_page.dart` — remove demographics dialog call
- `lib/features/home/presentation/widgets/quota_summary_list.dart` — integrate `QuotaBreakdownList` collapsible
- `lib/features/home/presentation/widgets/survey_stats_widget.dart` — remove DemographicCharts use
- `lib/features/responses/presentation/...` (response details screen) — show `display_label` row
- `lib/core/services/storage_service.dart` — add `currentSchemaVersion = 2`
- `lib/features/splash/bloc/splash_routing/splash_routing_bloc.dart` — invoke `SchemaMigrationService.runIfNeeded()` before any survey/profile read

### Delete
- `lib/features/assignment/presentation/widgets/demographics_dialog.dart`
- `lib/features/assignment/models/response_metadata.dart`
- `lib/features/home/presentation/widgets/demographic_charts.dart` (if it exists as a separate file)
- `Gender` and `AgeGroup` enums in `lib/core/enums/survey_enums.dart` (keep the file, remove the two enums + their extensions)
- l10n keys: `gender`, `gender_male`, `gender_female`, `select_gender`, `age_group`, `age_18_29`, `age_30_39`, `age_40_49`, `age_50_59`, `age_60_plus`, `select_age_group`, `demographic_quota_full_for_category`

---

## Implementation Phases

The 34 tasks below are grouped into 7 phases. Within a phase, tasks are independent unless one explicitly references another. Across phases, follow the order: A → B → C → D → E → F → G.

- **Phase A (Tasks 1–4):** Schema migration foundation. Lands first so the cache wipe is in place before any new model parser sees old data.
- **Phase B (Tasks 5–13):** Models. New value objects + modifications to existing models. No business logic yet.
- **Phase C (Tasks 14–15):** Pure services (`BindingInferer`, `QuotaMatcher`). Easy to TDD; no I/O.
- **Phase D (Tasks 16–22):** `AssignmentRepository` wiring. Inferer in fetch path, matcher in submit path, local quota increment by `quotaTargetId`, queue-drain hook.
- **Phase E (Tasks 23–25):** Bloc updates. Drop demographics events/state, rebuild Home stats aggregation.
- **Phase F (Tasks 26–31):** UI updates. Remove the dialog, add the breakdown widget, update detail/stats screens.
- **Phase G (Tasks 32–34):** Cleanup deletions. Files, enums, l10n keys.

---

## Phase A — Schema Migration Foundation

### Task 1: Schema version constant

**Files:**
- Modify: `lib/core/services/storage_service.dart`

- [ ] **Step 1: Open the file and locate a sensible constant section near the top.** If there isn't one, place the constant directly under the class declaration.

- [ ] **Step 2: Add the constant.**

```dart
/// Bumped whenever cached Hive boxes have an incompatible shape.
/// On startup, [SchemaMigrationService] compares this against the persisted
/// `schema_version` SharedPreference and runs a wipe + sanitize when they differ.
static const int currentSchemaVersion = 2;
```

- [ ] **Step 3: Verify it compiles.**

Run:
```bash
flutter analyze lib/core/services/storage_service.dart
```
Expected: `No issues found!`.

- [ ] **Step 4: Commit.**

```bash
git add lib/core/services/storage_service.dart
git commit -m "feat(storage): add currentSchemaVersion constant"
```

---

### Task 2: `SchemaMigrationService.runIfNeeded()` — wipe caches

**Files:**
- Create: `test/core/services/schema_migration_service_test.dart`
- Create: `lib/core/services/schema_migration_service.dart`

- [ ] **Step 1: Write the failing test.**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:king_abdulaziz_center_survey_app/core/services/schema_migration_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io' show Directory;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_migration_test');
    Hive.init(tempDir.path);
    await Hive.openBox<String>('cached_surveys_list');
    await Hive.openBox<String>('researcher_profile_cache');
    await Hive.openBox<String>('response_metadata_box');
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('SchemaMigrationService.runIfNeeded', () {
    test('wipes surveys/profile/metadata when schema_version is null', () async {
      final surveys = Hive.box<String>('cached_surveys_list');
      final profile = Hive.box<String>('researcher_profile_cache');
      final metadata = Hive.box<String>('response_metadata_box');
      await surveys.put('s1', '{"old":"shape"}');
      await profile.put('p', '{"old":"shape"}');
      await metadata.put('1', '{"gender":"MALE"}');

      final prefs = await SharedPreferences.getInstance();
      // schema_version unset → migration runs

      await SchemaMigrationService(prefs: prefs).runIfNeeded();

      expect(surveys.isEmpty, isTrue);
      expect(profile.isEmpty, isTrue);
      expect(metadata.isEmpty, isTrue);
      expect(prefs.getInt('schema_version'), 2);
    });

    test('is a no-op when schema_version already current', () async {
      final surveys = Hive.box<String>('cached_surveys_list');
      await surveys.put('s1', '{"new":"shape"}');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('schema_version', 2);

      await SchemaMigrationService(prefs: prefs).runIfNeeded();

      expect(surveys.get('s1'), '{"new":"shape"}');
    });

    test('is idempotent on repeat calls', () async {
      final prefs = await SharedPreferences.getInstance();
      final svc = SchemaMigrationService(prefs: prefs);
      await svc.runIfNeeded();
      await svc.runIfNeeded();
      expect(prefs.getInt('schema_version'), 2);
    });
  });
}
```

- [ ] **Step 2: Run the test, verify FAIL.**

```bash
flutter test test/core/services/schema_migration_service_test.dart
```
Expected: compile error — `SchemaMigrationService` does not exist.

- [ ] **Step 3: Create the service file.**

```dart
// lib/core/services/schema_migration_service.dart
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

/// Runs once per app launch (early, before any survey/profile read) to bring
/// the local cache in line with [StorageService.currentSchemaVersion].
///
/// When the persisted `schema_version` is older than the current value, this
/// clears the surveys cache, the profile cache, and the response-metadata
/// box, and (in a separate step) sanitizes queued requests of obsolete keys.
class SchemaMigrationService {
  static const String _versionKey = 'schema_version';
  static const String _surveysBoxName = 'cached_surveys_list';
  static const String _profileBoxName = 'researcher_profile_cache';
  static const String _metadataBoxName = 'response_metadata_box';

  final SharedPreferences prefs;

  SchemaMigrationService({required this.prefs});

  Future<void> runIfNeeded() async {
    final stored = prefs.getInt(_versionKey) ?? 1;
    if (stored >= StorageService.currentSchemaVersion) return;

    try {
      await _clearBox(_surveysBoxName);
      await _clearBox(_profileBoxName);
      await _clearBox(_metadataBoxName);
      await prefs.setInt(_versionKey, StorageService.currentSchemaVersion);
    } catch (e, st) {
      // Log but do not bump version; next launch retries.
      // ignore: avoid_print
      print('SchemaMigrationService failed: $e\n$st');
    }
  }

  Future<void> _clearBox(String name) async {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox<String>(name);
    }
    final box = Hive.box<String>(name);
    await box.clear();
  }
}
```

- [ ] **Step 4: Run the tests, verify PASS.**

```bash
flutter test test/core/services/schema_migration_service_test.dart
```
Expected: all 3 tests green.

- [ ] **Step 5: Commit.**

```bash
git add lib/core/services/schema_migration_service.dart test/core/services/schema_migration_service_test.dart
git commit -m "feat(migration): SchemaMigrationService clears stale caches on version bump"
```

---

### Task 3: Migration sanitizes the request queue

**Files:**
- Modify: `lib/core/services/schema_migration_service.dart`
- Modify: `test/core/services/schema_migration_service_test.dart`

- [ ] **Step 1: Add the failing tests for queue sanitization.**

Append the following test group to `test/core/services/schema_migration_service_test.dart` inside the existing `group('SchemaMigrationService.runIfNeeded', () { ... });`:

```dart
test('sanitizes queue: removes gender + age_group keys from start request bodies', () async {
  await Hive.openBox<String>('request_queue_box');
  final queue = Hive.box<String>('request_queue_box');
  await queue.put('q1', '{"path":"/researcher/assignment/survey/1/start","method":"POST","body":"{\\"gender\\":\\"MALE\\",\\"age_group\\":\\"AGE_18_29\\",\\"location\\":{\\"latitude\\":1.0,\\"longitude\\":2.0}}"}');

  final prefs = await SharedPreferences.getInstance();
  await SchemaMigrationService(prefs: prefs).runIfNeeded();

  final after = queue.get('q1');
  expect(after, isNotNull);
  expect(after, contains('"location"'));
  expect(after, isNot(contains('"gender"')));
  expect(after, isNot(contains('"age_group"')));
});

test('sanitize is a no-op for items with no body or no demographics', () async {
  await Hive.openBox<String>('request_queue_box');
  final queue = Hive.box<String>('request_queue_box');
  await queue.put('section', '{"path":"/x","method":"POST","body":"{\\"answers\\":[]}"}');
  await queue.put('nobody', '{"path":"/y","method":"GET"}');

  final prefs = await SharedPreferences.getInstance();
  await SchemaMigrationService(prefs: prefs).runIfNeeded();

  expect(queue.get('section'), contains('"answers"'));
  expect(queue.get('nobody'), '{"path":"/y","method":"GET"}');
});
```

Also extend the `setUp` to open the queue box:
```dart
await Hive.openBox<String>('request_queue_box');
```

- [ ] **Step 2: Run the tests, verify FAIL.**

```bash
flutter test test/core/services/schema_migration_service_test.dart
```
Expected: the two new tests fail because queue is untouched.

- [ ] **Step 3: Implement queue sanitization.**

In `lib/core/services/schema_migration_service.dart`, add the constant + new private method, and call it from `runIfNeeded()` before bumping the version:

```dart
import 'dart:convert';
// ... existing imports

class SchemaMigrationService {
  // ... existing constants
  static const String _queueBoxName = 'request_queue_box';

  // ... existing constructor + runIfNeeded body, but insert this call
  // BEFORE `await prefs.setInt(...)`:
  //
  //   await _sanitizeQueue();

  Future<void> _sanitizeQueue() async {
    if (!Hive.isBoxOpen(_queueBoxName)) {
      await Hive.openBox<String>(_queueBoxName);
    }
    final box = Hive.box<String>(_queueBoxName);
    for (final key in box.keys.toList()) {
      final raw = box.get(key);
      if (raw == null) continue;
      try {
        final envelope = jsonDecode(raw) as Map<String, dynamic>;
        final bodyStr = envelope['body'];
        if (bodyStr is! String || bodyStr.isEmpty) continue;
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;
        final hadGender = body.remove('gender') != null;
        final hadAge = body.remove('age_group') != null;
        if (hadGender || hadAge) {
          envelope['body'] = jsonEncode(body);
          await box.put(key, jsonEncode(envelope));
        }
      } catch (_) {
        // Malformed entry — leave as-is rather than dropping user data.
      }
    }
  }
}
```

Update `runIfNeeded()`:
```dart
Future<void> runIfNeeded() async {
  final stored = prefs.getInt(_versionKey) ?? 1;
  if (stored >= StorageService.currentSchemaVersion) return;

  try {
    await _clearBox(_surveysBoxName);
    await _clearBox(_profileBoxName);
    await _clearBox(_metadataBoxName);
    await _sanitizeQueue();
    await prefs.setInt(_versionKey, StorageService.currentSchemaVersion);
  } catch (e, st) {
    // ignore: avoid_print
    print('SchemaMigrationService failed: $e\n$st');
  }
}
```

- [ ] **Step 4: Run the tests, verify PASS.**

```bash
flutter test test/core/services/schema_migration_service_test.dart
```
Expected: all tests green.

- [ ] **Step 5: Commit.**

```bash
git add lib/core/services/schema_migration_service.dart test/core/services/schema_migration_service_test.dart
git commit -m "feat(migration): strip gender/age_group from queued start requests"
```

---

### Task 4: Wire `SchemaMigrationService` into splash routing

**Files:**
- Modify: `lib/features/splash/bloc/splash_routing/splash_routing_bloc.dart`

- [ ] **Step 1: Locate the bloc's startup sequence.** Read the file and find the earliest async hook that runs before any survey/profile read (typically a `_loadInitialState` handler or the constructor).

- [ ] **Step 2: Add the migration call.**

Near the top of that hook, before any read from `cached_surveys_list` or `researcher_profile_cache`, insert:

```dart
import 'package:king_abdulaziz_center_survey_app/core/services/schema_migration_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ... existing imports

// Inside the startup hook, before any survey/profile read:
final prefs = await SharedPreferences.getInstance();
await SchemaMigrationService(prefs: prefs).runIfNeeded();
```

- [ ] **Step 3: Verify it compiles.**

```bash
flutter analyze lib/features/splash/
```
Expected: `No issues found!`.

- [ ] **Step 4: Commit.**

```bash
git add lib/features/splash/bloc/splash_routing/splash_routing_bloc.dart
git commit -m "feat(splash): run schema migration before any cache read"
```

---

## Phase B — Models

### Task 5: `QuotaCoordinate` value object

**Files:**
- Create: `test/core/models/quota_coordinate_test.dart`
- Create: `lib/core/models/survey/quota_coordinate.dart`

- [ ] **Step 1: Write the failing test.**

```dart
// test/core/models/quota_coordinate_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/quota_coordinate.dart';

void main() {
  group('QuotaCoordinate', () {
    final json = {
      'scope_criterion_id': 3,
      'criterion_name': 'Gender',
      'scope_criterion_category_id': 11,
      'category_label': 'ذكر',
      'category_value': 'male',
      'order': 3,
    };

    test('fromJson parses all fields', () {
      final c = QuotaCoordinate.fromJson(json);
      expect(c.scopeCriterionId, 3);
      expect(c.criterionName, 'Gender');
      expect(c.scopeCriterionCategoryId, 11);
      expect(c.categoryLabel, 'ذكر');
      expect(c.categoryValue, 'male');
      expect(c.order, 3);
    });

    test('toJson round-trips', () {
      final c = QuotaCoordinate.fromJson(json);
      expect(c.toJson(), json);
    });

    test('equality is structural', () {
      final a = QuotaCoordinate.fromJson(json);
      final b = QuotaCoordinate.fromJson(json);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('preserves Arabic category_label byte-exact', () {
      final c = QuotaCoordinate.fromJson(json);
      expect(c.categoryLabel.codeUnits, 'ذكر'.codeUnits);
    });
  });
}
```

- [ ] **Step 2: Run the test, verify FAIL.**

```bash
flutter test test/core/models/quota_coordinate_test.dart
```
Expected: compile error — class missing.

- [ ] **Step 3: Implement.**

```dart
// lib/core/models/survey/quota_coordinate.dart
import 'package:equatable/equatable.dart';

/// One axis of a [QuotaTarget]'s identity. The full coordinate set of a target
/// uniquely identifies it within a sampling scope.
class QuotaCoordinate extends Equatable {
  final int scopeCriterionId;
  final String criterionName;
  final int scopeCriterionCategoryId;
  final String categoryLabel;
  final String categoryValue;
  final int order;

  const QuotaCoordinate({
    required this.scopeCriterionId,
    required this.criterionName,
    required this.scopeCriterionCategoryId,
    required this.categoryLabel,
    required this.categoryValue,
    required this.order,
  });

  factory QuotaCoordinate.fromJson(Map<String, dynamic> json) {
    return QuotaCoordinate(
      scopeCriterionId: json['scope_criterion_id'] as int,
      criterionName: json['criterion_name'] as String,
      scopeCriterionCategoryId: json['scope_criterion_category_id'] as int,
      categoryLabel: json['category_label'] as String,
      categoryValue: json['category_value'] as String,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'scope_criterion_id': scopeCriterionId,
    'criterion_name': criterionName,
    'scope_criterion_category_id': scopeCriterionCategoryId,
    'category_label': categoryLabel,
    'category_value': categoryValue,
    'order': order,
  };

  @override
  List<Object?> get props => [
    scopeCriterionId,
    criterionName,
    scopeCriterionCategoryId,
    categoryLabel,
    categoryValue,
    order,
  ];
}
```

- [ ] **Step 4: Run the test, verify PASS.**

```bash
flutter test test/core/models/quota_coordinate_test.dart
```
Expected: all tests green.

- [ ] **Step 5: Commit.**

```bash
git add lib/core/models/survey/quota_coordinate.dart test/core/models/quota_coordinate_test.dart
git commit -m "feat(models): add QuotaCoordinate value object"
```

---

### Task 6: `ScopeCriterionBinding` value object

**Files:**
- Create: `test/core/models/scope_criterion_binding_test.dart`
- Create: `lib/core/models/survey/scope_criterion_binding.dart`

- [ ] **Step 1: Write the failing test.**

```dart
// test/core/models/scope_criterion_binding_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/scope_criterion_binding.dart';

void main() {
  group('ScopeCriterionBinding', () {
    test('fromJson + toJson round-trip', () {
      final json = {'source_question_id': 42, 'scope_criterion_id': 3};
      final b = ScopeCriterionBinding.fromJson(json);
      expect(b.sourceQuestionId, 42);
      expect(b.scopeCriterionId, 3);
      expect(b.toJson(), json);
    });

    test('equality is structural', () {
      final a = ScopeCriterionBinding(sourceQuestionId: 1, scopeCriterionId: 2);
      final b = ScopeCriterionBinding(sourceQuestionId: 1, scopeCriterionId: 2);
      expect(a, b);
    });
  });
}
```

- [ ] **Step 2: Run, verify FAIL.**

```bash
flutter test test/core/models/scope_criterion_binding_test.dart
```

- [ ] **Step 3: Implement.**

```dart
// lib/core/models/survey/scope_criterion_binding.dart
import 'package:equatable/equatable.dart';

/// Inferred link from a survey [Question] to a [ScopeCriterion]. Populated by
/// [BindingInferer] after the survey is fetched and persisted on
/// [Survey.bindings] in the local cache.
class ScopeCriterionBinding extends Equatable {
  final int sourceQuestionId;
  final int scopeCriterionId;

  const ScopeCriterionBinding({
    required this.sourceQuestionId,
    required this.scopeCriterionId,
  });

  factory ScopeCriterionBinding.fromJson(Map<String, dynamic> json) {
    return ScopeCriterionBinding(
      sourceQuestionId: json['source_question_id'] as int,
      scopeCriterionId: json['scope_criterion_id'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'source_question_id': sourceQuestionId,
    'scope_criterion_id': scopeCriterionId,
  };

  @override
  List<Object?> get props => [sourceQuestionId, scopeCriterionId];
}
```

- [ ] **Step 4: Run, verify PASS.**

```bash
flutter test test/core/models/scope_criterion_binding_test.dart
```

- [ ] **Step 5: Commit.**

```bash
git add lib/core/models/survey/scope_criterion_binding.dart test/core/models/scope_criterion_binding_test.dart
git commit -m "feat(models): add ScopeCriterionBinding value object"
```

---

### Task 7: `ResearcherQuota` new shape (drop gender/age, add quotaTargetId/displayLabel/coordinates)

**Files:**
- Create: `test/core/models/researcher_quota_model_test.dart`
- Modify: `lib/core/models/survey/researcher_quota_model.dart`

- [ ] **Step 1: Write the failing test.**

```dart
// test/core/models/researcher_quota_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/quota_coordinate.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/researcher_quota_model.dart';

void main() {
  group('ResearcherQuota.fromJson (new shape)', () {
    final wire = {
      'id': 1001,
      'quota_id': 501,
      'assignment_id': 77,
      'quota_target_id': 301,
      'target': 10,
      'limit': 10,
      'progress': 4,
      'used': 4,
      'collected': 4,
      'remaining': 6,
      'responses_count': 4,
      'progress_percent': 40,
      'display_label': 'منطقة الباحة • ذكر • 18-29',
      'coordinates': [
        {
          'scope_criterion_id': 1,
          'criterion_name': 'Region',
          'scope_criterion_category_id': 5,
          'category_label': 'منطقة الباحة',
          'category_value': 'baha',
          'order': 1,
        },
        {
          'scope_criterion_id': 3,
          'criterion_name': 'Gender',
          'scope_criterion_category_id': 11,
          'category_label': 'ذكر',
          'category_value': 'male',
          'order': 3,
        },
      ],
    };

    test('parses new fields', () {
      final q = ResearcherQuota.fromJson(wire);
      expect(q.id, 1001);
      expect(q.quotaTargetId, 301);
      expect(q.target, 10);
      expect(q.progress, 4);
      expect(q.collected, 4);
      expect(q.responsesCountInCategory, 4);
      expect(q.serverRemaining, 6);
      expect(q.displayLabel, 'منطقة الباحة • ذكر • 18-29');
      expect(q.coordinates.length, 2);
      expect(q.coordinates.first, isA<QuotaCoordinate>());
    });

    test('quotaTargetId is nullable', () {
      final q = ResearcherQuota.fromJson({...wire, 'quota_target_id': null});
      expect(q.quotaTargetId, isNull);
    });

    test('legacy gender/age_group keys are silently ignored', () {
      final legacy = {...wire, 'gender': 'MALE', 'age_group': 'AGE_18_29'};
      final q = ResearcherQuota.fromJson(legacy);
      expect(q.id, 1001);
      // Compiles + parses; no field present to read.
    });

    test('toJson round-trips new shape', () {
      final q = ResearcherQuota.fromJson(wire);
      final out = q.toJson();
      expect(out['quota_target_id'], 301);
      expect(out['display_label'], 'منطقة الباحة • ذكر • 18-29');
      expect((out['coordinates'] as List).length, 2);
      expect(out.containsKey('gender'), isFalse);
      expect(out.containsKey('age_group'), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run, verify FAIL.**

```bash
flutter test test/core/models/researcher_quota_model_test.dart
```

- [ ] **Step 3: Replace `lib/core/models/survey/researcher_quota_model.dart` with the new shape.**

```dart
import 'package:equatable/equatable.dart';
import 'assignment_model.dart';
import 'quota_coordinate.dart';

/// ResearcherQuota — one cell of a researcher's assigned quota plan.
///
/// The bucket is identified by [quotaTargetId] (NULL when no target is
/// resolved yet). [coordinates] describe the bucket's `(criterion, category)`
/// axes; [displayLabel] is a server-built human-readable summary in Arabic.
class ResearcherQuota extends Equatable {
  /// Backend quota row id (may mirror [id] when API sends `quota_id`).
  final int quotaId;
  final int id;
  final int assignmentId;
  /// Identifier of the matching `QuotaTarget`. `null` when no target is yet
  /// resolved for this row (e.g., placeholder before assignment).
  final int? quotaTargetId;
  final int target;
  final int progress;
  final int collected;
  final num progressPercent;
  /// When set, reflects the API `remaining` value (authoritative over [target]-[progress]).
  final int? serverRemaining;
  /// Optional per-bucket count from API (`responses_count`).
  final int? responsesCountInCategory;
  /// Server-built display label, joined from coordinate labels with `" • "`.
  /// Always rendered as-is (Arabic).
  final String displayLabel;
  /// Coordinates that identify this quota bucket.
  final List<QuotaCoordinate> coordinates;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final Assignment? assignment;

  const ResearcherQuota({
    this.quotaId = 0,
    required this.id,
    required this.assignmentId,
    this.quotaTargetId,
    required this.target,
    this.progress = 0,
    this.collected = 0,
    this.progressPercent = 0,
    this.serverRemaining,
    this.responsesCountInCategory,
    this.displayLabel = '',
    this.coordinates = const [],
    required this.createdAt,
    required this.updatedAt,
    this.assignment,
  });

  ResearcherQuota copyWith({
    int? quotaId,
    int? id,
    int? assignmentId,
    int? quotaTargetId,
    bool clearQuotaTargetId = false,
    int? target,
    int? progress,
    int? collected,
    num? progressPercent,
    int? serverRemaining,
    bool clearServerRemaining = false,
    int? responsesCountInCategory,
    bool clearResponsesCountInCategory = false,
    String? displayLabel,
    List<QuotaCoordinate>? coordinates,
    DateTime? createdAt,
    DateTime? updatedAt,
    Assignment? assignment,
  }) {
    return ResearcherQuota(
      quotaId: quotaId ?? this.quotaId,
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      quotaTargetId: clearQuotaTargetId ? null : (quotaTargetId ?? this.quotaTargetId),
      target: target ?? this.target,
      progress: progress ?? this.progress,
      collected: collected ?? this.collected,
      progressPercent: progressPercent ?? this.progressPercent,
      serverRemaining: clearServerRemaining ? null : (serverRemaining ?? this.serverRemaining),
      responsesCountInCategory: clearResponsesCountInCategory
          ? null
          : (responsesCountInCategory ?? this.responsesCountInCategory),
      displayLabel: displayLabel ?? this.displayLabel,
      coordinates: coordinates ?? this.coordinates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignment: assignment ?? this.assignment,
    );
  }

  factory ResearcherQuota.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'] as int? ?? json['quota_id'] as int? ?? 0;
    final quotaIdVal = json['quota_id'] as int? ?? idVal;
    final targetVal = json['target'] as int? ?? json['limit'] as int? ?? 0;
    final progressVal = json['progress'] as int? ?? json['used'] as int? ?? 0;
    final collectedVal =
        json['collected'] as int? ?? json['used'] as int? ?? progressVal;

    int? parseOptionalInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.round();
      return int.tryParse(v.toString());
    }

    final coordsRaw = json['coordinates'];
    final coords = coordsRaw is List
        ? coordsRaw
            .whereType<Map<String, dynamic>>()
            .map(QuotaCoordinate.fromJson)
            .toList()
        : <QuotaCoordinate>[];

    return ResearcherQuota(
      quotaId: quotaIdVal,
      id: idVal,
      assignmentId: json['assignment_id'] as int? ?? 0,
      quotaTargetId: parseOptionalInt(json['quota_target_id']),
      target: targetVal,
      progress: progressVal,
      collected: collectedVal,
      progressPercent: (json['progress_percent'] as num?) ?? 0,
      serverRemaining: parseOptionalInt(json['remaining']),
      responsesCountInCategory: parseOptionalInt(json['responses_count']),
      displayLabel: (json['display_label'] as String?) ?? '',
      coordinates: coords,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      assignment: json['assignment'] != null
          ? Assignment.fromJson(json['assignment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'quota_id': quotaId,
    'id': id,
    'assignment_id': assignmentId,
    if (quotaTargetId != null) 'quota_target_id': quotaTargetId,
    'target': target,
    'progress': progress,
    'collected': collected,
    'progress_percent': progressPercent,
    if (serverRemaining != null) 'remaining': serverRemaining,
    if (responsesCountInCategory != null)
      'responses_count': responsesCountInCategory,
    'display_label': displayLabel,
    'coordinates': coordinates.map((c) => c.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'assignment': assignment?.toJson(),
  };

  /// Remaining slots: prefers API [serverRemaining] when present.
  int get remaining {
    if (serverRemaining != null) return serverRemaining!;
    if (target <= 0) return 0;
    final diff = target - progress;
    return diff < 0 ? 0 : diff;
  }

  /// True when this bucket cannot accept more responses (server-first).
  bool get isQuotaFull {
    if (target <= 0) return false;
    if (serverRemaining != null) return serverRemaining! <= 0;
    return progress >= target;
  }

  bool get isCompleted => isQuotaFull;

  /// Get completion percentage (prefers API [progressPercent] when non-zero).
  double get completionPercentage {
    if (target <= 0) return 0;
    if (progressPercent > 0) return progressPercent.toDouble().clamp(0, 100);
    return ((progress / target) * 100).clamp(0, 100);
  }

  bool get isNearlyComplete => completionPercentage >= 80;

  /// Opacity (0.0–1.0) for primary color in progress UI based on state.
  double get progressDisplayAlpha {
    if (isCompleted) return 1.0;
    if (isNearlyComplete) return 0.85;
    if (progress > 0) return 0.65;
    return 0.45;
  }

  @override
  List<Object?> get props => [
    quotaId,
    id,
    assignmentId,
    quotaTargetId,
    target,
    progress,
    collected,
    progressPercent,
    serverRemaining,
    responsesCountInCategory,
    displayLabel,
    coordinates,
    createdAt,
    updatedAt,
    assignment,
  ];
}
```

Note: this delete removes the now-dead `localizedStatusDescription`/`statusDescription`/`demographicDescription`/`localizedDemographicDescription` methods. They were only consumed by the demographics dialog, which is being deleted.

- [ ] **Step 4: Run, verify PASS.**

```bash
flutter test test/core/models/researcher_quota_model_test.dart
```

- [ ] **Step 5: Commit.**

```bash
git add lib/core/models/survey/researcher_quota_model.dart test/core/models/researcher_quota_model_test.dart
git commit -m "feat(models): ResearcherQuota uses quotaTargetId + displayLabel + coordinates"
```

Note: this temporarily breaks compilation of any file that references `ResearcherQuota.gender` / `.ageGroup` / `.demographicDescription`. That's expected; subsequent tasks fix each call site.

---

### Task 8: Profile `ResearcherQuotaModel` matches new shape

**Files:**
- Create: `test/features/profile/models/researcher_profile_response_model_test.dart`
- Modify: `lib/features/profile/models/researcher_profile_response_model.dart`

- [ ] **Step 1: Write the failing test.**

```dart
// test/features/profile/models/researcher_profile_response_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/profile/models/researcher_profile_response_model.dart';

void main() {
  group('Profile ResearcherQuotaModel.fromJson', () {
    final wire = {
      'id': 1001,
      'quota_id': 501,
      'assignment_id': 77,
      'quota_target_id': 301,
      'target': 10,
      'limit': 10,
      'progress': 4,
      'used': 4,
      'collected': 4,
      'remaining': 6,
      'responses_count': 4,
      'progress_percent': 40,
      'display_label': 'منطقة الباحة • ذكر • 18-29',
      'coordinates': [
        {
          'scope_criterion_id': 3,
          'criterion_name': 'Gender',
          'scope_criterion_category_id': 11,
          'category_label': 'ذكر',
          'category_value': 'male',
          'order': 3,
        },
      ],
    };

    test('exposes quotaTargetId/displayLabel/coordinates', () {
      final q = ResearcherQuotaModel.fromJson(wire);
      expect(q.quotaTargetId, 301);
      expect(q.displayLabel, 'منطقة الباحة • ذكر • 18-29');
      expect(q.coordinates.length, 1);
    });

    test('legacy gender/age_group are ignored', () {
      final q = ResearcherQuotaModel.fromJson({...wire, 'gender': 'MALE', 'age_group': 'AGE_18_29'});
      expect(q.quotaTargetId, 301);
    });
  });
}
```

- [ ] **Step 2: Run, verify FAIL.**

```bash
flutter test test/features/profile/models/researcher_profile_response_model_test.dart
```

- [ ] **Step 3: In `lib/features/profile/models/researcher_profile_response_model.dart`, locate the inner `ResearcherQuotaModel` class (around line 184).**

Replace it with:

```dart
import 'package:king_abdulaziz_center_survey_app/core/models/survey/quota_coordinate.dart';

class ResearcherQuotaModel {
  final int id;
  final int quotaId;
  final int assignmentId;
  final int? quotaTargetId;
  final int target;
  final int progress;
  final int collected;
  final int? serverRemaining;
  final int? responsesCount;
  final num progressPercent;
  final String displayLabel;
  final List<QuotaCoordinate> coordinates;
  final DateTime createdAt;
  final DateTime updatedAt;

  ResearcherQuotaModel({
    required this.id,
    required this.quotaId,
    required this.assignmentId,
    this.quotaTargetId,
    required this.target,
    this.progress = 0,
    this.collected = 0,
    this.serverRemaining,
    this.responsesCount,
    this.progressPercent = 0,
    this.displayLabel = '',
    this.coordinates = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ResearcherQuotaModel.fromJson(Map<String, dynamic> json) {
    int? parseOptionalInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.round();
      return int.tryParse(v.toString());
    }

    final coordsRaw = json['coordinates'];
    final coords = coordsRaw is List
        ? coordsRaw
            .whereType<Map<String, dynamic>>()
            .map(QuotaCoordinate.fromJson)
            .toList()
        : <QuotaCoordinate>[];

    return ResearcherQuotaModel(
      id: json['id'] as int? ?? 0,
      quotaId: json['quota_id'] as int? ?? json['id'] as int? ?? 0,
      assignmentId: json['assignment_id'] as int? ?? 0,
      quotaTargetId: parseOptionalInt(json['quota_target_id']),
      target: json['target'] as int? ?? json['limit'] as int? ?? 0,
      progress: json['progress'] as int? ?? json['used'] as int? ?? 0,
      collected: json['collected'] as int? ?? json['used'] as int? ?? 0,
      serverRemaining: parseOptionalInt(json['remaining']),
      responsesCount: parseOptionalInt(json['responses_count']),
      progressPercent: (json['progress_percent'] as num?) ?? 0,
      displayLabel: (json['display_label'] as String?) ?? '',
      coordinates: coords,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'quota_id': quotaId,
    'assignment_id': assignmentId,
    if (quotaTargetId != null) 'quota_target_id': quotaTargetId,
    'target': target,
    'progress': progress,
    'collected': collected,
    if (serverRemaining != null) 'remaining': serverRemaining,
    if (responsesCount != null) 'responses_count': responsesCount,
    'progress_percent': progressPercent,
    'display_label': displayLabel,
    'coordinates': coordinates.map((c) => c.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
```

- [ ] **Step 4: Run, verify PASS.**

```bash
flutter test test/features/profile/models/researcher_profile_response_model_test.dart
```

- [ ] **Step 5: Commit.**

```bash
git add lib/features/profile/models/researcher_profile_response_model.dart test/features/profile/models/researcher_profile_response_model_test.dart
git commit -m "feat(profile): ResearcherQuotaModel uses quotaTargetId + displayLabel + coordinates"
```

---

### Task 9: `Response` model — drop gender/ageGroup, add quotaTargetId

**Files:**
- Create: `test/core/models/response_model_test.dart`
- Modify: `lib/core/models/survey/response_model.dart`

- [ ] **Step 1: Write the failing test.**

```dart
// test/core/models/response_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/response_model.dart';

void main() {
  group('Response.fromJson (new shape)', () {
    test('parses quotaTargetId when present', () {
      final r = Response.fromJson({
        'id': 5,
        'survey_id': 1,
        'assignment_id': 7,
        'status': 'DRAFT',
        'quota_target_id': 301,
      });
      expect(r.id, 5);
      expect(r.quotaTargetId, 301);
    });

    test('quotaTargetId is null when absent', () {
      final r = Response.fromJson({
        'id': 5,
        'survey_id': 1,
        'assignment_id': 7,
        'status': 'DRAFT',
      });
      expect(r.quotaTargetId, isNull);
    });

    test('ignores legacy gender/age_group keys', () {
      final r = Response.fromJson({
        'id': 5,
        'survey_id': 1,
        'assignment_id': 7,
        'status': 'DRAFT',
        'gender': 'MALE',
        'age_group': 'AGE_18_29',
      });
      expect(r.id, 5); // parses cleanly
    });

    test('toJson does not emit gender/age_group', () {
      final r = Response.fromJson({
        'id': 5,
        'survey_id': 1,
        'assignment_id': 7,
        'status': 'DRAFT',
        'quota_target_id': 301,
      });
      final j = r.toJson();
      expect(j['quota_target_id'], 301);
      expect(j.containsKey('gender'), isFalse);
      expect(j.containsKey('age_group'), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run, verify FAIL.**

```bash
flutter test test/core/models/response_model_test.dart
```

- [ ] **Step 3: In `lib/core/models/survey/response_model.dart`, replace the gender/ageGroup fields with `quotaTargetId`.**

Locate the field block (around line 16-17) and:
1. Remove `final Gender? gender;` and `final AgeGroup? ageGroup;`.
2. Add `final int? quotaTargetId;`.
3. Update the constructor: drop `this.gender`, `this.ageGroup`; add `this.quotaTargetId`.
4. Update `copyWith`: drop gender/ageGroup; add `quotaTargetId` + `clearQuotaTargetId` flag.
5. Update `fromJson`: drop the `Gender.fromJson(json['gender'])` etc.; add `quotaTargetId: (json['quota_target_id'] as num?)?.toInt()`.
6. Update `toJson`: drop `'gender'` and `'age_group'` entries; add `if (quotaTargetId != null) 'quota_target_id': quotaTargetId`.
7. Update `props`: remove `gender, ageGroup`; add `quotaTargetId`.
8. Remove the `import` of `Gender`/`AgeGroup` if those were the only references.

- [ ] **Step 4: Run, verify PASS.**

```bash
flutter test test/core/models/response_model_test.dart
```

- [ ] **Step 5: Commit.**

```bash
git add lib/core/models/survey/response_model.dart test/core/models/response_model_test.dart
git commit -m "feat(models): Response.quotaTargetId replaces gender/ageGroup"
```

---

### Task 10: `ResponseDetails` — add quotaTargetId, displayLabel, coordinates

**Files:**
- Create: `test/features/responses/models/response_details_test.dart`
- Modify: `lib/features/responses/models/response_details.dart`

- [ ] **Step 1: Write the failing test.**

```dart
// test/features/responses/models/response_details_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/responses/models/response_details.dart';

void main() {
  group('ResponseDetails new fields', () {
    test('parses quotaTargetId/displayLabel/coordinates when present', () {
      final d = ResponseDetails.fromJson({
        'id': 5,
        'status': 'SUBMITTED',
        'started_at': '2026-04-26T10:00:00Z',
        'duration_sec': 0,
        'answers': [],
        'quota_target_id': 301,
        'display_label': 'منطقة الباحة • ذكر • 18-29',
        'coordinates': [
          {
            'scope_criterion_id': 3,
            'criterion_name': 'Gender',
            'scope_criterion_category_id': 11,
            'category_label': 'ذكر',
            'category_value': 'male',
            'order': 3,
          }
        ],
      });
      expect(d.quotaTargetId, 301);
      expect(d.displayLabel, 'منطقة الباحة • ذكر • 18-29');
      expect(d.coordinates!.length, 1);
    });

    test('NULL quotaTargetId is supported', () {
      final d = ResponseDetails.fromJson({
        'id': 5,
        'status': 'SUBMITTED',
        'started_at': '2026-04-26T10:00:00Z',
        'duration_sec': 0,
        'answers': [],
      });
      expect(d.quotaTargetId, isNull);
      expect(d.displayLabel, isNull);
      expect(d.coordinates, isNull);
    });
  });
}
```

- [ ] **Step 2: Run, verify FAIL.**

```bash
flutter test test/features/responses/models/response_details_test.dart
```

- [ ] **Step 3: In `lib/features/responses/models/response_details.dart`, add the three new fields.**

```dart
import 'package:king_abdulaziz_center_survey_app/core/models/survey/quota_coordinate.dart';
// ... existing imports

class ResponseDetails extends Equatable {
  // ... existing fields
  final int? quotaTargetId;
  final String? displayLabel;
  final List<QuotaCoordinate>? coordinates;

  const ResponseDetails({
    // ... existing required/named params
    this.quotaTargetId,
    this.displayLabel,
    this.coordinates,
  });

  factory ResponseDetails.fromJson(Map<String, dynamic> json) {
    final coordsRaw = json['coordinates'];
    final coords = coordsRaw is List
        ? coordsRaw
            .whereType<Map<String, dynamic>>()
            .map(QuotaCoordinate.fromJson)
            .toList()
        : null;

    return ResponseDetails(
      // ... existing field assignments
      quotaTargetId: (json['quota_target_id'] as num?)?.toInt(),
      displayLabel: json['display_label'] as String?,
      coordinates: coords,
    );
  }

  Map<String, dynamic> toJson() => {
    // ... existing entries
    if (quotaTargetId != null) 'quota_target_id': quotaTargetId,
    if (displayLabel != null) 'display_label': displayLabel,
    if (coordinates != null)
      'coordinates': coordinates!.map((c) => c.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    // ... existing props
    quotaTargetId,
    displayLabel,
    coordinates,
  ];
}
```

- [ ] **Step 4: Run, verify PASS.**

```bash
flutter test test/features/responses/models/response_details_test.dart
```

- [ ] **Step 5: Commit.**

```bash
git add lib/features/responses/models/response_details.dart test/features/responses/models/response_details_test.dart
git commit -m "feat(responses): ResponseDetails carries quotaTargetId + displayLabel + coordinates"
```

---

### Task 11: `Survey` — add `bindings: List<ScopeCriterionBinding>`

**Files:**
- Modify: `lib/core/models/survey/survey_model.dart`

- [ ] **Step 1: Open the file.** Locate the Survey class field block and the `fromJson`/`toJson`/`copyWith`/`props`.

- [ ] **Step 2: Add the field with a sensible default and round-trip in JSON.**

Add these changes:

```dart
import 'scope_criterion_binding.dart';
// ... existing imports

class Survey extends Equatable {
  // ... existing fields
  /// Inferred (question_id → scope_criterion_id) bindings used by
  /// [QuotaMatcher]. Populated by [BindingInferer] in
  /// [AssignmentRepository] after fetch; persisted in the local cache so
  /// the matcher works even when the next session starts offline.
  final List<ScopeCriterionBinding> bindings;

  const Survey({
    // ... existing params
    this.bindings = const [],
  });

  Survey copyWith({
    // ... existing params
    List<ScopeCriterionBinding>? bindings,
  }) {
    return Survey(
      // ... existing assignments
      bindings: bindings ?? this.bindings,
    );
  }

  factory Survey.fromJson(Map<String, dynamic> json) {
    final bindingsRaw = json['bindings'];
    final bindings = bindingsRaw is List
        ? bindingsRaw
            .whereType<Map<String, dynamic>>()
            .map(ScopeCriterionBinding.fromJson)
            .toList()
        : <ScopeCriterionBinding>[];

    return Survey(
      // ... existing assignments
      bindings: bindings,
    );
  }

  Map<String, dynamic> toJson() => {
    // ... existing entries
    if (bindings.isNotEmpty)
      'bindings': bindings.map((b) => b.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    // ... existing props
    bindings,
  ];
}
```

- [ ] **Step 3: Verify it compiles.**

```bash
flutter analyze lib/core/models/survey/survey_model.dart
```
Expected: `No issues found!`.

- [ ] **Step 4: Commit.**

```bash
git add lib/core/models/survey/survey_model.dart
git commit -m "feat(models): Survey carries inferred bindings list"
```

---

### Task 12: `StartResponseRequest` — drop `gender` and `ageGroup`

**Files:**
- Modify: `lib/features/assignment/models/start_response_request_model.dart`
- Update: `test/features/assignment/models/start_response_request_model_test.dart` (if present from earlier feature)

- [ ] **Step 1: Replace the file contents.**

```dart
// lib/features/assignment/models/start_response_request_model.dart
import 'package:equatable/equatable.dart';

/// Model for starting a survey response request.
///
/// As of the QuotaTarget migration the body carries only [location] and
/// [createdAt]; quota matching now happens at FINAL_SUBMIT on the server.
class StartResponseRequest extends Equatable {
  final int surveyId;
  final Map<String, double>? location;

  /// Wall-clock time captured when this request DTO was built. Sent as
  /// `created_at` so the server can record the moment of user action even
  /// when the request is replayed from the offline queue much later.
  final DateTime createdAt;

  StartResponseRequest({
    required this.surveyId,
    this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  StartResponseRequest copyWith({
    int? surveyId,
    Map<String, double>? location,
    DateTime? createdAt,
  }) {
    return StartResponseRequest(
      surveyId: surveyId ?? this.surveyId,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    if (location != null) 'location': location,
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  @override
  List<Object?> get props => [surveyId, location, createdAt];
}
```

- [ ] **Step 2: Update the existing test file to drop gender/ageGroup parameters.**

If `test/features/assignment/models/start_response_request_model_test.dart` exists from the offline-created-at feature, edit it: remove every `Gender.male` / `AgeGroup.from19To29` argument and any tests that asserted those keys in `toJson()`. Add this assertion in place:

```dart
test('toJson omits gender and age_group entirely', () {
  final req = StartResponseRequest(surveyId: 1);
  final j = req.toJson();
  expect(j.containsKey('gender'), isFalse);
  expect(j.containsKey('age_group'), isFalse);
});
```

- [ ] **Step 3: Run the test, verify PASS.**

```bash
flutter test test/features/assignment/models/start_response_request_model_test.dart
```

- [ ] **Step 4: Commit.**

```bash
git add lib/features/assignment/models/start_response_request_model.dart test/features/assignment/models/start_response_request_model_test.dart
git commit -m "feat(assignment): StartResponseRequest drops gender/ageGroup"
```

Compilation breaks here for `start_response_bloc.dart` and `survey_answering_screen.dart`. Tasks 23 and 26 fix those.

---

### Task 13: Public-link start body — drop `gender` and `age_group`

**Files:**
- Modify: `lib/features/public_links/repository/public_links_online_repository.dart`

- [ ] **Step 1: Read the file and locate the start-body builder.** It's typically around line 73 (per spec anchors).

- [ ] **Step 2: Remove the gender/age_group entries from the inline body.**

The new body shape:
```dart
final body = <String, dynamic>{
  if (location != null) 'location': location,
  'created_at': (createdAt ?? DateTime.now()).toUtc().toIso8601String(),
};
```

Update the method signature: drop `Gender? gender` and `AgeGroup? ageGroup` parameters; the only required argument other than `shortCode` is now optional `location` and optional `createdAt`.

- [ ] **Step 3: Verify it compiles.**

```bash
flutter analyze lib/features/public_links/
```
Expected: errors at `public_link_answering_bloc.dart` and `public_link_answering_page.dart` (still pass gender/age). That's expected — Tasks 24 and 27 fix those.

- [ ] **Step 4: Commit.**

```bash
git add lib/features/public_links/repository/public_links_online_repository.dart
git commit -m "feat(public-link): start body drops gender/age_group"
```

---

## Phase C — Pure Services

### Task 14: `BindingInferer.infer(...)`

**Files:**
- Create: `test/features/assignment/services/binding_inferer_test.dart`
- Create: `lib/features/assignment/services/binding_inferer.dart`

- [ ] **Step 1: Write the failing test.**

```dart
// test/features/assignment/services/binding_inferer_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/quota_coordinate.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/researcher_quota_model.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/services/binding_inferer.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/assignment_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/survey_model.dart';
import '../../../helpers/quota_test_factories.dart';

void main() {
  group('BindingInferer.infer', () {
    test('infers binding when one question has a superset of category values', () {
      final survey = makeSurveyWithSingleQuestion(
        questionId: 9,
        optionValues: const ['male', 'female'],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 12, value: 'female'),
      ]);

      final bindings = BindingInferer.infer(survey: survey, assignment: assignment);

      expect(bindings.length, 1);
      expect(bindings.first.sourceQuestionId, 9);
      expect(bindings.first.scopeCriterionId, 3);
    });

    test('strict superset still matches (extra option value is fine)', () {
      final survey = makeSurveyWithSingleQuestion(
        questionId: 9,
        optionValues: const ['male', 'female', 'other'],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 12, value: 'female'),
      ]);

      final bindings = BindingInferer.infer(survey: survey, assignment: assignment);
      expect(bindings.length, 1);
    });

    test('no candidate question with superset → no binding for that criterion', () {
      final survey = makeSurveyWithSingleQuestion(
        questionId: 9,
        optionValues: const ['yes', 'no'],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
      ]);

      final bindings = BindingInferer.infer(survey: survey, assignment: assignment);
      expect(bindings, isEmpty);
    });

    test('two candidate questions match → ambiguous, no binding', () {
      final survey = makeSurveyWithTwoQuestions(
        ids: const [9, 10],
        optionValuesEach: const ['male', 'female'],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 12, value: 'female'),
      ]);

      final bindings = BindingInferer.infer(survey: survey, assignment: assignment);
      expect(bindings, isEmpty);
    });

    test('multi-criterion (Region + Gender + Age) → three bindings', () {
      final survey = makeSurveyWithThreeQuestions(
        regionQuestionId: 1,
        regionOptions: const ['baha', 'jouf', 'riyadh'],
        genderQuestionId: 2,
        genderOptions: const ['male', 'female'],
        ageQuestionId: 3,
        ageOptions: const ['18-29', '30-39'],
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 1, criterionName: 'Region', categoryId: 100, value: 'baha'),
        coord(scopeCriterionId: 1, criterionName: 'Region', categoryId: 101, value: 'jouf'),
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
        coord(scopeCriterionId: 4, criterionName: 'Age Group', categoryId: 14, value: '18-29'),
      ]);

      final bindings = BindingInferer.infer(survey: survey, assignment: assignment);
      final byCriterion = {for (final b in bindings) b.scopeCriterionId: b.sourceQuestionId};
      expect(byCriterion[1], 1);
      expect(byCriterion[3], 2);
      expect(byCriterion[4], 3);
    });

    test('questions with no options are ignored', () {
      final survey = makeSurveyWithSingleQuestion(
        questionId: 9,
        optionValues: const [], // open-text / NUMBER
      );
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
      ]);

      expect(BindingInferer.infer(survey: survey, assignment: assignment), isEmpty);
    });

    test('empty researcherQuotas → empty bindings', () {
      final survey = makeSurveyWithSingleQuestion(questionId: 9, optionValues: const ['male']);
      final assignment = makeAssignmentWithCoordinates(const []);
      expect(BindingInferer.infer(survey: survey, assignment: assignment), isEmpty);
    });

    test('output is deterministic', () {
      final survey = makeSurveyWithSingleQuestion(questionId: 9, optionValues: const ['male', 'female']);
      final assignment = makeAssignmentWithCoordinates([
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
        coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 12, value: 'female'),
      ]);
      final a = BindingInferer.infer(survey: survey, assignment: assignment);
      final b = BindingInferer.infer(survey: survey, assignment: assignment);
      expect(a, b);
    });
  });
}
```

- [ ] **Step 2: Add the test factory helper.** Create `test/helpers/quota_test_factories.dart`:

```dart
// test/helpers/quota_test_factories.dart
import 'package:king_abdulaziz_center_survey_app/core/models/survey/assignment_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/quota_coordinate.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/researcher_quota_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/survey_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/section_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_option_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';

QuotaCoordinate coord({
  required int scopeCriterionId,
  required String criterionName,
  required int categoryId,
  required String value,
  String? label,
  int order = 0,
}) {
  return QuotaCoordinate(
    scopeCriterionId: scopeCriterionId,
    criterionName: criterionName,
    scopeCriterionCategoryId: categoryId,
    categoryLabel: label ?? value,
    categoryValue: value,
    order: order,
  );
}

Question makeQuestion(int id, List<String> optionValues) {
  return Question(
    id: id,
    sectionId: 1,
    questionType: QuestionType.singleChoice,
    title: 'q$id',
    order: id,
    questionOptions: [
      for (var i = 0; i < optionValues.length; i++)
        QuestionOption(
          id: id * 100 + i,
          questionId: id,
          value: optionValues[i],
          label: optionValues[i],
          order: i,
        ),
    ],
  );
}

Survey makeSurveyWithSingleQuestion({
  required int questionId,
  required List<String> optionValues,
}) {
  return Survey(
    id: 1,
    title: 'S',
    description: 'D',
    status: SurveyStatus.published,
    sections: [
      Section(
        id: 1,
        surveyId: 1,
        title: 's',
        order: 1,
        questions: [makeQuestion(questionId, optionValues)],
      ),
    ],
    assignments: const [],
  );
}

Survey makeSurveyWithTwoQuestions({
  required List<int> ids,
  required List<String> optionValuesEach,
}) {
  return Survey(
    id: 1,
    title: 'S',
    description: 'D',
    status: SurveyStatus.published,
    sections: [
      Section(
        id: 1,
        surveyId: 1,
        title: 's',
        order: 1,
        questions: ids.map((id) => makeQuestion(id, optionValuesEach)).toList(),
      ),
    ],
    assignments: const [],
  );
}

Survey makeSurveyWithThreeQuestions({
  required int regionQuestionId,
  required List<String> regionOptions,
  required int genderQuestionId,
  required List<String> genderOptions,
  required int ageQuestionId,
  required List<String> ageOptions,
}) {
  return Survey(
    id: 1,
    title: 'S',
    description: 'D',
    status: SurveyStatus.published,
    sections: [
      Section(
        id: 1,
        surveyId: 1,
        title: 's',
        order: 1,
        questions: [
          makeQuestion(regionQuestionId, regionOptions),
          makeQuestion(genderQuestionId, genderOptions),
          makeQuestion(ageQuestionId, ageOptions),
        ],
      ),
    ],
    assignments: const [],
  );
}

Assignment makeAssignmentWithCoordinates(List<QuotaCoordinate> coords) {
  // Group coords into per-target buckets keyed by their (criterion, category) tuple
  // For the inferer's purposes, every coord can go into one quota.
  final quota = ResearcherQuota(
    id: 1,
    quotaId: 1,
    assignmentId: 1,
    target: 10,
    quotaTargetId: 100,
    coordinates: coords,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  return Assignment(
    id: 1,
    surveyId: 1,
    researcherQuotas: [quota],
  );
}
```

Note: adapt the imports + named parameters above to match the actual constructor signatures of `Survey`, `Section`, `Question`, `QuestionOption`, `Assignment` in the codebase (they may have additional required fields). The test helper exists to keep test files concise.

- [ ] **Step 3: Run, verify FAIL.**

```bash
flutter test test/features/assignment/services/binding_inferer_test.dart
```
Expected: file `binding_inferer.dart` doesn't exist.

- [ ] **Step 4: Implement.**

```dart
// lib/features/assignment/services/binding_inferer.dart
import 'package:king_abdulaziz_center_survey_app/core/models/survey/assignment_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/scope_criterion_binding.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/survey_model.dart';

/// Pure-function service that reconstructs (question_id → scope_criterion_id)
/// bindings from the survey's questions + the researcher's quota coordinates.
///
/// Inference rule: a question with `question_options` whose `value` set is a
/// **superset** of a criterion's category-value set (taken from the
/// researcher's quotas) is the unique candidate for that criterion. If 0 or
/// >1 questions match a criterion, no binding is emitted for it; the matcher
/// will then return `null` for any response that needs that criterion, and
/// the server will reconcile on refetch.
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

    // 2. Candidate questions: every question that has at least one option.
    final candidates = <_QCandidate>[];
    for (final section in survey.sections ?? const []) {
      for (final q in section.questions ?? const []) {
        final values = (q.questionOptions ?? const [])
            .map((o) => o.value)
            .where((v) => v != null && v.isNotEmpty)
            .cast<String>()
            .toSet();
        if (values.isEmpty) continue;
        candidates.add(_QCandidate(questionId: q.id, optionValues: values));
      }
    }

    // 3. For each criterion, find candidates whose option set is a superset.
    final out = <ScopeCriterionBinding>[];
    final sortedCriteria = criterionToValues.keys.toList()..sort();
    for (final cid in sortedCriteria) {
      final values = criterionToValues[cid]!;
      final matches =
          candidates.where((c) => values.every(c.optionValues.contains)).toList();
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
```

- [ ] **Step 5: Run, verify PASS.**

```bash
flutter test test/features/assignment/services/binding_inferer_test.dart
```
Expected: 8 tests green.

- [ ] **Step 6: Commit.**

```bash
git add lib/features/assignment/services/binding_inferer.dart test/features/assignment/services/binding_inferer_test.dart test/helpers/quota_test_factories.dart
git commit -m "feat(quota): BindingInferer reconstructs question→criterion mapping on-device"
```

---

### Task 15: `QuotaMatcher.match(...)`

**Files:**
- Create: `test/features/assignment/services/quota_matcher_test.dart`
- Create: `lib/features/assignment/services/quota_matcher.dart`

- [ ] **Step 1: Write the failing test.**

```dart
// test/features/assignment/services/quota_matcher_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/assignment_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/researcher_quota_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/scope_criterion_binding.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/survey_model.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/services/quota_matcher.dart';
import '../../../helpers/quota_test_factories.dart';

void main() {
  // A reusable scenario: 2 quota targets sharing a sampling scope:
  //   target 100: Gender=male, Age=18-29
  //   target 200: Gender=female, Age=18-29
  Assignment makeTwoTargets() => Assignment(
    id: 1,
    surveyId: 1,
    researcherQuotas: [
      ResearcherQuota(
        id: 1,
        quotaId: 1,
        assignmentId: 1,
        quotaTargetId: 100,
        target: 10,
        coordinates: [
          coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male'),
          coord(scopeCriterionId: 4, criterionName: 'Age', categoryId: 14, value: '18-29'),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ResearcherQuota(
        id: 2,
        quotaId: 2,
        assignmentId: 1,
        quotaTargetId: 200,
        target: 10,
        coordinates: [
          coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 12, value: 'female'),
          coord(scopeCriterionId: 4, criterionName: 'Age', categoryId: 14, value: '18-29'),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
  );

  Survey makeSurvey({SurveyStatus status = SurveyStatus.published, List<ScopeCriterionBinding> bindings = const []}) =>
    Survey(
      id: 1, title: 'S', description: 'D', status: status,
      sections: const [], assignments: const [],
      bindings: bindings,
    );

  group('QuotaMatcher.match', () {
    test('single-binding match', () {
      final survey = makeSurvey(bindings: [
        ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3),
      ]);
      final asgn = Assignment(
        id: 1, surveyId: 1,
        researcherQuotas: [
          ResearcherQuota(
            id: 1, quotaId: 1, assignmentId: 1,
            quotaTargetId: 100, target: 10,
            coordinates: [coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male')],
            createdAt: DateTime.now(), updatedAt: DateTime.now(),
          ),
        ],
      );
      expect(QuotaMatcher.match(survey: survey, assignment: asgn, answers: {2: 'male'}), 100);
    });

    test('multi-binding match resolves to unique target', () {
      final survey = makeSurvey(bindings: [
        ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3),
        ScopeCriterionBinding(sourceQuestionId: 3, scopeCriterionId: 4),
      ]);
      final asgn = makeTwoTargets();
      expect(QuotaMatcher.match(survey: survey, assignment: asgn, answers: {2: 'male', 3: '18-29'}), 100);
      expect(QuotaMatcher.match(survey: survey, assignment: asgn, answers: {2: 'female', 3: '18-29'}), 200);
    });

    test('TEST_MODE survey → null', () {
      final survey = makeSurvey(
        status: SurveyStatus.testMode,
        bindings: [ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3)],
      );
      final asgn = makeTwoTargets();
      expect(QuotaMatcher.match(survey: survey, assignment: asgn, answers: {2: 'male'}), isNull);
    });

    test('empty bindings → null', () {
      final survey = makeSurvey();
      expect(QuotaMatcher.match(survey: survey, assignment: makeTwoTargets(), answers: {}), isNull);
    });

    test('missing answer for a bound question → null', () {
      final survey = makeSurvey(bindings: [
        ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3),
      ]);
      expect(QuotaMatcher.match(survey: survey, assignment: makeTwoTargets(), answers: {}), isNull);
    });

    test('answer that matches no category → null', () {
      final survey = makeSurvey(bindings: [
        ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3),
      ]);
      expect(QuotaMatcher.match(survey: survey, assignment: makeTwoTargets(), answers: {2: 'other'}), isNull);
    });

    test('coordinate-count mismatch (target needs more pairs than resolved) → null', () {
      // Bindings only resolve Gender; targets have 2 coordinates each → no exact match.
      final survey = makeSurvey(bindings: [
        ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3),
      ]);
      expect(QuotaMatcher.match(survey: survey, assignment: makeTwoTargets(), answers: {2: 'male'}), isNull);
    });

    test('two targets share the resolved coordinate set → null', () {
      // Construct duplicate target with identical coordinates.
      final dup = ResearcherQuota(
        id: 99, quotaId: 99, assignmentId: 1,
        quotaTargetId: 999, target: 10,
        coordinates: [coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male')],
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
      final asgn = Assignment(
        id: 1, surveyId: 1,
        researcherQuotas: [
          ResearcherQuota(
            id: 1, quotaId: 1, assignmentId: 1, quotaTargetId: 100, target: 10,
            coordinates: [coord(scopeCriterionId: 3, criterionName: 'Gender', categoryId: 11, value: 'male')],
            createdAt: DateTime.now(), updatedAt: DateTime.now(),
          ),
          dup,
        ],
      );
      final survey = makeSurvey(bindings: [
        ScopeCriterionBinding(sourceQuestionId: 2, scopeCriterionId: 3),
      ]);
      expect(QuotaMatcher.match(survey: survey, assignment: asgn, answers: {2: 'male'}), isNull);
    });
  });
}
```

- [ ] **Step 2: Run, verify FAIL.**

```bash
flutter test test/features/assignment/services/quota_matcher_test.dart
```

- [ ] **Step 3: Implement.**

```dart
// lib/features/assignment/services/quota_matcher.dart
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/assignment_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/quota_coordinate.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/researcher_quota_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/survey_model.dart';

/// Pure-function service that mirrors the backend `resolveQuotaTarget`
/// algorithm. Returns the unique `quota_target_id` when the response's answers
/// resolve cleanly to exactly one target in the researcher's assigned quotas;
/// otherwise returns `null`.
///
/// The matcher is ENUM-only (matches by `categoryValue == answer`).
/// NUMBER/DATE criteria fall through to `null` and reconcile from the server
/// at FINAL_SUBMIT.
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
    final resolved = <int, int>{}; // scopeCriterionId → categoryId
    for (final b in bindings) {
      final answer = answers[b.sourceQuestionId];
      if (answer == null || answer.isEmpty) return null;

      QuotaCoordinate? hit;
      for (final q in quotas) {
        for (final c in q.coordinates) {
          if (c.scopeCriterionId != b.scopeCriterionId) continue;
          if (c.categoryValue == answer) {
            if (hit != null && hit.scopeCriterionCategoryId != c.scopeCriterionCategoryId) {
              return null; // ambiguous within criterion (shouldn't happen if data is sound)
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
        if (resolved[c.scopeCriterionId] != c.scopeCriterionCategoryId) return false;
      }
      return true;
    }).toList();

    if (candidates.length != 1) return null;
    return candidates.first.quotaTargetId;
  }
}
```

- [ ] **Step 4: Run, verify PASS.**

```bash
flutter test test/features/assignment/services/quota_matcher_test.dart
```

- [ ] **Step 5: Commit.**

```bash
git add lib/features/assignment/services/quota_matcher.dart test/features/assignment/services/quota_matcher_test.dart
git commit -m "feat(quota): QuotaMatcher mirrors backend resolveQuotaTarget logic on-device"
```

---

## Phase D — Repository Wiring

### Task 16: Repo runs `BindingInferer` in `listAssignments`

**Files:**
- Modify: `lib/features/assignment/repository/assignment_repository.dart`

- [ ] **Step 1: Open the file and locate `listAssignments`** (around line 19-29).

- [ ] **Step 2: After parsing the API response into `Survey`s and before caching, run the inferer per survey.** Replace the existing return path with:

```dart
import '../services/binding_inferer.dart';
// ... existing imports

static Future<ListAssignmentsResponse> listAssignments() async {
  final request = APIRequest(
    path: '/researcher/assignment/',
    method: HTTPMethod.get,
  );
  final response = await request.send();
  final parsed = ListAssignmentsResponse.fromJson(
    response.data as Map<String, dynamic>,
  );
  // Attach inferred bindings before persisting.
  final enriched = parsed.copyWith(
    surveys: parsed.surveys.map(_attachInferredBindings).toList(),
  );
  return enriched;
}

static Survey _attachInferredBindings(Survey survey) {
  final assignment = survey.assignments.isNotEmpty ? survey.assignments.first : null;
  if (assignment == null) return survey;
  final bindings = BindingInferer.infer(survey: survey, assignment: assignment);
  return survey.copyWith(bindings: bindings);
}
```

(If `ListAssignmentsResponse` doesn't have a `copyWith` or a `surveys` field, adapt: replace `surveys` in whatever container holds them.)

- [ ] **Step 3: Verify it compiles.**

```bash
flutter analyze lib/features/assignment/repository/assignment_repository.dart
```
Expected: `No issues found!`.

- [ ] **Step 4: Commit.**

```bash
git add lib/features/assignment/repository/assignment_repository.dart
git commit -m "feat(repo): infer bindings on listAssignments before caching"
```

---

### Task 17: Repo runs `BindingInferer` in `getSurveyDetails`

**Files:**
- Modify: `lib/features/assignment/repository/assignment_repository.dart`

- [ ] **Step 1: Locate `getSurveyDetails`** (around lines 31-43).

- [ ] **Step 2: Add the inferer call after parsing.**

```dart
static Future<GetSurveyAssignmentResponse> getSurveyDetails(int surveyId) async {
  final request = APIRequest(
    path: '/researcher/assignment/survey/$surveyId',
    method: HTTPMethod.get,
  );
  final response = await request.send();
  final parsed = GetSurveyAssignmentResponse.fromJson(
    response.data as Map<String, dynamic>,
  );
  final enriched = parsed.copyWith(
    survey: _attachInferredBindings(parsed.survey),
  );
  return enriched;
}
```

- [ ] **Step 3: Verify it compiles.**

```bash
flutter analyze lib/features/assignment/repository/assignment_repository.dart
```

- [ ] **Step 4: Commit.**

```bash
git add lib/features/assignment/repository/assignment_repository.dart
git commit -m "feat(repo): infer bindings on getSurveyDetails before caching"
```

---

### Task 18: Repo runs `QuotaMatcher` on online final submit

**Files:**
- Create: `test/features/assignment/repository/assignment_repository_quota_test.dart`
- Modify: `lib/features/assignment/repository/assignment_repository.dart`

- [ ] **Step 1: Write the failing test.**

```dart
// test/features/assignment/repository/assignment_repository_quota_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/scope_criterion_binding.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/services/quota_matcher.dart';
// ... import repository, mocks, etc.

void main() {
  group('saveSectionAnswers final submit', () {
    test('runs QuotaMatcher when isComplete=true and writes quotaTargetId', () async {
      // Arrange: a survey with a single binding, an assignment with one quota
      // matching answer 'male', a Response with quotaTargetId=null, an answers
      // map {qid: 'male'}. Stub the network response to set isComplete=true.
      // Act: call saveSectionAnswers.
      // Assert:
      //   - localRepo.updateResponse called with response.quotaTargetId == 100
      //   - localRepo.updateSurvey called with the quota's progress incremented by 1
    });

    test('matcher returns null → response.quotaTargetId stays null + no increment', () async {
      // Arrange: bindings present but answer does not match any category.
      // Assert: response.quotaTargetId == null after; quota.progress unchanged.
    });

    test('TEST_MODE survey → no local increment even if matcher would resolve', () async {
      // survey.status = TEST_MODE; matcher returns null per spec.
      // Assert: no quota increment.
    });

    test('Response.quotaTargetId already non-null → matcher not invoked', () async {
      // Pre-set response.quotaTargetId = 100 before save. After save, no extra call.
    });

    test('successful online final submit triggers refetch via getSurveyDetails', () async {
      // Stub getSurveyDetails to return new state. Assert it was called once
      // with the expected surveyId after a successful save.
    });
  });
}
```

(Fill in real mocks using `mocktail` once the surrounding repo + DI structure are clear; the assertions above are what the implementation must satisfy.)

- [ ] **Step 2: Run, verify FAIL.**

```bash
flutter test test/features/assignment/repository/assignment_repository_quota_test.dart
```

- [ ] **Step 3: In `lib/features/assignment/repository/assignment_repository.dart`, modify `saveSectionAnswers`** (around lines 247-307).

After the API call returns and `result.isComplete` is checked, before the existing `_incrementLocalQuotaForCompletedResponse(...)` call, insert the matcher:

```dart
import '../services/quota_matcher.dart';
// ... existing imports

if (result.isComplete) {
  final response = await _localRepo.getResponse(responseId);
  if (response.quotaTargetId == null) {
    final survey = await _localRepo.getSurvey(response.surveyId);
    final assignment = survey.assignments.firstOrNull;
    if (assignment != null) {
      final answers = await _localRepo.getCollectedAnswers(responseId);
      final matched = QuotaMatcher.match(
        survey: survey,
        assignment: assignment,
        answers: answers,
      );
      if (matched != null) {
        await _localRepo.updateResponse(
          response.copyWith(quotaTargetId: matched),
        );
      }
    }
  }
  _incrementLocalQuotaForCompletedResponse(responseId);
  // Trigger refetch in the background; do not await — we don't want to block
  // the UI on an extra round trip.
  unawaited(refreshSurvey(response.surveyId));
}
```

Add the helper:

```dart
static Future<void> refreshSurvey(int surveyId) async {
  try {
    final fresh = await getSurveyDetails(surveyId);
    await _localRepo.updateSurvey(fresh.survey);
  } catch (_) {
    // Silent: a failed refetch is not user-visible. Next foreground will retry.
  }
}
```

(If `_localRepo.getCollectedAnswers(int)` doesn't exist, add it: it returns the `Map<int, String>` of `questionId → answer.value` for that response. The data is already in Hive; this is a thin accessor.)

- [ ] **Step 4: Run, verify PASS.**

```bash
flutter test test/features/assignment/repository/assignment_repository_quota_test.dart
```

- [ ] **Step 5: Commit.**

```bash
git add lib/features/assignment/repository/assignment_repository.dart test/features/assignment/repository/assignment_repository_quota_test.dart
git commit -m "feat(repo): run QuotaMatcher on online final submit + refetch"
```

---

### Task 19: Repo runs `QuotaMatcher` on offline submit (`enqueueSaveSectionAnswers`)

**Files:**
- Modify: `lib/features/assignment/repository/assignment_repository.dart`
- Modify: `test/features/assignment/repository/assignment_repository_quota_test.dart`

- [ ] **Step 1: Add a test case for the offline path.**

```dart
test('enqueueSaveSectionAnswers runs matcher locally and increments optimistically', () async {
  // Arrange: connectivity offline; bindings + answers resolve to quotaTargetId=100.
  // Act: call enqueueSaveSectionAnswers with a request whose isComplete=true.
  // Assert:
  //   - response.quotaTargetId == 100 after enqueue
  //   - local quota.progress incremented by 1
  //   - queue contains the section request (still waiting to send)
});
```

- [ ] **Step 2: Run, verify FAIL.**

```bash
flutter test test/features/assignment/repository/assignment_repository_quota_test.dart
```

- [ ] **Step 3: In `enqueueSaveSectionAnswers` (around lines 311-365)** add the same matcher block right before `await _queue.add(...)` when `request.isComplete` is true:

```dart
if (request.isComplete) {
  final response = await _localRepo.getResponse(request.responseId);
  if (response.quotaTargetId == null) {
    final survey = await _localRepo.getSurvey(response.surveyId);
    final assignment = survey.assignments.firstOrNull;
    if (assignment != null) {
      final answers = await _localRepo.getCollectedAnswers(request.responseId);
      final matched = QuotaMatcher.match(
        survey: survey,
        assignment: assignment,
        answers: answers,
      );
      if (matched != null) {
        await _localRepo.updateResponse(
          response.copyWith(quotaTargetId: matched),
        );
      }
    }
  }
  _incrementLocalQuotaForCompletedResponse(request.responseId);
}
// existing enqueue call follows unchanged
```

- [ ] **Step 4: Run, verify PASS.**

```bash
flutter test test/features/assignment/repository/assignment_repository_quota_test.dart
```

- [ ] **Step 5: Commit.**

```bash
git add lib/features/assignment/repository/assignment_repository.dart test/features/assignment/repository/assignment_repository_quota_test.dart
git commit -m "feat(repo): run QuotaMatcher when enqueueing offline final submit"
```

---

### Task 20: Rewrite `_incrementLocalQuotaForCompletedResponse` to key off `quotaTargetId`

**Files:**
- Modify: `lib/features/assignment/repository/assignment_repository.dart`

- [ ] **Step 1: Locate the method (around lines 124-186).**

- [ ] **Step 2: Replace its body.**

```dart
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
// ... existing imports

void _incrementLocalQuotaForCompletedResponse(int responseId) async {
  final response = await _localRepo.getResponse(responseId);
  if (response == null) return;
  if (response.quotaTargetId == null) return;

  final survey = await _localRepo.getSurvey(response.surveyId);
  if (survey == null) return;
  if (survey.status == SurveyStatus.testMode) return;

  final assignment = survey.assignments.firstOrNull;
  if (assignment == null) return;

  final quotas = assignment.researcherQuotas ?? const [];
  final idx = quotas.indexWhere((q) => q.quotaTargetId == response.quotaTargetId);
  if (idx < 0) return;

  final updated = quotas[idx].copyWith(
    progress: quotas[idx].progress + 1,
    collected: quotas[idx].collected + 1,
    responsesCountInCategory: (quotas[idx].responsesCountInCategory ?? 0) + 1,
    serverRemaining: quotas[idx].serverRemaining != null
        ? (quotas[idx].serverRemaining! - 1).clamp(0, 1 << 30)
        : null,
  );
  final newQuotas = [...quotas];
  newQuotas[idx] = updated;
  final newAssignment = assignment.copyWith(researcherQuotas: newQuotas);
  final newSurvey = survey.copyWith(
    assignments: [
      newAssignment,
      ...survey.assignments.skip(1),
    ],
  );
  await _localRepo.updateSurvey(newSurvey);
  // Mirror the bump into the profile cache so other screens see it.
  await _profileLocalRepo.incrementQuotaByTargetId(
    response.quotaTargetId!,
  );
}
```

(`incrementQuotaByTargetId` is a thin helper on `ProfileLocalRepository` that bumps the matching `ResearcherQuotaModel` by 1. If it doesn't exist, add it analogously to the survey-side update.)

- [ ] **Step 3: Verify compilation.**

```bash
flutter analyze lib/features/assignment/repository/assignment_repository.dart
```

- [ ] **Step 4: Commit.**

```bash
git add lib/features/assignment/repository/assignment_repository.dart lib/features/profile/repository/profile_local_repository.dart
git commit -m "refactor(repo): increment local quota by quotaTargetId instead of gender/ageGroup"
```

---

### Task 21: Add `refreshAllAssignments()` + queue-drain hook

**Files:**
- Modify: `lib/features/assignment/repository/assignment_repository.dart`
- Modify: queue-drain caller (typically `lib/core/queue/services/request_queue_manager.dart`)

- [ ] **Step 1: Add the method to the repository.**

```dart
/// Replace all locally cached surveys with the latest server state.
/// Called after offline → online queue drain finishes.
static Future<void> refreshAllAssignments() async {
  try {
    final fresh = await listAssignments();
    await _localRepo.replaceAllSurveys(fresh.surveys);
  } catch (_) {
    // Tolerate transient failures; next foreground refresh retries.
  }
}
```

(`replaceAllSurveys` may need to be added to `AssignmentLocalRepository` — it clears the surveys cache and writes the new list atomically.)

- [ ] **Step 2: Hook it into the queue manager's drain-completion event.**

In `lib/core/queue/services/request_queue_manager.dart`, find the function that runs after the queue is drained successfully (look for an "onDrained" / "_onComplete" / final return path). Add:

```dart
import 'package:king_abdulaziz_center_survey_app/features/assignment/repository/assignment_repository.dart';
// ... existing imports

// At the point where the queue reports drain complete:
unawaited(AssignmentRepository.refreshAllAssignments());
```

- [ ] **Step 3: Verify compilation.**

```bash
flutter analyze lib/features/assignment/ lib/core/queue/
```

- [ ] **Step 4: Commit.**

```bash
git add lib/features/assignment/repository/assignment_repository.dart lib/features/assignment/repository/assignment_local_repository.dart lib/core/queue/services/request_queue_manager.dart
git commit -m "feat(sync): refetch all assignments after queue drain completes"
```

---

### Task 22: Remove all `ResponseMetadata` references in the repository

**Files:**
- Modify: `lib/features/assignment/repository/assignment_repository.dart`
- Modify: `lib/features/assignment/repository/assignment_local_repository.dart`

- [ ] **Step 1: In `assignment_repository.dart`, delete every call to `saveResponseMetadata`, `getResponseMetadata`, and any code that constructs a `ResponseMetadata` object.** The matcher-based flow has fully replaced this.

- [ ] **Step 2: In `assignment_local_repository.dart`, delete the `saveResponseMetadata`/`getResponseMetadata` methods and their Hive box accessors.** Leave the actual box-name constant for the migration to clear; the box itself is dropped in Task 33.

- [ ] **Step 3: Verify compilation.**

```bash
flutter analyze lib/features/assignment/
```
Expected: no issues except the `ResponseMetadata.dart` file itself, which Task 33 deletes.

- [ ] **Step 4: Commit.**

```bash
git add lib/features/assignment/repository/assignment_repository.dart lib/features/assignment/repository/assignment_local_repository.dart
git commit -m "refactor(repo): drop ResponseMetadata persistence; quotaTargetId is on the Response now"
```

---

## Phase E — Bloc Updates

### Task 23: `StartResponseBloc` drops demographics events/state/check

**Files:**
- Modify: `lib/features/assignment/bloc/start_response/start_response_bloc.dart`
- Modify: `lib/features/assignment/bloc/start_response/start_response_event.dart`
- Modify: `lib/features/assignment/bloc/start_response/start_response_state.dart`
- Create: `test/features/assignment/bloc/start_response_bloc_test.dart`

- [ ] **Step 1: Write the failing test.**

```dart
// test/features/assignment/bloc/start_response_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/bloc/start_response/start_response_bloc.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/bloc/start_response/start_response_event.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/bloc/start_response/start_response_state.dart';
// ... mocks

void main() {
  group('StartResponseBloc (post-demographics)', () {
    blocTest<StartResponseBloc, StartResponseState>(
      'StartSurveyResponse builds StartResponseRequest with no gender/ageGroup',
      build: () => /* with mocked repository */,
      act: (b) => b.add(StartSurveyResponse()),
      verify: (_) {
        // Capture the StartResponseRequest passed to repository.startResponse
        // and assert toJson() has no 'gender' / 'age_group'.
      },
    );

    test('there is no UpdateGender or UpdateAgeGroup event class anymore',
        () {
      // Static assertion: importing those names is a compile error.
      // No-op runtime test — compile-time check is the assertion.
      expect(true, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run, verify FAIL.**

```bash
flutter test test/features/assignment/bloc/start_response_bloc_test.dart
```

- [ ] **Step 3: Edit the events file.** In `start_response_event.dart`, **delete** the classes `UpdateGender` and `UpdateAgeGroup` and any `final Gender ...` / `AgeGroup ...` fields on other events.

- [ ] **Step 4: Edit the state file.** In `start_response_state.dart`, **delete** the `gender`, `ageGroup` fields from the state class. Also delete the `isDemographicQuotaFull` flag from the `StartResponseError` subtype.

- [ ] **Step 5: Edit the bloc file.** In `start_response_bloc.dart`:

1. Delete the `on<UpdateGender>(...)` and `on<UpdateAgeGroup>(...)` handlers.
2. In the `_onStartSurveyResponse` handler (around line 80), find the `isDemographicQuotaFull` check and the `StartResponseError(isDemographicQuotaFull: true)` emit — **delete the entire block**.
3. Construct `StartResponseRequest` without gender/ageGroup:

```dart
final request = StartResponseRequest(
  surveyId: state.surveyId,
  location: state.location,
);
```

- [ ] **Step 6: Run, verify PASS.**

```bash
flutter test test/features/assignment/bloc/start_response_bloc_test.dart
```

- [ ] **Step 7: Commit.**

```bash
git add lib/features/assignment/bloc/start_response/ test/features/assignment/bloc/start_response_bloc_test.dart
git commit -m "refactor(bloc): StartResponseBloc drops demographics events + pre-start check"
```

---

### Task 24: `PublicLinkAnsweringBloc` drops demographics from `StartAnswering`

**Files:**
- Modify: `lib/features/public_links/bloc/answering/public_link_answering_bloc.dart`
- Modify: `lib/features/public_links/bloc/answering/public_link_answering_event.dart`
- Create: `test/features/public_links/bloc/public_link_answering_bloc_test.dart`

- [ ] **Step 1: Write the failing test.**

```dart
// test/features/public_links/bloc/public_link_answering_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/public_links/bloc/answering/public_link_answering_bloc.dart';
import 'package:king_abdulaziz_center_survey_app/features/public_links/bloc/answering/public_link_answering_event.dart';
// ... mocks

void main() {
  group('PublicLinkAnsweringBloc (post-demographics)', () {
    test('StartAnswering takes only optional location', () {
      const e = StartAnswering(location: null);
      expect(e.location, isNull);
    });

    blocTest<PublicLinkAnsweringBloc, PublicLinkAnsweringState>(
      'start body excludes gender + age_group',
      build: () => /* mocked bloc */,
      act: (b) => b.add(const StartAnswering(location: null)),
      verify: (_) {
        // assert repository.startPublicLinkResponse was called with no
        // gender / age_group args
      },
    );
  });
}
```

- [ ] **Step 2: Run, verify FAIL.**

- [ ] **Step 3: Edit the event file.** In `public_link_answering_event.dart`, find `StartAnswering` and **remove** the gender/ageGroup fields from it (and any string-typed equivalents like `genderJson`/`ageGroupJson`). Final shape:

```dart
class StartAnswering extends PublicLinkAnsweringEvent {
  final Map<String, double>? location;
  const StartAnswering({this.location});
}
```

- [ ] **Step 4: Edit the bloc file.** In the `_onStartAnswering` handler (around line 64), drop the gender/ageGroup arguments to the repository call. Construct the call with only location.

- [ ] **Step 5: Run, verify PASS.**

```bash
flutter test test/features/public_links/bloc/public_link_answering_bloc_test.dart
```

- [ ] **Step 6: Commit.**

```bash
git add lib/features/public_links/bloc/answering/ test/features/public_links/bloc/public_link_answering_bloc_test.dart
git commit -m "refactor(bloc): PublicLinkAnswering drops gender/ageGroup from StartAnswering"
```

---

### Task 25: `HomeStatsBloc` replaces gender/age aggregation with breakdown

**Files:**
- Modify: `lib/features/home/bloc/home_stats/home_stats_bloc.dart`
- Modify: `lib/features/home/models/survey_stats_model.dart`
- Create: `test/features/home/bloc/home_stats_bloc_test.dart`

- [ ] **Step 1: Add the new model** at the bottom of `survey_stats_model.dart`:

```dart
class QuotaBreakdownEntry extends Equatable {
  final int? quotaTargetId;
  final String displayLabel;
  final int progress;
  final int target;
  final num progressPercent;

  const QuotaBreakdownEntry({
    required this.quotaTargetId,
    required this.displayLabel,
    required this.progress,
    required this.target,
    required this.progressPercent,
  });

  @override
  List<Object?> get props => [quotaTargetId, displayLabel, progress, target, progressPercent];
}
```

- [ ] **Step 2: Replace the demographic fields in `SurveyStatsModel`.**

Remove `final Map<String, double> genderProgress;` and `final Map<String, double> ageGroupProgress;`.

Add:
```dart
final List<QuotaBreakdownEntry> breakdown;
```

Update the constructor + props accordingly.

- [ ] **Step 3: Write the failing bloc test.**

```dart
// test/features/home/bloc/home_stats_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/home/bloc/home_stats/home_stats_bloc.dart';
// ... imports + mocks

void main() {
  group('HomeStatsBloc breakdown', () {
    test('per-survey total = sum of quota progress / target', () {
      // Arrange: 2 quotas (3/10 and 5/10).
      // Assert: stats.totalProgress == 8, stats.totalTarget == 20.
    });

    test('breakdown entries sorted descending by progressPercent', () {
      // Arrange: quota A at 20%, quota B at 80%, quota C at 50%.
      // Assert: breakdown[0].displayLabel == B's, [1] == C's, [2] == A's.
    });

    test('TEST_MODE survey contributes 0 (no breakdown rows)', () {
      // Arrange: testMode survey + 3 quotas.
      // Assert: stats.totalProgress == 0; breakdown is empty.
    });

    test('tie-break by displayLabel string when progressPercent ties', () {
      // Two quotas at exactly 50%; assert deterministic ordering.
    });
  });
}
```

- [ ] **Step 4: Run, verify FAIL.**

- [ ] **Step 5: Replace the aggregation in `home_stats_bloc.dart` (around lines 56-104).**

Remove the `genderProgress` and `ageGroupProgress` accumulators. Replace with a `breakdown` builder:

```dart
List<QuotaBreakdownEntry> _buildBreakdown(Survey survey) {
  if (survey.status == SurveyStatus.testMode) return const [];
  final assignment = survey.assignments.firstOrNull;
  if (assignment == null) return const [];

  final entries = (assignment.researcherQuotas ?? const [])
      .where((q) => q.quotaTargetId != null)
      .map((q) => QuotaBreakdownEntry(
            quotaTargetId: q.quotaTargetId,
            displayLabel: q.displayLabel,
            progress: q.progress,
            target: q.target,
            progressPercent: q.completionPercentage,
          ))
      .toList();
  entries.sort((a, b) {
    final cmp = b.progressPercent.compareTo(a.progressPercent);
    if (cmp != 0) return cmp;
    return a.displayLabel.compareTo(b.displayLabel);
  });
  return entries;
}
```

Wire it into the existing per-survey stats construction.

- [ ] **Step 6: Run, verify PASS.**

```bash
flutter test test/features/home/bloc/home_stats_bloc_test.dart
```

- [ ] **Step 7: Commit.**

```bash
git add lib/features/home/bloc/home_stats/ lib/features/home/models/survey_stats_model.dart test/features/home/bloc/home_stats_bloc_test.dart
git commit -m "refactor(home): replace gender/age aggregation with quota breakdown by display_label"
```

---

## Phase F — UI Updates

### Task 26: `SurveyAnsweringScreen` removes demographics dialog call

**Files:**
- Modify: `lib/features/assignment/presentation/screens/survey_answering_screen.dart`

- [ ] **Step 1: Open the file** and locate the `onStart` callback (around lines 125-175) — the block that shows `DemographicsDialog`, dispatches `UpdateGender`/`UpdateAgeGroup`, checks `isDemographicQuotaFull`, and shows the snackbar.

- [ ] **Step 2: Replace the entire block with the simpler flow.**

```dart
onStart: () async {
  final loc = await LocationService.getCurrentLocation();
  if (loc != null) bloc.add(UpdateLocation(loc));
  bloc.add(StartSurveyResponse());
},
```

Delete the import of `DemographicsDialog` and any unused localization strings referenced inside the deleted block.

- [ ] **Step 3: Verify it compiles.**

```bash
flutter analyze lib/features/assignment/presentation/screens/survey_answering_screen.dart
```

- [ ] **Step 4: Commit.**

```bash
git add lib/features/assignment/presentation/screens/survey_answering_screen.dart
git commit -m "feat(survey): remove demographics dialog from researcher start flow"
```

---

### Task 27: `PublicLinkAnsweringPage` removes demographics dialog call

**Files:**
- Modify: `lib/features/public_links/presentation/public_link_answering_page.dart`

- [ ] **Step 1: Locate `_bootstrap`** (around lines 96-139). The block shows `DemographicsDialog`, captures gender/ageGroup, optionally captures location, then dispatches `StartAnswering(...)`.

- [ ] **Step 2: Replace `_bootstrap` body.**

```dart
Future<void> _bootstrap() async {
  Map<String, double>? loc;
  if (widget.requireLocation) {
    loc = await LocationService.getCurrentLocation();
    if (loc == null) {
      // Show "location required" message and return.
      // (Reuse the existing "permission denied" UX path.)
      return;
    }
  }
  if (!mounted) return;
  context.read<PublicLinkAnsweringBloc>().add(StartAnswering(location: loc));
}
```

Delete `DemographicsDialog` import + any references to gender/ageGroup variables in this file.

- [ ] **Step 3: Verify it compiles.**

```bash
flutter analyze lib/features/public_links/presentation/public_link_answering_page.dart
```

- [ ] **Step 4: Commit.**

```bash
git add lib/features/public_links/presentation/public_link_answering_page.dart
git commit -m "feat(public-link): remove demographics dialog from public start flow"
```

---

### Task 28: New widget `QuotaBreakdownList`

**Files:**
- Create: `lib/features/home/presentation/widgets/quota_breakdown_list.dart`
- Create: `test/features/home/widgets/quota_breakdown_list_test.dart`

- [ ] **Step 1: Write the failing widget test.**

```dart
// test/features/home/widgets/quota_breakdown_list_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/home/models/survey_stats_model.dart';
import 'package:king_abdulaziz_center_survey_app/features/home/presentation/widgets/quota_breakdown_list.dart';

void main() {
  testWidgets('renders top-N entries with display_label + progress/target', (tester) async {
    final entries = List.generate(
      8,
      (i) => QuotaBreakdownEntry(
        quotaTargetId: i + 1,
        displayLabel: 'الكوتا $i',
        progress: i * 2,
        target: 10,
        progressPercent: i * 20,
      ),
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: QuotaBreakdownList(entries: entries, topN: 5)),
    ));
    expect(find.text('الكوتا 0'), findsOneWidget);
    expect(find.text('الكوتا 4'), findsOneWidget);
    expect(find.text('الكوتا 5'), findsNothing); // hidden until "show more"
    expect(find.text('عرض المزيد'), findsOneWidget);
  });

  testWidgets('tap "show more" reveals all entries', (tester) async {
    final entries = List.generate(
      8,
      (i) => QuotaBreakdownEntry(
        quotaTargetId: i,
        displayLabel: 'X $i',
        progress: 0,
        target: 10,
        progressPercent: 0,
      ),
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: QuotaBreakdownList(entries: entries, topN: 5)),
    ));
    await tester.tap(find.text('عرض المزيد'));
    await tester.pumpAndSettle();
    expect(find.text('X 7'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run, verify FAIL.**

- [ ] **Step 3: Implement.**

```dart
// lib/features/home/presentation/widgets/quota_breakdown_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:king_abdulaziz_center_survey_app/features/home/models/survey_stats_model.dart';

class QuotaBreakdownList extends StatefulWidget {
  final List<QuotaBreakdownEntry> entries;
  final int topN;

  const QuotaBreakdownList({super.key, required this.entries, this.topN = 5});

  @override
  State<QuotaBreakdownList> createState() => _QuotaBreakdownListState();
}

class _QuotaBreakdownListState extends State<QuotaBreakdownList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final visible = _expanded
        ? widget.entries
        : widget.entries.take(widget.topN).toList();
    final showToggle = widget.entries.length > widget.topN;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final e in visible) _Row(entry: e),
        if (showToggle)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(_expanded ? 'عرض أقل' : 'عرض المزيد'),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final QuotaBreakdownEntry entry;
  const _Row({required this.entry});

  @override
  Widget build(BuildContext context) {
    final percent = entry.progressPercent.toDouble().clamp(0, 100) / 100;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(entry.displayLabel,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percent.toDouble(),
                minHeight: 6.h,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 50.w,
            child: Text(
              '${entry.progress}/${entry.target}',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run, verify PASS.**

```bash
flutter test test/features/home/widgets/quota_breakdown_list_test.dart
```

- [ ] **Step 5: Commit.**

```bash
git add lib/features/home/presentation/widgets/quota_breakdown_list.dart test/features/home/widgets/quota_breakdown_list_test.dart
git commit -m "feat(home): QuotaBreakdownList widget with collapsible top-N + show more"
```

---

### Task 29: Integrate `QuotaBreakdownList` into `QuotaSummaryList`

**Files:**
- Modify: `lib/features/home/presentation/widgets/quota_summary_list.dart`

- [ ] **Step 1: Open the file** and locate `_buildSurveyQuotaCard` (around lines 47-126).

- [ ] **Step 2: Add a collapsible section under the existing summary row.**

After the existing total-progress bar widget, insert:

```dart
import 'quota_breakdown_list.dart';
// ... existing imports

// At the end of the card column, after the total progress bar:
ExpansionTile(
  tilePadding: EdgeInsets.zero,
  childrenPadding: EdgeInsets.symmetric(horizontal: 12.w),
  title: Text('عرض التفاصيل', style: Theme.of(context).textTheme.bodySmall),
  children: [
    QuotaBreakdownList(entries: stats.breakdown, topN: 5),
  ],
),
```

- [ ] **Step 3: Verify compilation.**

```bash
flutter analyze lib/features/home/presentation/widgets/
```

- [ ] **Step 4: Commit.**

```bash
git add lib/features/home/presentation/widgets/quota_summary_list.dart
git commit -m "feat(home): show quota breakdown under each survey card"
```

---

### Task 30: `SurveyStatsWidget` removes `DemographicCharts`

**Files:**
- Modify: `lib/features/home/presentation/widgets/survey_stats_widget.dart`

- [ ] **Step 1: Locate `DemographicCharts` use** (around lines 54-57).

- [ ] **Step 2: Delete the widget instance and any surrounding container that exists only to hold it.** Also delete the `import` for `DemographicCharts`.

- [ ] **Step 3: Verify compilation.**

```bash
flutter analyze lib/features/home/presentation/widgets/survey_stats_widget.dart
```

- [ ] **Step 4: Commit.**

```bash
git add lib/features/home/presentation/widgets/survey_stats_widget.dart
git commit -m "feat(home): drop DemographicCharts from SurveyStatsWidget"
```

---

### Task 31: `ResponseDetailsPage` shows `display_label` row

**Files:**
- Modify: response details screen (search for the screen that renders `ResponseDetails`)

- [ ] **Step 1: Locate the response details screen.** Likely in `lib/features/responses/presentation/response_details_page.dart` — confirm with:

```bash
flutter analyze lib/features/responses/presentation/
```

(or `grep -r "ResponseDetails" lib/features/responses/presentation/`)

- [ ] **Step 2: Add a row that shows the quota.**

In the build method, after the existing meta rows (e.g. status, started_at), add:

```dart
Builder(builder: (context) {
  final label = details.quotaTargetId == null
      ? 'غير محدد'
      : (details.displayLabel ?? 'غير محدد');
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(
      children: [
        Text('الكوتا: ', style: Theme.of(context).textTheme.bodyMedium),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}),
```

- [ ] **Step 3: Verify compilation.**

```bash
flutter analyze lib/features/responses/
```

- [ ] **Step 4: Commit.**

```bash
git add lib/features/responses/presentation/
git commit -m "feat(responses): show quota display_label (or 'غير محدد') in details"
```

---

## Phase G — Cleanup Deletions

### Task 32: Delete `DemographicsDialog` file

**Files:**
- Delete: `lib/features/assignment/presentation/widgets/demographics_dialog.dart`

- [ ] **Step 1: Confirm no imports remain.**

```bash
grep -r "demographics_dialog" lib/ test/
```
Expected: no matches (Tasks 26 and 27 removed the call sites).

- [ ] **Step 2: Delete the file.**

```bash
rm lib/features/assignment/presentation/widgets/demographics_dialog.dart
```

- [ ] **Step 3: Verify the project builds.**

```bash
flutter analyze
```

- [ ] **Step 4: Commit.**

```bash
git add -A
git commit -m "chore: delete obsolete DemographicsDialog"
```

---

### Task 33: Delete `ResponseMetadata` file + Hive adapter registration

**Files:**
- Delete: `lib/features/assignment/models/response_metadata.dart`
- Modify: Hive boot file (search for `ResponseMetadataAdapter`)

- [ ] **Step 1: Confirm no imports remain.**

```bash
grep -r "response_metadata\|ResponseMetadata" lib/ test/
```
Expected: matches only inside the file itself + the adapter-registration line in the boot file.

- [ ] **Step 2: Remove the adapter registration.** Find `Hive.registerAdapter(ResponseMetadataAdapter())` and delete that line. Also remove the import.

- [ ] **Step 3: Delete the model file.**

```bash
rm lib/features/assignment/models/response_metadata.dart
```

- [ ] **Step 4: Verify the project builds + tests pass.**

```bash
flutter analyze
flutter test
```

- [ ] **Step 5: Commit.**

```bash
git add -A
git commit -m "chore: delete ResponseMetadata model and Hive adapter"
```

---

### Task 34: Delete `Gender` and `AgeGroup` enums + unused l10n keys

**Files:**
- Modify: `lib/core/enums/survey_enums.dart`
- Modify: `lib/core/l10n/intl_*.arb` (or generated equivalents)
- Modify: any `.localized()` call sites that referred to these enums

- [ ] **Step 1: Confirm no remaining references in `.dart` files.**

```bash
grep -r "Gender\.\|AgeGroup\.\|Gender\?\|AgeGroup\?" lib/ test/
```
Any remaining match means an earlier task missed a call site — find and fix it before continuing.

- [ ] **Step 2: Delete the enums.** In `lib/core/enums/survey_enums.dart`, remove:

- The entire `enum Gender { ... }` block.
- The `extension GenderLocalization on Gender { ... }` block.
- The entire `enum AgeGroup { ... }` block.
- The `extension AgeGroupLocalization on AgeGroup { ... }` block.

- [ ] **Step 3: Remove l10n keys.** In `lib/core/l10n/intl_en.arb` and `lib/core/l10n/intl_ar.arb` (or whichever ARB files the project uses), delete the keys:

`gender`, `gender_male`, `gender_female`, `select_gender`, `age_group`, `age_18_29`, `age_30_39`, `age_40_49`, `age_50_59`, `age_60_plus`, `select_age_group`, `demographic_quota_full_for_category`.

- [ ] **Step 4: Regenerate l10n.**

```bash
flutter pub run intl_utils:generate
```

- [ ] **Step 5: Verify the project builds + all tests pass.**

```bash
flutter analyze
flutter test
```

- [ ] **Step 6: Commit.**

```bash
git add -A
git commit -m "chore: delete Gender/AgeGroup enums + unused l10n keys"
```

---

## Final Verification

After all tasks, run the full suite:

```bash
flutter analyze
flutter test
```

Both must be green. Then exercise the three integration scenarios from the spec manually if a device/emulator is available:

1. **Online happy path:** login → start a researcher survey → answer all sections (including bound questions) → finalize → check the quota progress bar moves +1 → pull-to-refresh and verify the count is unchanged (server agrees).
2. **Offline → online:** disable connectivity → start + answer + finalize → see quota progress moves +1 locally → re-enable connectivity → wait for queue drain → verify count is still +1 (server-truth equals local prediction).
3. **NULL match:** create a test survey where binding inference fails (e.g. two questions with identical option sets) → answer + finalize → quota progress is unchanged → after refetch, server-side match may set the count (depending on server's bindings) → final count is consistent with server.
