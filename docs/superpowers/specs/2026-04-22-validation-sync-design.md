# Validation Sync & Live UX — Design Spec

**Date:** 2026-04-22
**Scope:** Flutter researcher app — `lib/core/validation/` (new), `lib/core/utils/survey_validator.dart`, `lib/core/widgets/survey/*`, `lib/features/public_links/bloc/answering/*`.
**Reference:** Backend validation rules live in `survey-system/prisma/seeders/validations.ts` (25 seeded rules) and dispatch in `survey-system/src/utils/validate-question-response.ts`.

## Goal

Give the Flutter answering flow a live per-field validation UX that mirrors the backend's per-rule semantics, replacing the current brittle title-substring dispatch in `SurveyValidator`. The user sees errors as they type (with hard-cap input formatters where appropriate), the submit-time gate remains authoritative, and adding a 26th backend rule does not brick the app.

## Non-Goals

- **Backend changes.** No new `code`/`slug` field on `Validation`; no new endpoints. The schema and seed stay as-is.
- **New rule authoring on the frontend.** All rule semantics come from the backend — we consume, we don't define.
- **Offline rule caching.** The backend already ships the full `Validation` object embedded in every question payload; no separate fetch of the rule catalog is needed.
- **Replacing the submit-time bloc gate.** `PublicLinkAnsweringBloc` stays the authoritative validator. Live UX is a discoverability layer on top.
- **Phone-number via the registry.** Phone is keyed off `QuestionType.phoneNumber` on the backend (`validate-question-response.ts:186`) and stays that way on the frontend.
- **Multi-error per field.** Existing UI shows one error slot; we keep that. Multi-error display is a future concern.

## Anchors (read before implementing)

- Backend rule seed (source of truth): `survey-system/prisma/seeders/validations.ts` (25 rules)
- Backend dispatch reference: `survey-system/src/utils/validate-question-response.ts:200-458`
- Backend upload endpoint: `survey-system/src/routes/upload/route.ts` (returns `path`)
- Current validator: `lib/core/utils/survey_validator.dart`
- Validation model: `lib/core/models/survey/validation_model.dart`
- `QuestionValidation`: `lib/core/models/survey/question_validation_model.dart`
- Submit gate: `lib/features/public_links/bloc/answering/public_link_answering_bloc.dart:129-237`
- Question renderer: `lib/core/widgets/survey/survey_question_renderer.dart`
- Question card (error slot): `lib/core/widgets/survey/survey_question_card.dart:145-154`
- Existing bloc tests: `test/features/public_links/public_link_answering_bloc_test.dart`

## UX decisions (locked)

- **Hybrid live UX** — input formatters block hard violations at the keyboard (max length, decimal-place cap, digits-only, no-spaces, letter whitelists); soft rules (min length, email, URL, ranges, password complexity, "no special characters") surface a debounced error text under the field.
- **Debounce 350 ms.** On-blur flushes the debounce immediately.
- **Error visibility gating** — no error shows on a pristine field; errors appear after the first user edit, or after a submit attempt (required-empty case).
- **Submit-time errors win.** When the bloc emits `errorText`, it overrides any live error.
- **Error message source** — always `validation.arContent` / `validation.enContent` from the backend. Parameterised rules (min/max/range length & value, min/max letters) interpolate the numeric parameter into the message.

## Dispatch decision (locked) — Approach B: Hybrid chain

Three-step lookup per `Validation` attached to a question:
1. **ID match** (`validation.id`) against a hard-coded registry of the 25 seeded rules.
2. **Regex fingerprint match** — normalize the backend regex (strip `{min}`/`{max}` placeholders, collapse whitespace, lowercase hex escapes), look up in a signature table derived from the seed file. Survives dev/staging reseeds that shift IDs.
3. **Raw regex fallback** — unknown-to-us rule: execute whatever regex the backend sent via a `RawRegexRule`, with placeholder substitution as today. No formatters, no parameter-aware messages, but validation still runs.

All fallbacks log once (`debugPrint`) including `validation.id` and `enTitle` so a missed rule is noticeable in dev.

---

## 1. File layout

