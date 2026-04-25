# Offline `created_at` Timestamps Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Capture `created_at` at request-construction time on the Flutter client and ship it in the body of researcher + public-link start/section-save requests, so requests replayed from the offline queue preserve the original moment of action.

**Architecture:** Two researcher request DTOs (`StartResponseRequest`, `SaveSectionRequest`) gain a `final DateTime createdAt` field that defaults to `DateTime.now()` in the constructor. Two public-link inline body builders are extracted into `@visibleForTesting` static helpers that include `created_at`. The offline branch in `assignment_repository.dart` reuses `request.createdAt` for the dummy local `Response.startedAt` so local view and queued body agree to the millisecond.

**Tech Stack:** Flutter 3.9+, Dart 3, `equatable`, `flutter_test`.

**Spec:** [docs/superpowers/specs/2026-04-25-offline-created-at-timestamps-design.md](../specs/2026-04-25-offline-created-at-timestamps-design.md)

---

## File Structure

**Modify:**
- `lib/features/assignment/models/start_response_request_model.dart` — add `createdAt` field
- `lib/features/assignment/models/save_section_models.dart` — add `createdAt` field to `SaveSectionRequest`
- `lib/features/public_links/repository/public_links_online_repository.dart` — extract two body-builder helpers, include `created_at`
- `lib/features/assignment/repository/assignment_repository.dart` — line 103: `startedAt: request.createdAt` instead of `DateTime.now()`

**Create:**
- `test/features/assignment/models/start_response_request_model_test.dart`
- `test/features/assignment/models/save_section_models_test.dart`
- `test/features/public_links/repository/public_links_online_repository_test.dart`

---

## Task 1: `StartResponseRequest` carries `createdAt`

**Files:**
- Test: `test/features/assignment/models/start_response_request_model_test.dart` (create)
- Modify: `lib/features/assignment/models/start_response_request_model.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/models/start_response_request_model.dart';

void main() {
  group('StartResponseRequest.createdAt', () {
    test('toJson includes created_at as ISO 8601 UTC string', () {
      final t = DateTime.utc(2026, 4, 25, 14, 35, 22, 143);
      final req = StartResponseRequest(
        surveyId: 1,
        gender: Gender.male,
        ageGroup: AgeGroup.from19To29,
        createdAt: t,
      );
      final json = req.toJson();
      expect(json['created_at'], '2026-04-25T14:35:22.143Z');
    });

    test('defaults createdAt to now when omitted', () {
      final before = DateTime.now().toUtc();
      final req = StartResponseRequest(
        surveyId: 1,
        gender: Gender.male,
        ageGroup: AgeGroup.from19To29,
      );
      final after = DateTime.now().toUtc();
      final ca = req.createdAt.toUtc();
      expect(ca.isBefore(before.subtract(const Duration(milliseconds: 5))), isFalse);
      expect(ca.isAfter(after.add(const Duration(milliseconds: 5))), isFalse);
    });

    test('toJson is stable across re-invocations (timestamp frozen at construction)', () async {
      final req = StartResponseRequest(
        surveyId: 1,
        gender: Gender.male,
        ageGroup: AgeGroup.from19To29,
      );
      final first = req.toJson()['created_at'];
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final second = req.toJson()['created_at'];
      expect(first, second);
    });

    test('copyWith preserves createdAt when not overridden', () {
      final t = DateTime.utc(2026, 4, 25, 10);
      final req = StartResponseRequest(
        surveyId: 1,
        gender: Gender.male,
        ageGroup: AgeGroup.from19To29,
        createdAt: t,
      );
      final copy = req.copyWith(surveyId: 2);
      expect(copy.createdAt, t);
    });
  });
}
```

- [ ] **Step 2: Run test, verify FAIL**

```bash
flutter test test/features/assignment/models/start_response_request_model_test.dart
```

Expected: compile error or test failure — `createdAt` field doesn't exist yet.

- [ ] **Step 3: Implement**

Replace the entire file `lib/features/assignment/models/start_response_request_model.dart` with:

