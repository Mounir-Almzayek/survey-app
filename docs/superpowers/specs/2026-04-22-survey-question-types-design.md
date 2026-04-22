# Survey Question Types — Design Spec

**Date:** 2026-04-22
**Scope:** Flutter researcher app (`lib/core/widgets/survey/*`, `lib/features/public_links/*`)
**Reference:** `survey-system-frontend-new/src/app/[locale]/survey/[shortCode]/` and its shared preview components

## Goal

Improve and complete the six question-type fields the Flutter survey answering flow supports today (Grid, Conditional Date/Time, Location, File Upload, Phone Number, Rating). The resulting behaviour matches the Next.js frontend that is already shipping against the same backend, so that any survey a researcher authors on the web renders and submits identically on the device.

## Non-Goals

- Schema changes on `QuestionOption` / `QuestionRow` / `QuestionValidation`.
- Backend endpoint changes.
- Offline-queue plumbing (not touched by this work).
- "Input field inside grid cell" — not supported by backend or frontend; deferred until schema work lands.

## Anchors (read these before implementing)

- Enum of question types: `lib/core/enums/survey_enums.dart` (`QuestionType`)
- Dispatcher widget: `lib/core/widgets/survey/survey_question_renderer.dart`
- Public-link answering bloc: `lib/features/public_links/bloc/answering/public_link_answering_bloc.dart`
- Backend answer serialiser: `survey-system/src/services/response.service.ts` (`serializeAnswerValue`, line ~667)
- Frontend field dispatcher: `survey-system-frontend-new/src/app/[locale]/(dashboard)/surveys/[id]/preview/components/question-input-renderer.tsx`
- Frontend public form: `survey-system-frontend-new/src/app/[locale]/survey/[shortCode]/components/public-survey-form.tsx`

---

## 1. Dependencies

Add to `pubspec.yaml` (`dependencies:`):

```yaml
flutter_map: ^7.0.2
latlong2: ^0.9.1
intl_phone_field: ^3.2.0
phone_numbers_parser: ^9.0.8
```

`geolocator`, `image_picker`, `image_cropper`, `flutter_dotenv`, `permission_handler` already present — reused.

---

## 2. Environment config

Add to `.env` (file is already in `.gitignore`, verified):

```
MAP_TILE_URL=https://tile.openstreetmap.org/{z}/{x}/{y}.png
MAP_DEFAULT_LAT=24.72169
MAP_DEFAULT_LNG=46.75702
```

Access via `dotenv.env['MAP_TILE_URL']` with sensible fallbacks in `lib/core/config/app_environment.dart` (new getters: `mapTileUrl`, `mapDefaultLatLng`). OSM tiles are free and require no key; the URL is parameterised so a paid provider (Mapbox/MapTiler) can be swapped in later by editing `.env` only.

Also update `.env.example` (if/when created) with these keys — never the real values.

---

## 3. Enum change — `QuestionType.phoneNumber`

File: `lib/core/enums/survey_enums.dart`

Add enum value `phoneNumber` mapped to backend string `PHONE_NUMBER`. Existing `fromJson`/`toJson` handle the mapping generically (uppercase snake of `name`). Backend already recognises `PHONE_NUMBER` in `question.prisma`.

---

## 4. Answer value shapes (contract)

| QuestionType | Flutter in-memory value | Sent to backend |
|---|---|---|
| `textShort`, `textLong`, `date`, `time`, `datetime`, `phoneNumber` | `String?` | plain string |
| `number`, `slider` | `num?` | stringified number |
| `rating` | `int?` (1..N) | stringified int |
| `radio`, `dropdown` | `String?` | plain string |
| `checkbox` | `List<String>` | JSON-stringified array |
| `singleSelectGrid` | `Map<String, String>` keyed by `row.value` | JSON-stringified object |
| `multiSelectGrid` | `Map<String, List<String>>` keyed by `row.value` | JSON-stringified object |
| `gps` | `{latitude: double, longitude: double}` (`Map<String, double>`) | JSON-stringified object |
| `file` | `String?` (server path returned from upload endpoint) | plain string |

Backend (`serializeAnswerValue`) already JSON-stringifies arrays/objects, and stores everything as `String` in the `answer_item.value` column — no backend work needed.

**Breaking change:** existing `SurveyGridField` uses `Map<int, List<String>>` keyed by `row.id`. That changes to `Map<String, ...>` keyed by `row.value`. `PublicLinkAnsweringBloc` stores values as `dynamic`, so only the field widget and the value’s consumers (only `SurveyValidator` today) need updating.

---