```
lib/core/validation/
├── rule.dart                            # Rule abstract class, RuleResult
├── rule_registry.dart                   # Map<int, Rule> + validateAll() + formattersFor()
├── rule_lookup.dart                     # 3-step dispatch chain
├── regex_fingerprint.dart               # Normalized-regex → id table
├── raw_regex_rule.dart                  # Tier-3 fallback rule
├── input_formatters/
│   ├── digits_only_formatter.dart       # Latin + Arabic-Indic digits, no sign
│   ├── digits_and_sign_formatter.dart   # + leading +/-, and optional '.' for decimals
│   ├── decimal_places_formatter.dart    # Caps fractional digits at N
│   ├── char_whitelist_formatter.dart    # Regex-backed char whitelist
│   └── no_spaces_formatter.dart
├── rules/
│   ├── number_rules.dart                # ids 1, 2, 3, 4, 5
│   ├── length_rules.dart                # ids 6, 7, 8, 24
│   ├── letter_rules.dart                # ids 9, 10, 11, 12
│   ├── alphanumeric_rules.dart          # ids 13, 14, 18
│   ├── format_rules.dart                # ids 15 (email), 16 (url), 17 (no spaces)
│   ├── value_range_rules.dart           # ids 19, 20, 21
│   ├── script_rules.dart                # ids 22 (Arabic), 23 (English)
│   └── password_rules.dart              # id 25
└── live_validation_controller.dart      # Per-question debounced validator + ChangeNotifier
```

Each rules file is < 200 lines. Formatters live separately because multiple rules compose the same formatter (e.g. ids 10 and 11 both use the letter whitelist).

## 2. `Rule` and `RuleResult`

```dart
// lib/core/validation/rule.dart
import 'package:flutter/services.dart';
import '../models/survey/validation_model.dart';

class RuleResult {
  final bool isValid;
  final String? message;
  const RuleResult.valid() : isValid = true, message = null;
  const RuleResult.invalid(this.message) : isValid = false;
}

abstract class Rule {
  int get id;
  String get debugName;

  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  });

  List<TextInputFormatter> formatters(Map<String, dynamic> params) => const [];

  bool get appliesToTextInput => true;
}
```

**Shape notes:**
- `value` is a normalized `String`. Non-string question types (file, gps, grid, multi-select, date, rating) bypass the registry entirely; they keep type-specific validation in `SurveyValidator.isValueEmpty` and the bloc.
- `params` is `qv.values` from `QuestionValidation`. Rules that need `min`/`max` pull them with a small helper (see §4).
- Error messages come from `validation.arContent` / `validation.enContent` by default. Parameterised rules override to interpolate (e.g. `"الحد الأدنى 3 أحرف"`).
- Sync return type. No rule needs async.

## 3. `RuleRegistry` and dispatch chain

```dart
// lib/core/validation/rule_registry.dart
class RuleRegistry {
  static final Map<int, Rule> _byId = {
    1: NumberRule(),        2: PositiveNumberRule(),    3: IntegerRule(),
    4: DecimalNumberRule(), 5: Decimal2PlacesRule(),
    6: MinLengthRule(),     7: MaxLengthRule(),         8: LengthRangeRule(),
    9: MinLettersRule(),    10: MaxLettersRule(),
    11: LettersOnlyRule(),  12: LettersAndSpacesRule(),
    13: AlphanumericRule(), 14: AlphanumericWithSpacesRule(),
    15: EmailRule(),        16: UrlRule(),              17: NoSpacesRule(),
    18: NoSpecialCharsRule(),
    19: MinValueRule(),     20: MaxValueRule(),         21: ValueRangeRule(),
    22: ArabicOnlyRule(),   23: EnglishOnlyRule(),
    24: MinEightCharsRule(), 25: StrongPasswordRule(),
  };

  static Rule? lookup(Validation v) => RuleLookup.resolve(v, _byId);

  static List<String> validateAll({
    required Question question,
    required String normalizedValue,
    required String locale,
  }) {
    final errors = <String>[];
    for (final qv in question.questionValidations ?? const []) {
      final v = qv.validation;
      if (v == null || v.isActive == false) continue;
      final rule = lookup(v);
      if (rule == null) continue;
      final r = rule.validate(
        value: normalizedValue, params: qv.values,
        validation: v, locale: locale,
      );
      if (!r.isValid && r.message != null) errors.add(r.message!);
    }
    return errors;
  }

  static List<TextInputFormatter> formattersFor(Question q) {
    final out = <TextInputFormatter>[];
    for (final qv in q.questionValidations ?? const []) {
      final v = qv.validation;
      if (v == null || v.isActive == false) continue;
      final rule = lookup(v);
      if (rule != null && rule.appliesToTextInput) {
        out.addAll(rule.formatters(qv.values));
      }
    }
    return _dedupe(out); // collapses multiple LengthLimitingTextInputFormatter → smallest cap
  }
}
```