```dart
import 'package:equatable/equatable.dart';
import '../../../../core/enums/survey_enums.dart';

/// Model for starting a survey response request
class StartResponseRequest extends Equatable {
  final int surveyId;
  final Gender gender;
  final AgeGroup ageGroup;
  final Map<String, double>? location;

  /// Wall-clock time captured when this request DTO was built. Sent as
  /// `created_at` so the server can record the moment of user action even
  /// when the request is replayed from the offline queue much later.
  final DateTime createdAt;

  StartResponseRequest({
    required this.surveyId,
    required this.gender,
    required this.ageGroup,
    this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  StartResponseRequest copyWith({
    int? surveyId,
    Gender? gender,
    AgeGroup? ageGroup,
    Map<String, double>? location,
    DateTime? createdAt,
  }) {
    return StartResponseRequest(
      surveyId: surveyId ?? this.surveyId,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender.toJson(),
      'age_group': ageGroup.toJson(),
      if (location != null) 'location': location,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [surveyId, gender, ageGroup, location, createdAt];
}
```

- [ ] **Step 4: Run test, verify PASS**

```bash
flutter test test/features/assignment/models/start_response_request_model_test.dart
```

Expected: 4 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/assignment/models/start_response_request_model.dart test/features/assignment/models/start_response_request_model_test.dart
git commit -m "feat(assignment): StartResponseRequest carries optional created_at"
```

---

## Task 2: `SaveSectionRequest` carries `createdAt`

**Files:**
- Test: `test/features/assignment/models/save_section_models_test.dart` (create)
- Modify: `lib/features/assignment/models/save_section_models.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/models/save_section_models.dart';

