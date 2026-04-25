# Offline `created_at` Timestamps — Design Spec

**Date:** 2026-04-25
**Scope:** Flutter client only — `lib/features/assignment/models/`, `lib/features/public_links/repository/`. No backend changes.

## Problem

When the device is offline, survey actions (start a response, save a section's answers) are queued in `RequestQueueService` and replayed serially when connectivity returns. Each replayed request lands at the server within a tight window (the queue drains with a 500 ms gap between items), and the server stamps each row with its own `now()`. The result: a session that was actually performed across a workday — start at 14:00, section 1 at 14:05, section 2 at 14:30 — appears in the database as if it all happened within seconds, breaking chronological ordering and any downstream feature that reasons about session timing.

The fix: have the client capture the wall-clock time **at the moment the action occurs** and ship it inside the request body as an optional `created_at` field. The server, when it sees the field, uses it; otherwise it falls back to `now()` (existing default).

## Goal

Every researcher and public-link request that creates timestamped rows on the server carries a client-captured `created_at`. The capture happens once at request-construction time and rides through the offline queue unchanged, so the replayed request preserves the original moment of action.

## Non-Goals

- **Backend changes.** Backend ownership is separate. The researcher endpoints already accept `created_at` (Zod schemas at [survey-system/src/routes/researcher/assignment/route.ts:370](../../../survey-system/src/routes/researcher/assignment/route.ts) and `:697`). The public-link endpoints will gain the field on the backend side later; until they do, Zod's default strip mode silently drops the unknown key — no client breakage, no client redeploy needed once backend ships.
- **Per-answer `created_at` in the request body.** The backend already propagates the section-level `created_at` to every `AnswerItem` row in that save call (see [survey-system/src/services/response.service.ts:791-806](../../../survey-system/src/services/response.service.ts)). Sending one timestamp per section is sufficient for the chosen "captured at section save time" semantics.
- **Queue infrastructure changes.** `RequestQueueService` and `RequestQueueManager` stay untouched. The timestamp lives inside the serialized request body, which the queue already persists and replays verbatim.
- **Local model changes.** The dummy local response built in the offline path ([lib/features/assignment/repository/assignment_repository.dart:103](../../../lib/features/assignment/repository/assignment_repository.dart)) already captures `startedAt: DateTime.now()` for local UI; that stays.
- **Server-side clock-skew validation.** Whatever the client sends is what the server stores. Same trust model as the existing researcher flow.
- **Backfilling old queued items.** Requests that were queued before this change will replay without `created_at` and the server falls back to `now()` — same behavior as today.

## Anchors (read before implementing)

- Researcher start DTO: [lib/features/assignment/models/start_response_request_model.dart:34](../../../lib/features/assignment/models/start_response_request_model.dart)
- Researcher section-save DTO: [lib/features/assignment/models/save_section_models.dart:47](../../../lib/features/assignment/models/save_section_models.dart)
- Public-link start body (inline): [lib/features/public_links/repository/public_links_online_repository.dart:73](../../../lib/features/public_links/repository/public_links_online_repository.dart)
- Public-link section-save body (inline): [lib/features/public_links/repository/public_links_online_repository.dart:98](../../../lib/features/public_links/repository/public_links_online_repository.dart)
- Offline path captures local `now`: [lib/features/assignment/repository/assignment_repository.dart:103](../../../lib/features/assignment/repository/assignment_repository.dart)
- Queue (untouched, for reference): [lib/core/queue/services/request_queue_service.dart](../../../lib/core/queue/services/request_queue_service.dart), [lib/core/queue/services/request_queue_manager.dart](../../../lib/core/queue/services/request_queue_manager.dart)
- Backend (read-only reference): researcher Zod schemas at `survey-system/src/routes/researcher/assignment/route.ts:370` and `:697`; service write at `survey-system/src/services/response.service.ts:596,791-806`.

## Design decisions (locked)

### 1. Field shape

- **JSON key:** `created_at` (snake_case to match existing backend convention).
- **Format:** ISO 8601 in UTC with millisecond precision — `DateTime.now().toUtc().toIso8601String()` → e.g. `"2026-04-25T14:35:22.143Z"`.
- **Optionality on the wire:** always sent. The backend treats it as optional and falls back to `now()` when absent; we never omit it.

### 2. Capture timing

- The timestamp is captured **at the moment the request DTO is constructed**, not at the moment the network call fires.
- Rationale: the DTO is constructed at the moment of user action in both online and offline paths. In the offline path the DTO is then handed to the queue and may be replayed minutes/hours later — the captured timestamp must remain frozen across that delay and across any retries.
- Implementation: each affected DTO accepts an optional `DateTime? createdAt` constructor parameter and stores it as a final field. If `null`, the constructor defaults to `DateTime.now()`. Call sites that already capture a local `now` (e.g. the offline path that also sets the dummy response's `startedAt`) pass the same value in for perfect alignment; other call sites rely on the default.

### 3. Online vs offline behavior

- **Identical.** No conditional branch. Both paths construct the same DTO, which carries `created_at`. Online path: server-receive time ≈ client-capture time, no functional difference. Offline path: server-receive time may be hours after capture, and the captured value is what we want stored.

### 4. Backward compatibility

- **Old queued requests** (queued before this change ships): replayed without `created_at`. Backend falls back to `now()`. No errors.
- **Researcher endpoints** (backend already accepts `created_at`): start using the client-supplied value immediately on first install with the new client.
- **Public-link endpoints** (backend accepts but ignores until they update Zod schema): client always sends; Zod's default strip mode drops the unknown key silently. Once the backend developer adds `created_at: z.coerce.date().optional()` to the public-link Zod schemas, the field starts being persisted with no client redeploy. Verified that no `.strict()` is used on the public-link routes (grep run on `survey-system/src/routes/public-link/route.ts`).

## Components

### `StartResponseRequest` (researcher start)

[lib/features/assignment/models/start_response_request_model.dart:34](../../../lib/features/assignment/models/start_response_request_model.dart)

Add a final `createdAt` field, defaulted in the constructor to `DateTime.now()` when not provided. Extend `toJson()` to include `'created_at': createdAt.toUtc().toIso8601String()`. The existing `gender`, `ageGroup`, `location` fields are unchanged.

### `SaveSectionRequest` (researcher section save)

[lib/features/assignment/models/save_section_models.dart:47](../../../lib/features/assignment/models/save_section_models.dart)

Same shape as above: optional `DateTime? createdAt` constructor param, defaults to `DateTime.now()`, serialized as `'created_at'` in `toJson()`.

### Public-link start body

[lib/features/public_links/repository/public_links_online_repository.dart:73](../../../lib/features/public_links/repository/public_links_online_repository.dart)

The body is currently built inline as a `Map<String, dynamic>`. The method signature gains an optional `DateTime? createdAt` parameter that defaults to `DateTime.now()` inside the method, and the inline body adds `'created_at': createdAt.toUtc().toIso8601String()`.

### Public-link section-save body

[lib/features/public_links/repository/public_links_online_repository.dart:98](../../../lib/features/public_links/repository/public_links_online_repository.dart)

Same change as the start body — optional `DateTime? createdAt` parameter on the method, defaulted to `DateTime.now()`, serialized into the inline body map.

### Call sites

- **Online researcher path:** no code change beyond the DTO update; the DTO defaults `createdAt` to now at construction time.
- **Offline researcher path** ([lib/features/assignment/repository/assignment_repository.dart:103](../../../lib/features/assignment/repository/assignment_repository.dart) and the corresponding section-save offline branch): captures a local `now`, uses it for the dummy local response's `startedAt`, and **passes the same `now` into the queued request DTO** so the local view and the eventual server row agree to the millisecond.
- **Public-link paths (online and offline):** symmetric to the researcher paths.

## Data flow

```
User action (online or offline)
        │
        ▼
DTO constructed → createdAt = caller-supplied OR DateTime.now()
        │
        ▼
toJson() → body includes "created_at": "2026-04-25T14:35:22.143Z"
        │
        ├── Online path → APIRequest.send() → server receives, parses, stores
        │
        └── Offline path → RequestQueueService.queue(item)
                                    │
                                    ▼ (later, when online)
                            RequestQueueManager._processQueue()
                                    │
                                    ▼
                            item.request.send() → server receives, parses
                            stored body still carries the original timestamp
```

## Tests

### Unit — DTOs

- `StartResponseRequest`:
  - `toJson()` includes `'created_at'` as an ISO 8601 UTC string ending in `Z`.
  - When constructed without `createdAt`, the field is set to a value within ~5 ms of `DateTime.now()`.
  - When constructed with an explicit `DateTime`, `toJson()` echoes it (verify the parsed roundtrip equals the input).
- `SaveSectionRequest`: same three assertions.

### Unit — Public-link repository helpers

- The methods that build the public-link start and section-save bodies include `'created_at'` in the body map.
- When passed an explicit `DateTime`, the body's `'created_at'` matches it; otherwise it's within ~5 ms of `DateTime.now()`.

### Integration — offline replay preserves the timestamp

- Construct a request DTO at time `T0`.
- Serialize and store it in a fake `RequestQueueService`.
- Sleep long enough to make a difference (e.g. 50 ms).
- Pull the item back, deserialize, send it through a stub `APIRequest`, and assert the body's `'created_at'` still equals the `T0` capture (not the replay time).

### Manual smoke

- Offline mode: start a survey, answer one section, wait, restore connectivity, observe the queue drain. Verify in the backend (researcher response row) that `created_at` reflects the offline action time rather than the connectivity-restored time. (Public-link won't show the effect until the backend Zod schema is updated; that's expected.)

## Open questions

None.

## Risks

- **Device clock skew.** A user with a wrong system clock will produce wrong timestamps. Same risk already exists for the researcher flow today; we accept it.
- **Public-link backend not updated.** Until the backend dev adds `created_at` to the public-link Zod schemas, the field is silently stripped and the public-link rows continue to use `now()`. No regression vs. today; the fix simply doesn't activate for that flow yet.