```dart
// lib/core/validation/rule_lookup.dart
class RuleLookup {
  static Rule? resolve(Validation v, Map<int, Rule> byId) {
    final byIdHit = byId[v.id];
    if (byIdHit != null) return byIdHit;

    final byFp = RegexFingerprint.match(v.validation, byId);
    if (byFp != null) { _log('fingerprint', v); return byFp; }

    if ((v.validation ?? '').isNotEmpty) { _log('raw-regex', v); return RawRegexRule(v); }

    _log('unhandled', v);
    return null;
  }

  static void _log(String tier, Validation v) =>
      debugPrint('[ValidationFallback] tier=$tier id=${v.id} title="${v.enTitle}"');
}
```

```dart
// lib/core/validation/regex_fingerprint.dart
class RegexFingerprint {
  static final Map<String, int> _signatureToId = _buildTable();

  static Rule? match(String? pattern, Map<int, Rule> byId) {
    if (pattern == null || pattern.isEmpty) return null;
    final id = _signatureToId[_normalize(pattern)];
    return id == null ? null : byId[id];
  }

  static String _normalize(String p) =>
      p.replaceAll(RegExp(r'\{[a-z_]+\}'), '')
       .replaceAll(RegExp(r'\s+'), '')
       .toLowerCase();

  static Map<String, int> _buildTable() => {
    _normalize(r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$'): 1,
    _normalize(r'^\+?[1-9١-٩][0-9٠-٩]*$'): 2,
    // ...23 more, hand-mirrored from prisma/seeders/validations.ts
  };
}
```

```dart
// lib/core/validation/raw_regex_rule.dart — Tier-3 fallback.
// Executes whatever regex the backend sent; keeps existing placeholder
// substitution. Reports the backend's arContent / enContent verbatim.
```

### Integration with `SurveyValidator`

`SurveyValidator.validateQuestion` becomes a thin wrapper. Public signature is preserved so the bloc and bloc tests don't change:

```dart
static List<String> validateQuestion({
  required Question question,
  required dynamic value,
  required String locale,
  bool isRequired = false,
}) {
  final valueStr = _normalizeValue(value);
  if (!isRequired && valueStr.isEmpty) return const [];

  final errors = RuleRegistry.validateAll(
    question: question, normalizedValue: valueStr, locale: locale,
  );

  if (question.type == QuestionType.phoneNumber) {
    final phoneErr = validatePhone(valueStr, locale: locale);
    if (phoneErr != null) errors.add(phoneErr);
  }
  return errors;
}
```

`isValueEmpty`, `sanitizeValue`, `validatePhone`, `_normalizeValue` are kept intact.

## 4. Parameter helpers

Shared, private to `lib/core/validation/rules/`:

```dart
int? paramInt(Map<String, dynamic> p, String k) {
  final v = p[k];
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
double? paramDouble(Map<String, dynamic> p, String k) { /* analogous */ }
```

## 5. `LiveValidationController`