void main() {
  group('SaveSectionRequest.createdAt', () {
    test('toJson includes created_at as ISO 8601 UTC string', () {
      final t = DateTime.utc(2026, 4, 25, 14, 35, 22, 143);
      final req = SaveSectionRequest(
        sectionId: 10,
        answers: const [],
        createdAt: t,
      );
      expect(req.toJson()['created_at'], '2026-04-25T14:35:22.143Z');
    });

    test('defaults createdAt to now when omitted', () {
      final before = DateTime.now().toUtc();
      final req = SaveSectionRequest(sectionId: 10, answers: const []);
      final after = DateTime.now().toUtc();
      final ca = req.createdAt.toUtc();
      expect(ca.isBefore(before.subtract(const Duration(milliseconds: 5))), isFalse);
      expect(ca.isAfter(after.add(const Duration(milliseconds: 5))), isFalse);
    });

    test('toJson is stable across re-invocations', () async {
      final req = SaveSectionRequest(sectionId: 10, answers: const []);
      final first = req.toJson()['created_at'];
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final second = req.toJson()['created_at'];
      expect(first, second);
    });

    test('copyWith preserves createdAt when not overridden', () {
      final t = DateTime.utc(2026, 4, 25, 10);
      final req = SaveSectionRequest(
        sectionId: 10,
        answers: const [],
        createdAt: t,
      );
      expect(req.copyWith(sectionId: 11).createdAt, t);
    });

    test('fromJson reads created_at if present, falls back to now otherwise', () {
      final t = DateTime.utc(2026, 4, 25, 12);
      final withTs = SaveSectionRequest.fromJson({
        'section_id': 10,
        'answers': <Map<String, dynamic>>[],
        'created_at': t.toIso8601String(),
      });
      expect(withTs.createdAt, t);

      final before = DateTime.now().toUtc();
      final without = SaveSectionRequest.fromJson({
        'section_id': 10,
        'answers': <Map<String, dynamic>>[],
      });
      final after = DateTime.now().toUtc();
      final ca = without.createdAt.toUtc();
      expect(ca.isBefore(before.subtract(const Duration(milliseconds: 5))), isFalse);
      expect(ca.isAfter(after.add(const Duration(milliseconds: 5))), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run test, verify FAIL**

```bash
flutter test test/features/assignment/models/save_section_models_test.dart
```

- [ ] **Step 3: Implement**

Replace the contents of `lib/features/assignment/models/save_section_models.dart` with:

```dart
class AnswerRequest {
  final int questionId;
  final dynamic value;

  AnswerRequest({required this.questionId, required this.value});

  Map<String, dynamic> toJson() {
    return {'question_id': questionId, 'value': value};
  }
}

class SaveSectionRequest {
  final int sectionId;
  final int? lastReachedSectionId;
  final List<AnswerRequest> answers;
  final double? latitude;
  final double? longitude;
  final bool isSynced;

  /// Wall-clock time captured when this request DTO was built. Sent as
  /// `created_at` so the server records the moment of user action even when
  /// the request is replayed from the offline queue much later.
  final DateTime createdAt;

  SaveSectionRequest({
    required this.sectionId,
    this.lastReachedSectionId,
    required this.answers,
    this.latitude,
    this.longitude,
    this.isSynced = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  SaveSectionRequest copyWith({
    int? sectionId,
    int? lastReachedSectionId,
    List<AnswerRequest>? answers,
    double? latitude,
    double? longitude,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return SaveSectionRequest(
      sectionId: sectionId ?? this.sectionId,
      lastReachedSectionId: lastReachedSectionId ?? this.lastReachedSectionId,
      answers: answers ?? this.answers,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section_id': sectionId,
      'answers': answers.map((e) => e.toJson()).toList(),
      if (latitude != null && longitude != null)
        'location': {'latitude': latitude, 'longitude': longitude},
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Convert to JSON including local-only fields (for local storage)
  Map<String, dynamic> toLocalJson() {
    return {
      ...toJson(),
      'last_reached_section_id': lastReachedSectionId,
      'is_synced': isSynced,
    };
  }

  factory SaveSectionRequest.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['created_at'];
    return SaveSectionRequest(
      sectionId: json['section_id'] as int? ?? 0,
      lastReachedSectionId: json['last_reached_section_id'] as int?,
      isSynced: json['is_synced'] as bool? ?? false,
      answers:
          (json['answers'] as List?)
              ?.map(
                (e) => AnswerRequest(
                  questionId: e['question_id'] as int,
                  value: e['value'],
                ),
              )
              .toList() ??
          [],
      latitude: json['location']?['latitude'] as double?,
      longitude: json['location']?['longitude'] as double?,
      createdAt: rawCreatedAt is String ? DateTime.parse(rawCreatedAt) : null,
    );
  }
}

class SaveSectionResponse {
  final bool success;
  final String message;
  final bool isComplete;
  final bool isQueued;

  SaveSectionResponse({
    required this.success,
    required this.message,
    required this.isComplete,
    this.isQueued = false,
  });

  factory SaveSectionResponse.fromJson(Map<String, dynamic> json) {
    return SaveSectionResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      isComplete: json['data']?['is_complete'] as bool? ?? false,
      isQueued: false,
    );
  }
}
```

- [ ] **Step 4: Run test, verify PASS**

```bash
flutter test test/features/assignment/models/save_section_models_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/assignment/models/save_section_models.dart test/features/assignment/models/save_section_models_test.dart
git commit -m "feat(assignment): SaveSectionRequest carries optional created_at"
```

---

## Task 3: Align offline dummy `Response.startedAt` with `request.createdAt`

**Files:**
- Modify: `lib/features/assignment/repository/assignment_repository.dart` line 103

This change has no isolated unit test (the static method has multiple I/O dependencies). Verified by:
- The `request.createdAt` correctness is covered by Task 1 tests.
- The 1-line change is reviewed visually and verified by the existing test suite still passing.

- [ ] **Step 1: Apply the edit**

In `lib/features/assignment/repository/assignment_repository.dart`, change line 103 from:

```dart
        startedAt: DateTime.now(),
```

to:

```dart
        startedAt: request.createdAt,
```

- [ ] **Step 2: Run the existing assignment-area tests to ensure nothing broke**

```bash
flutter test test/features/assignment/
```

Expected: all existing tests still pass.

- [ ] **Step 3: Commit**

```bash
git add lib/features/assignment/repository/assignment_repository.dart
git commit -m "fix(assignment): align offline dummy startedAt with request.createdAt"
```

---

## Task 4: Public-link body builders carry `created_at`

**Files:**
- Test: `test/features/public_links/repository/public_links_online_repository_test.dart` (create)
- Modify: `lib/features/public_links/repository/public_links_online_repository.dart`

This task extracts the inline body construction into two `@visibleForTesting` static helpers and adds `created_at` to both. Tests target the helpers directly — the `APIRequest.send()` path is left alone.

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/public_links/repository/public_links_online_repository.dart';

void main() {
  group('PublicLinksOnlineRepository.buildStartBody', () {
    test('includes gender, age_group, and created_at', () {
      final t = DateTime.utc(2026, 4, 25, 14, 35, 22, 143);
      final body = PublicLinksOnlineRepository.buildStartBody(
        gender: 'MALE',
        ageGroup: '19_29',
        createdAt: t,
      );
      expect(body['gender'], 'MALE');
      expect(body['age_group'], '19_29');
      expect(body['created_at'], '2026-04-25T14:35:22.143Z');
      expect(body.containsKey('location'), isFalse);
    });

    test('includes location when provided', () {
      final body = PublicLinksOnlineRepository.buildStartBody(
        gender: 'FEMALE',
        ageGroup: '30_39',
        location: (latitude: 24.7136, longitude: 46.6753),
        createdAt: DateTime.utc(2026, 4, 25),
      );
      expect(body['location'], {'latitude': 24.7136, 'longitude': 46.6753});
    });

    test('defaults createdAt to now when omitted', () {
      final before = DateTime.now().toUtc();
      final body = PublicLinksOnlineRepository.buildStartBody(
        gender: 'MALE',
        ageGroup: '19_29',
      );
      final after = DateTime.now().toUtc();
      final ca = DateTime.parse(body['created_at'] as String);
      expect(ca.isBefore(before.subtract(const Duration(milliseconds: 5))), isFalse);
      expect(ca.isAfter(after.add(const Duration(milliseconds: 5))), isFalse);
    });
  });

  group('PublicLinksOnlineRepository.buildSectionSubmitBody', () {
    test('includes answers and created_at', () {
      final t = DateTime.utc(2026, 4, 25, 14, 40);
      final body = PublicLinksOnlineRepository.buildSectionSubmitBody(
        answers: [
          (questionId: 1, value: 'A'),
          (questionId: 2, value: 42),
        ],
        createdAt: t,
      );
      expect(body['answers'], [
        {'question_id': 1, 'value': 'A'},
        {'question_id': 2, 'value': 42},
      ]);
      expect(body['created_at'], '2026-04-25T14:40:00.000Z');
    });

    test('defaults createdAt to now when omitted', () {
      final before = DateTime.now().toUtc();
      final body = PublicLinksOnlineRepository.buildSectionSubmitBody(
        answers: const [],
      );
      final after = DateTime.now().toUtc();
      final ca = DateTime.parse(body['created_at'] as String);
      expect(ca.isBefore(before.subtract(const Duration(milliseconds: 5))), isFalse);
      expect(ca.isAfter(after.add(const Duration(milliseconds: 5))), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run test, verify FAIL**

```bash
flutter test test/features/public_links/repository/public_links_online_repository_test.dart
```

Expected: compile error — helpers don't exist.

- [ ] **Step 3: Implement**

In `lib/features/public_links/repository/public_links_online_repository.dart`:

a) Add this import at the top (after the existing imports):

```dart
import 'package:flutter/foundation.dart' show visibleForTesting;
```

b) Replace the body of `startPublicLinkResponse` (lines 67-93) with:

```dart
  /// Start a public-link response (unauthenticated).
  /// POST /public-link/:short_code/start
  /// Returns [responseId], the [firstSection], and [conditionalLogics].
  static Future<PublicLinkStartResult> startPublicLinkResponse({
    required String shortCode,
    required String gender,
    required String ageGroup,
    ({double latitude, double longitude})? location,
  }) async {
    final body = buildStartBody(
      gender: gender,
      ageGroup: ageGroup,
      location: location,
    );

    final apiRequest = APIRequest(
      path: '/public-link/$shortCode/start',
      method: HTTPMethod.post,
      body: body,
      authorizationOption: AuthorizationOption.unauthorized,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;
    return PublicLinkStartResult.fromJson(data as Map<String, dynamic>);
  }

  /// Build the request body for the public-link start endpoint. The
  /// `created_at` field is captured at call time so a server that supports
  /// it can use the moment of user action; backends that don't yet recognise
  /// the field strip it silently (Zod default).
  @visibleForTesting
  static Map<String, dynamic> buildStartBody({
    required String gender,
    required String ageGroup,
    ({double latitude, double longitude})? location,
    DateTime? createdAt,
  }) {
    final ts = (createdAt ?? DateTime.now()).toUtc().toIso8601String();
    return <String, dynamic>{
      'gender': gender,
      'age_group': ageGroup,
      if (location != null)
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
      'created_at': ts,
    };
  }
```

c) Replace the body of `submitPublicLinkSection` (lines 98-120) with:

```dart
  /// Submit answers for one section and retrieve the next section or a
  /// completion signal (unauthenticated).
  /// POST /public-link/:short_code/responses/:response_id/sections/:section_id
  static Future<PublicLinkSectionResult> submitPublicLinkSection({
    required String shortCode,
    required int responseId,
    required int sectionId,
    required List<({int questionId, dynamic value})> answers,
  }) async {
    final body = buildSectionSubmitBody(answers: answers);

    final apiRequest = APIRequest(
      path: '/public-link/$shortCode/responses/$responseId/sections/$sectionId',
      method: HTTPMethod.post,
      body: body,
      authorizationOption: AuthorizationOption.unauthorized,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;
    return PublicLinkSectionResult.fromJson(data as Map<String, dynamic>);
  }

  /// Build the request body for the public-link section-submit endpoint.
  /// `created_at` is captured at call time. See [buildStartBody] for
  /// backend-compatibility notes.
  @visibleForTesting
  static Map<String, dynamic> buildSectionSubmitBody({
    required List<({int questionId, dynamic value})> answers,
    DateTime? createdAt,
  }) {
    final ts = (createdAt ?? DateTime.now()).toUtc().toIso8601String();
    return <String, dynamic>{
      'answers': answers
          .map((a) => {'question_id': a.questionId, 'value': a.value})
          .toList(),
      'created_at': ts,
    };
  }
```

- [ ] **Step 4: Run test, verify PASS**

```bash
flutter test test/features/public_links/repository/public_links_online_repository_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/public_links/repository/public_links_online_repository.dart test/features/public_links/repository/public_links_online_repository_test.dart
git commit -m "feat(public-link): build helpers expose start + section bodies with created_at"
```

---

## Task 5: Final verification — full test suite

- [ ] **Step 1: Run the full test suite**

```bash
flutter test
```

Expected: all pre-existing tests still pass, plus the 3 new test files.

- [ ] **Step 2: Inspect the diff visually**

```bash
git log --oneline -6
git diff HEAD~5 HEAD -- lib/
```

Confirm the 4 source files match the design and no unrelated changes leaked in.

---

## Self-review notes (already applied)

- All four endpoints (researcher start/section, public-link start/section) ship `created_at` in the body.
- The researcher DTOs default `createdAt` in their constructors so the existing call sites need no change to opt in.
- The public-link helpers default `createdAt` so the bloc layer (which doesn't know about timestamps) gets correct behaviour for free.
- The offline researcher path's local `Response.startedAt` aligns with the queued request's `created_at` to the millisecond by reading from `request.createdAt`.
- Backward-compat: `SaveSectionRequest.fromJson` tolerates missing `created_at` (defaults to now). Old persisted local drafts deserialised after this change get a fresh timestamp on hydration — acceptable since drafts that were already mid-edit are user-specific and the affected timestamp only matters on the next replay attempt.