## 5. Field-level changes

### 5.1 `SurveyGridField` (rewrite)

File: `lib/core/widgets/survey/survey_grid_field.dart`

- Layout: `Scrollbar(thumbVisibility: true)` + `SingleChildScrollView(scrollDirection: Axis.horizontal)` around a `Table`-like column of fixed-width rows. Header row contains option labels; data rows begin with a sticky `row.label` column (fixed width via `context.responsive`) followed by option cells.
- Single-select: radio-button in each cell, one per row (enforced by clearing other selections for that row).
- Multi-select: checkbox in each cell, multiple per row allowed.
- Sort: `row.order ?? 0` then `option.id ?? 0`, matching frontend (`question-input-renderer.tsx` lines 351-356).
- Value keying: `row.value` (string). Empty `row.value` rows are skipped.
- Performance: wrap each data row in `RepaintBoundary` so toggling one cell does not repaint the whole grid.

### 5.2 `SurveyPhoneField` (new)

File: `lib/core/widgets/survey/survey_phone_field.dart`

- Wraps `IntlPhoneField` with `initialCountryCode: 'SA'`, flag + dial code dropdown on the leading edge.
- Auto-detect: if the user types `+966…` (or any `+<dial>`) into the number input, parse via `PhoneNumber.parsable()` and move the country-code prefix into the country selector, clearing it from the text field. Behaviour mirrors `handleCountryChange` in frontend `phone-input.tsx` lines 36-43.
- Emits the value in E.164 (`+966501234567`). Empty → `null`.
- Validation: delegated to `SurveyValidator` (see §7). Error text surfaced through existing `SurveyQuestionCard`.

### 5.3 `SurveyLocationMapPicker` (new) + `SurveyGpsField` (rewrite)

Files: `lib/core/widgets/survey/survey_location_map_picker.dart` (new), `lib/core/widgets/survey/survey_gps_field.dart` (rewrite).

- `SurveyLocationMapPicker`: reusable map widget — `FlutterMap` with `TileLayer(urlTemplate: env.mapTileUrl)`, height 280px, initial centre from `.env`, zoom 10 when no pin / 14 when pin present.
- Tap the map → place a `Marker` at the tapped `LatLng` and emit `{latitude, longitude}`.
- Button "استخدام موقعي الحالي" → `Geolocator.getCurrentPosition()` inside a `try/catch` that respects existing permission flow (see `lib/features/device_location/service/`). Shows snackbar on permission denied or timeout.
- Below the map: "lat, lng" text with 5 decimals (matches frontend line 83-85).
- `SurveyGpsField`: replaces the current placeholder; displays `SurveyLocationMapPicker` inside the `SurveyQuestionCard` envelope; stores/restores `{latitude, longitude}` object.
- Performance: wrap `Marker` child in `RepaintBoundary`; use `keepBuffer: 3` on `TileLayer` so scrolling is smooth.

### 5.4 `SurveyFileField` (rewrite — eager upload)

File: `lib/core/widgets/survey/survey_file_field.dart`

Convert to `StatefulWidget` with local state: `_isUploading`, `_errorMessage`, `_localPreviewXFile`.

Flow on image pick (via existing `CustomImagePicker`):
1. Store `XFile` in `_localPreviewXFile` and render local preview immediately.
2. Set `_isUploading = true`, overlay spinner.
3. Call injected `FileUploader` (default `UploadOnlineRepository.uploadImage`) → server returns `path`.
4. On success: `onChanged(path)` (answer value becomes the server path string) and `_isUploading = false`.
5. On failure: set `_errorMessage`, show inline retry button ("إعادة المحاولة"), keep local preview, do NOT call `onChanged`.

Mirrors frontend `handleFileUpload` in `public-survey-form.tsx` lines 122-138: upload first, store path only after success.

Uploader interface (for testability):

```dart
typedef FileUploader = Future<String> Function(XFile file);
```

### 5.5 `SurveyRatingField` (tweak)

File: `lib/core/widgets/survey/survey_rating_field.dart`

- Read `maxRating` from `question.questionValidations` (`values['max']`) when present; default 5.
- No shape change — still `int` 1..N.
- Default-option support: `SectionDefaultsResolver` already handles numeric-like defaults for `radio/dropdown` — extend it to `rating` by treating the default option's `value` as the initial `int`.

### 5.6 Conditional field triggered by "time" choice

No code change required. Uses existing `SurveyBehaviorManager.calculateBehavior` (already integrated in `AnsweringSectionView` line 39 and `PublicLinkAnsweringBloc._onSubmitCurrentSection`).