```dart
// lib/core/validation/live_validation_controller.dart
class LiveValidationController extends ChangeNotifier {
  LiveValidationController({
    required this.question,
    required this.locale,
    Duration debounce = const Duration(milliseconds: 350),
  }) : _debounce = debounce;

  final Question question;
  final String locale;
  final Duration _debounce;

  Timer? _timer;
  String? _error;
  bool _dirty = false;
  bool _submitAttempted = false;

  String? get error => (_dirty || _submitAttempted) ? _error : null;

  void onChanged(dynamic value) {
    _dirty = true;
    _timer?.cancel();
    _timer = Timer(_debounce, () => _evaluate(value));
  }

  void onBlur(dynamic value) { _timer?.cancel(); _evaluate(value); }

  void markSubmitAttempted() { _submitAttempted = true; notifyListeners(); }

  void _evaluate(dynamic value) {
    final errors = SurveyValidator.validateQuestion(
      question: question, value: value, locale: locale,
      isRequired: question.isRequired,
    );
    final next = errors.isEmpty ? null : errors.first;
    if (next != _error) { _error = next; notifyListeners(); }
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
}
```

Controllers are **owned by `SurveyQuestionRenderer`'s state** in a `Map<int, LiveValidationController>` keyed by `question.id`. Created on first render of a visible question, disposed when the question leaves visibility (conditional-logic hide) or the section unmounts.

## 6. Widget integration

Additive changes only — no breaking signatures.

### `SurveyQuestionRenderer` (`lib/core/widgets/survey/survey_question_renderer.dart`)

- State holds `Map<int, LiveValidationController> _controllers`.
- For each visible text-input question type, pass `formatters: RuleRegistry.formattersFor(q)` and `validationController: _controllerFor(q)` into the field widget.
- On build, prune controllers whose questions are no longer in the visible list.
- Subscribes to a new `Stream<void>` on the bloc state (see §7) and calls `c.markSubmitAttempted()` on every controller when submit is attempted.

### `SurveyQuestionCard` (`lib/core/widgets/survey/survey_question_card.dart`)

New optional param `LiveValidationController? controller`. The error slot at lines 145-154 becomes:

```dart
ListenableBuilder(
  listenable: controller ?? const _NullListenable(),
  builder: (_, __) {
    final shown = errorText ?? controller?.error;
    if (shown == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(shown, style: redErrorStyle),
    );
  },
)
```

Submit-time `errorText` (bloc-driven) overrides the live error — the user always sees the authoritative message after pressing Next.

### Text & number fields

`lib/core/widgets/survey/survey_text_field.dart` and `survey_number_field.dart` gain two optional params:
- `List<TextInputFormatter>? inputFormatters` → passed straight to `TextFormField.inputFormatters`.
- `LiveValidationController? validationController` → wired into `onChanged` (forward to existing callback + `controller.onChanged(value)`) and wrapped in `Focus(onFocusChange: ...)` for `onBlur`.

### Widgets that do NOT change

`survey_phone_field.dart` (phone validation is type-driven), `survey_date_field.dart`, `survey_dropdown_field.dart`, `survey_radio_field.dart`, `survey_checkbox_field.dart`, `survey_grid_field.dart`, `survey_gps_field.dart`, `survey_slider_field.dart`, `survey_rating_field.dart`, `survey_file_field.dart`. They have no keyboard-bound validation.

## 7. Bloc coordination

One small addition to `PublicLinkAnsweringBloc`'s submit handler (`bloc/answering/public_link_answering_bloc.dart:129-237`):

- After constructing the errors map and before emitting the error state, emit a lightweight "submit attempted" signal. Implementation: a `StreamController<void>` exposed on the state (or a simple incrementing counter field on the emitted state). The renderer subscribes and calls `markSubmitAttempted()` on every live controller it owns.
- No change to the validation logic — the bloc keeps calling `SurveyValidator.isValueEmpty` + `SurveyValidator.validateQuestion`, whose behaviour is preserved by §3's wrapper.

## 8. Formatter assignments

Hard caps installed at the keyboard:

| id | Rule | Formatter(s) |
|---|---|---|
| 1  | Number                      | `DigitsAndSignFormatter(allowDecimal: true)` |
| 2  | Positive Number             | `DigitsOnlyFormatter()` (accepts ٠-٩) |
| 3  | Integer                     | `DigitsAndSignFormatter(allowDecimal: false)` |
| 4  | Decimal Number              | `DigitsAndSignFormatter(allowDecimal: true)` |
| 5  | Decimal (2 places)          | `DigitsAndSignFormatter(allowDecimal: true)` + `DecimalPlacesFormatter(2)` |
| 7  | Maximum Length              | `LengthLimitingTextInputFormatter(max)` |
| 8  | Length Range                | `LengthLimitingTextInputFormatter(max)` |
| 10 | Maximum Letters             | `LengthLimitingTextInputFormatter(max)` + letter whitelist |
| 11 | Letters Only                | `CharWhitelistFormatter(r'[؀-ٰٟ-ۿa-zA-Z]')` |
| 12 | Letters and Spaces Only     | `CharWhitelistFormatter(r'[؀-ٰٟ-ۿa-zA-Z ]')` |
| 17 | No Spaces                   | `NoSpacesFormatter()` |
| 22 | Arabic Text Only            | `CharWhitelistFormatter(arabicScriptPattern)` |
| 23 | English Text Only           | `CharWhitelistFormatter(r'[\x00-\x7F]')` |

No formatter (validation runs live, no keystroke blocking): ids 6, 9, 13, 14, 15, 16, 18, 19, 20, 21, 24, 25. Blocking characters mid-email or mid-URL is worse UX than a live error.

## 9. Testing plan

### Unit tests — `test/core/validation/rules/` (one file per family)

For each of the 25 rules, at minimum:
1. Happy-path value passes (Latin + Arabic-Indic digits where relevant).
2. Failure-path value fails, asserting message source (`arContent` / `enContent` / interpolated override).
3. Edge case: empty string, leading `+`/`-`, Arabic-Indic digits.

Parameterised rules (6, 7, 8, 9, 10, 19, 20, 21) add a 4th case: missing `params` → rule is a no-op, no crash.

### Unit tests — dispatch chain

`test/core/validation/rule_lookup_test.dart`:
- ID match wins when present.
- Fingerprint match kicks in for unknown id + known regex.
- `RawRegexRule` returned on Tier-3 fallback (executes pattern with placeholder substitution).
- `null` returned when fully unhandled; no throw.

`test/core/validation/regex_fingerprint_test.dart`:
- Every seeded regex round-trips through `_normalize` to the correct id.
- `^.{min,}$` and `^.{3,}$` collapse to the same signature.

### Unit tests — formatters

`test/core/validation/input_formatters/`:
- `DigitsOnlyFormatter`: accepts `0-9` and `٠-٩`, rejects letters/symbols.
- `DecimalPlacesFormatter(2)`: rejects a 3rd fractional digit, allows deletions, accepts ٠-٩.
- `CharWhitelistFormatter`: reject keeps previous `TextEditingValue` (no cursor jump).
- `NoSpacesFormatter`: rejects space key and pasted whitespace.

### Widget tests

`test/core/widgets/survey/survey_question_card_live_error_test.dart`:
- Pristine field with controller → no error rendered even if rule would fail.
- After `onChanged("x")` + `pump(400ms)` → error renders.
- After `markSubmitAttempted()` on empty required field → required-error renders without typing.
- `errorText` from bloc overrides live error.

`test/core/widgets/survey/survey_text_field_formatter_test.dart`:
- `enterText("abc123")` into a Letters-and-Spaces field → controller ends with `"abc"` only.

### Regression

`test/features/public_links/public_link_answering_bloc_test.dart` — **no modifications to existing tests**. Two new expectations only:
- Submitting a min-length violation: state emits `errors: {qid: <arContent msg>}` (unchanged behaviour).
- Submitting an empty required field: same (unchanged behaviour).

### Fixtures

`test/core/validation/_fixtures/seeded_validations.dart` — hand-typed `Validation` objects for all 25 seeded rules, single source of truth in the test tree. Re-sync manually if the backend seed changes.

## 10. Out-of-scope follow-ups (noted, not implemented)

- Backend: add a stable `code` / `slug` field to `Validation` and migrate dispatch to key off it. Would eliminate our fingerprint tier long-term.
- Flutter: multi-error display per field (show *all* violations, not just the first).
- Flutter: per-rule severity (warning vs error) — not modelled by backend today.
- Flutter: custom Arabic error-message interpolation uses RTL-aware templating. Today we splice raw numerals — acceptable given backend messages already do.