Survey authoring pattern (documented here, not implemented):

1. Author creates a radio/dropdown question Q1 with options, including one whose `value` indicates a time choice (e.g., `"scheduled"`).
2. Author creates a DATETIME question Q2 in the same section.
3. Author adds a `ConditionalLogic` with rule: `IF answer(Q1) == "scheduled" THEN SHOW Q2`.
4. Runtime behaviour: Q2 is hidden until Q1 is picked → selecting triggers re-evaluation → Q2 appears. Already works in Flutter via `SurveyQuestionRenderer`'s `isVisible` branch.

Add a note in `docs/APP_ARCHITECTURE.md` under the survey-response section so authors know the pattern.

---

## 6. Renderer wiring

File: `lib/core/widgets/survey/survey_question_renderer.dart`

Add a `case QuestionType.phoneNumber:` that returns `SurveyPhoneField`. Every other case untouched.

---

## 7. Validation

File: `lib/core/utils/survey_validator.dart`

- New method `validatePhone(String? value, {String countryCode = 'SA'})` using `PhoneNumber.parsable` from `phone_numbers_parser`. Returns localised error when invalid.
- `validateQuestion` dispatches to `validatePhone` when `question.type == phoneNumber`.
- Grid and GPS values use the existing `isValueEmpty` with small additions: Map is empty when no keys OR all values are empty strings / empty lists.

---

## 8. Bloc integration

File: `lib/features/public_links/bloc/answering/public_link_answering_bloc.dart`

Zero logical change. The bloc already:
- Stores answers as `Map<int, dynamic>` (sanitised via `SurveyValidator.sanitizeValue`).
- Passes `dynamic` to the submit endpoint which serialises via `serializeAnswerValue` on the backend.

We only need to confirm `SurveyValidator.sanitizeValue` does not flatten `Map`/list-of-doubles into strings. If it does, extend it to pass these through unchanged.

---

## 9. Defaults

File: `lib/features/public_links/utils/section_defaults_resolver.dart`

Extend to:
- `rating`: same as `radio` (single default option → `int` value).
- `singleSelectGrid` / `multiSelectGrid`: skip (frontend also does not pre-fill grids from defaults).
- `phoneNumber`: no defaults from option list.

---

## 10. Performance targets

- Grid with ≥ 10 rows × 6 options must scroll at 60fps on mid-range Android (Moto G-class).
- Map interactions: pin placement under 100ms after tap.
- File upload: spinner visible in ≤ 50ms after selection; fallback preview shown before upload completes.

Tactical measures: `RepaintBoundary` around grid rows and map marker; `keepBuffer: 3` on `TileLayer`; `image_picker`'s existing `maxWidth/maxHeight: 1024` + `imageQuality: 85` kept.

---

## 11. Testing

- Widget tests per new/rewritten field:
  - `SurveyGridField`: tapping cells produces correct `Map<String, String|List<String>>` keyed by `row.value`; toggling clears cell in multi mode.
  - `SurveyPhoneField`: typing `+966 50 123 4567` into national-number field rebinds country to SA and emits E.164.
  - `SurveyFileField`: successful upload sets answer to path; failed upload keeps preview and shows retry.
  - `SurveyLocationMapPicker`: tap emits lat/lng; current-location button emits Geolocator fixture.
- Validator tests: phone parses/rejects per country; grid/map emptiness checks.
- Bloc test: `PublicLinkAnsweringBloc` submits a section with grid + gps + file values and payload shapes unchanged end-to-end.

---

## 12. Rollout & risk

- All changes are additive or self-contained per field file. No API change.
- Breaking: grid value shape changes from `Map<int, List<String>>` to `Map<String, String | List<String>>`. Only one caller (`PublicLinkAnsweringBloc`), untyped, and no persisted local value relies on the old shape (the answering bloc rebuilds answers on section start).
- `.env` gains three keys; missing keys fall back to defaults so dev/staging/prod keep working without coordinated config changes.

---

## 13. Implementation order (for follow-up plan)

1. Add dependencies; add `.env` keys + `app_environment.dart` getters.
2. `QuestionType.phoneNumber` enum value + renderer case.
3. `SurveyGridField` rewrite + validator/empty-check update + tests.
4. `SurveyPhoneField` + validator + tests.
5. `SurveyLocationMapPicker` + `SurveyGpsField` rewrite + tests.
6. `SurveyFileField` eager-upload rewrite + tests.
7. `SurveyRatingField` maxRating-from-validation tweak + defaults resolver extension.
8. Bloc-level integration test + manual walkthrough on a staging survey that uses every type.
