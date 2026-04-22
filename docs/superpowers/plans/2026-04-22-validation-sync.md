# Validation Sync & Live UX Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the brittle title-substring dispatch in `SurveyValidator` with a typed ID-keyed rule registry (with regex-fingerprint and raw-regex fallbacks), add debounced per-field live error display, and install input formatters for hard-cap rules — all additive, no backend changes, public `SurveyValidator.validateQuestion` signature preserved.

**Architecture:** A three-tier lookup chain (`id` → regex fingerprint → raw regex) maps each backend `Validation` to a typed `Rule` that declares its own validator and optional `TextInputFormatter`s. A per-question `LiveValidationController` (a `ChangeNotifier`) debounces keystroke validation and is owned by `SurveyQuestionRenderer`. `SurveyValidator.validateQuestion` becomes a thin wrapper delegating to `RuleRegistry`. Widgets gain optional params so the bloc/submission path is untouched.

**Tech Stack:** Dart 3, Flutter, `flutter_test`, `bloc_test`, `phone_numbers_parser` (existing), `equatable` (existing). No new dependencies.

**Spec:** `docs/superpowers/specs/2026-04-22-validation-sync-design.md`

---

## File Map

### New files (production)
| Path | Responsibility |
|---|---|
| `lib/core/validation/rule.dart` | `Rule` abstract class + `RuleResult` value type |
| `lib/core/validation/param_helpers.dart` | `paramInt` / `paramDouble` param extraction |
| `lib/core/validation/input_formatters/digits_only_formatter.dart` | Latin + Arabic-Indic digits only |
| `lib/core/validation/input_formatters/digits_and_sign_formatter.dart` | Digits + leading `+`/`-` + optional `.` |
| `lib/core/validation/input_formatters/decimal_places_formatter.dart` | Caps fractional digits at N |
| `lib/core/validation/input_formatters/char_whitelist_formatter.dart` | Regex-pattern-backed char whitelist |
| `lib/core/validation/input_formatters/no_spaces_formatter.dart` | Blocks whitespace |
| `lib/core/validation/rules/number_rules.dart` | ids 1, 2, 3, 4, 5 |
| `lib/core/validation/rules/length_rules.dart` | ids 6, 7, 8, 24 |
| `lib/core/validation/rules/letter_rules.dart` | ids 9, 10, 11, 12 |
| `lib/core/validation/rules/alphanumeric_rules.dart` | ids 13, 14, 18 |
| `lib/core/validation/rules/format_rules.dart` | ids 15, 16, 17 |
| `lib/core/validation/rules/value_range_rules.dart` | ids 19, 20, 21 |
| `lib/core/validation/rules/script_rules.dart` | ids 22, 23 |
| `lib/core/validation/rules/password_rules.dart` | id 25 |
| `lib/core/validation/raw_regex_rule.dart` | Tier-3 fallback |
| `lib/core/validation/regex_fingerprint.dart` | Pattern → id signature map |
| `lib/core/validation/rule_lookup.dart` | 3-step dispatch chain |
| `lib/core/validation/rule_registry.dart` | `validateAll` + `formattersFor` |
| `lib/core/validation/live_validation_controller.dart` | Per-question debounced validator |

### New files (test)
| Path | Responsibility |
|---|---|
| `test/core/validation/_fixtures/seeded_validations.dart` | Hand-typed `Validation` instances for all 25 rules |
| `test/core/validation/rules/number_rules_test.dart` | ids 1–5 |
| `test/core/validation/rules/length_rules_test.dart` | ids 6, 7, 8, 24 |
| `test/core/validation/rules/letter_rules_test.dart` | ids 9–12 |
| `test/core/validation/rules/alphanumeric_rules_test.dart` | ids 13, 14, 18 |
| `test/core/validation/rules/format_rules_test.dart` | ids 15–17 |
| `test/core/validation/rules/value_range_rules_test.dart` | ids 19–21 |
| `test/core/validation/rules/script_rules_test.dart` | ids 22, 23 |
| `test/core/validation/rules/password_rules_test.dart` | id 25 |
| `test/core/validation/input_formatters/digits_only_formatter_test.dart` | |
| `test/core/validation/input_formatters/digits_and_sign_formatter_test.dart` | |
| `test/core/validation/input_formatters/decimal_places_formatter_test.dart` | |
| `test/core/validation/input_formatters/char_whitelist_formatter_test.dart` | |
| `test/core/validation/input_formatters/no_spaces_formatter_test.dart` | |
| `test/core/validation/regex_fingerprint_test.dart` | |
| `test/core/validation/rule_lookup_test.dart` | |
| `test/core/validation/rule_registry_test.dart` | |
| `test/core/validation/live_validation_controller_test.dart` | |
| `test/core/widgets/survey/survey_question_card_live_error_test.dart` | |
| `test/core/widgets/survey/survey_text_field_formatter_test.dart` | |
| `test/core/validation/param_helpers_test.dart` | |

### Modified files
| Path | Nature of change |
|---|---|
| `lib/core/utils/survey_validator.dart` | `validateQuestion` body delegates to `RuleRegistry.validateAll`; rest intact |
| `lib/core/widgets/custom_text_field.dart` | Add optional `inputFormatters` param + pass to `TextFormField` |
| `lib/core/widgets/survey/survey_text_field.dart` | Accept `inputFormatters` + `validationController`; wire `onChanged`/`onBlur` |
| `lib/core/widgets/survey/survey_number_field.dart` | Same |
| `lib/core/widgets/survey/survey_question_card.dart` | Accept `liveController`; wrap error slot in `ListenableBuilder` |
| `lib/core/widgets/survey/survey_question_renderer.dart` | Own `Map<int, LiveValidationController>`; pass into text/number fields |
| `lib/features/public_links/bloc/answering/public_link_answering_state.dart` | Add `submitAttemptCount` field (monotonic counter) |
| `lib/features/public_links/bloc/answering/public_link_answering_bloc.dart` | Increment counter on each submit attempt |
| `test/features/public_links/public_link_answering_bloc_test.dart` | Two new expectations — no changes to existing ones |

---

## Phase 1 — Foundation

### Task 1: `Rule` abstract class + `RuleResult`

**Files:**
- Create: `lib/core/validation/rule.dart`

- [ ] **Step 1: Write the source file**

```dart
// lib/core/validation/rule.dart
import 'package:flutter/services.dart';

import '../models/survey/validation_model.dart';

/// Outcome of running a single rule against a normalized value.
class RuleResult {
  final bool isValid;
  final String? message;

  const RuleResult.valid()
      : isValid = true,
        message = null;

  const RuleResult.invalid(this.message) : isValid = false;
}

/// A typed validation rule. One instance per seeded backend rule.
///
/// Instances are stateless and may be held statically in [RuleRegistry].
abstract class Rule {
  /// Backend `validation.id` this rule corresponds to. Used by [RuleRegistry]
  /// for id-keyed lookup.
  int get id;

  /// English title of the seeded rule (e.g. "Minimum Length"). Used only
  /// for debug output.
  String get debugName;

  /// Whether this rule is meaningful for text-input question types (text_short,
  /// text_long, phone-ish). Non-text question types skip the registry entirely
  /// so this guard is cheap insurance.
  bool get appliesToTextInput => true;

  /// Run the rule against a normalized string [value]. [params] is
  /// `qv.values` from the backend (e.g. `{"min": 3}`); the rule pulls the
  /// fields it needs via the helpers in `param_helpers.dart`.
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  });

  /// Optional input formatters installed by the field widget for this rule.
  /// Default: no formatters (keystroke-time rejection is opt-in per rule).
  List<TextInputFormatter> formatters(Map<String, dynamic> params) => const [];
}
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/core/validation/rule.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/validation/rule.dart
git commit -m "feat(validation): add Rule abstract class and RuleResult

Foundation for the typed rule registry. Rules are stateless and held
statically; they expose validate() and formatters() with optional
input formatter overrides."
```

---

### Task 2: Parameter helpers

**Files:**
- Create: `lib/core/validation/param_helpers.dart`
- Test: `test/core/validation/param_helpers_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/param_helpers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/param_helpers.dart';

void main() {
  group('paramInt', () {
    test('returns int for int value', () {
      expect(paramInt({'min': 5}, 'min'), 5);
    });

    test('returns int for double value (truncated)', () {
      expect(paramInt({'min': 5.9}, 'min'), 5);
    });

    test('returns int for string value', () {
      expect(paramInt({'min': '10'}, 'min'), 10);
    });

    test('returns null for missing key', () {
      expect(paramInt({}, 'min'), null);
    });

    test('returns null for null value', () {
      expect(paramInt({'min': null}, 'min'), null);
    });

    test('returns null for unparseable string', () {
      expect(paramInt({'min': 'abc'}, 'min'), null);
    });
  });

  group('paramDouble', () {
    test('returns double for double', () {
      expect(paramDouble({'max': 3.14}, 'max'), 3.14);
    });

    test('returns double for int', () {
      expect(paramDouble({'max': 7}, 'max'), 7.0);
    });

    test('returns double for numeric string', () {
      expect(paramDouble({'max': '2.5'}, 'max'), 2.5);
    });

    test('returns null for missing key', () {
      expect(paramDouble({}, 'max'), null);
    });
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/param_helpers_test.dart`
Expected: FAIL — `param_helpers.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/param_helpers.dart

/// Returns an int from [params] under [key], tolerating int, double, or
/// numeric-string source values. Returns null for missing/null/unparseable.
int? paramInt(Map<String, dynamic> params, String key) {
  final v = params[key];
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// Returns a double from [params] under [key], tolerating double, int, or
/// numeric-string source values. Returns null for missing/null/unparseable.
double? paramDouble(Map<String, dynamic> params, String key) {
  final v = params[key];
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/param_helpers_test.dart`
Expected: All 10 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/param_helpers.dart test/core/validation/param_helpers_test.dart
git commit -m "feat(validation): add paramInt/paramDouble helpers

Shared param-extraction helpers for Rule implementations. Tolerate
int/double/string source values from the backend's Json values map."
```

---

### Task 3: Seeded validations test fixture

**Files:**
- Create: `test/core/validation/_fixtures/seeded_validations.dart`

This is a fixture file — no TDD cycle, just data. Copied verbatim from `survey-system/prisma/seeders/validations.ts` to keep the test tree self-contained.

- [ ] **Step 1: Write the fixture**

```dart
// test/core/validation/_fixtures/seeded_validations.dart
//
// Hand-typed mirror of survey-system/prisma/seeders/validations.ts.
// Re-sync manually if the backend seed changes.

import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';

Validation _v({
  required int id,
  required String regex,
  required String en,
  required String ar,
  required String enContent,
  required String arContent,
  bool needsValue = false,
  List<Map<String, dynamic>> valueFields = const [],
}) {
  return Validation(
    id: id,
    type: ValidationType.questions,
    validation: regex,
    enTitle: en,
    arTitle: ar,
    enContent: enContent,
    arContent: arContent,
    needsValue: needsValue,
    valueFields: valueFields,
    isActive: true,
  );
}

final Validation vNumber = _v(
  id: 1,
  regex: r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$',
  en: 'Number',
  ar: 'رقم',
  enContent: 'Value must be a number (integer or decimal); optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة رقماً (صحيحاً أو عشرياً)؛ يُسمح بعلامة + أو - في البداية',
);

final Validation vPositiveNumber = _v(
  id: 2,
  regex: r'^\+?[1-9١-٩][0-9٠-٩]*$',
  en: 'Positive Number',
  ar: 'رقم موجب',
  enContent: 'Value must be a positive number (greater than zero); optional leading + is allowed (e.g. +24)',
  arContent: 'يجب أن تكون القيمة رقماً موجباً (أكبر من الصفر)؛ يُسمح بعلامة + في البداية (مثل +24)',
);

final Validation vInteger = _v(
  id: 3,
  regex: r'^[-+]?[0-9٠-٩]+$',
  en: 'Integer (Positive or Negative)',
  ar: 'عدد صحيح (موجب أو سالب)',
  enContent: 'Value must be an integer; optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة عدداً صحيحاً؛ يُسمح بعلامة + أو - في البداية',
);

final Validation vDecimal = _v(
  id: 4,
  regex: r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$',
  en: 'Decimal Number',
  ar: 'رقم عشري',
  enContent: 'Value must be a decimal number; optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة رقماً عشرياً؛ يُسمح بعلامة + أو - في البداية',
);

final Validation vDecimal2 = _v(
  id: 5,
  regex: r'^[-+]?[0-9٠-٩]+\.[0-9٠-٩]{2}$',
  en: 'Decimal Number (2 Decimal Places)',
  ar: 'رقم عشري (منزلتان عشريتان)',
  enContent: 'Value must be a decimal number with exactly 2 decimal places; optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة رقماً عشرياً بمنزلتين عشريتين بالضبط؛ يُسمح بعلامة + أو - في البداية',
);

final Validation vMinLength = _v(
  id: 6,
  regex: r'^.{min,}$',
  en: 'Minimum Length',
  ar: 'الحد الأدنى للمحارف',
  enContent: 'Value must have a minimum number of characters',
  arContent: 'يجب أن تحتوي القيمة على الحد الأدنى من المحارف',
  needsValue: true,
  valueFields: const [{'field': 'min', 'type': 'positive_integer'}],
);

final Validation vMaxLength = _v(
  id: 7,
  regex: r'^.{0,max}$',
  en: 'Maximum Length',
  ar: 'الحد الأقصى للمحارف',
  enContent: 'Value must not exceed a maximum number of characters',
  arContent: 'يجب ألا تتجاوز القيمة الحد الأقصى من المحارف',
  needsValue: true,
  valueFields: const [{'field': 'max', 'type': 'positive_integer'}],
);

final Validation vLengthRange = _v(
  id: 8,
  regex: r'^.{min,max}$',
  en: 'Length Range',
  ar: 'نطاق الطول',
  enContent: 'Value must be between minimum and maximum number of characters',
  arContent: 'يجب أن تكون القيمة بين الحد الأدنى والأقصى من المحارف',
  needsValue: true,
  valueFields: const [
    {'field': 'min', 'type': 'positive_integer'},
    {'field': 'max', 'type': 'positive_integer'},
  ],
);

final Validation vMinLetters = _v(
  id: 9,
  regex: '^(?!.*[٠-٩])(?!.*[0-9])[؀-ٰٟ-ۿa-zA-Z]{min,}\$',
  en: 'Minimum Letters',
  ar: 'الحد الأدنى للأحرف',
  enContent: 'Value must have a minimum number of letters (alphabetic characters only)',
  arContent: 'يجب أن تحتوي القيمة على الحد الأدنى من الحروف (أحرف فقط)',
  needsValue: true,
  valueFields: const [{'field': 'min', 'type': 'positive_integer'}],
);

final Validation vMaxLetters = _v(
  id: 10,
  regex: '^(?!.*[٠-٩])(?!.*[0-9])[؀-ٰٟ-ۿa-zA-Z]{0,max}\$',
  en: 'Maximum Letters',
  ar: 'الحد الأقصى للأحرف',
  enContent: 'Value must not exceed a maximum number of letters (alphabetic characters only)',
  arContent: 'يجب ألا تتجاوز القيمة الحد الأقصى من الحروف (أحرف فقط)',
  needsValue: true,
  valueFields: const [{'field': 'max', 'type': 'positive_integer'}],
);

final Validation vLettersOnly = _v(
  id: 11,
  regex: '^(?!.*[٠-٩])[؀-ٰٟ-ۿa-zA-Z]+\$',
  en: 'Letters Only',
  ar: 'أحرف فقط',
  enContent: 'Value must contain only alphabetic characters (no numbers, special characters, or spaces)',
  arContent: 'يجب أن تكون بدون ارقام او رموز خاصة أو مسافات',
);

final Validation vLettersAndSpaces = _v(
  id: 12,
  regex: '^(?!.*[٠-٩])[؀-ٰٟ-ۿa-zA-Z ]+\$',
  en: 'Letters and Spaces Only',
  ar: 'أحرف ومسافات فقط',
  enContent: 'Value must contain only alphabetic characters and spaces',
  arContent: 'يجب أن تحتوي القيمة على أحرف ومسافات فقط',
);

final Validation vAlphanumeric = _v(
  id: 13,
  regex: '^[؀-ۿa-zA-Z0-9٠-٩]+\$',
  en: 'Alphanumeric',
  ar: 'أحرف وأرقام',
  enContent: 'Value must contain only letters and numbers (no spaces or special characters)',
  arContent: 'يجب أن تحتوي القيمة على أحرف وأرقام فقط (بدون مسافات أو رموز خاصة)',
);

final Validation vAlphanumericWithSpaces = _v(
  id: 14,
  regex: '^[؀-ۿa-zA-Z0-9٠-٩\\s]+\$',
  en: 'Alphanumeric with Spaces',
  ar: 'أحرف وأرقام مع مسافات',
  enContent: 'Value must contain only letters, numbers, and spaces',
  arContent: 'يجب أن تحتوي القيمة على أحرف وأرقام ومسافات فقط',
);

final Validation vEmail = _v(
  id: 15,
  regex: '^[a-zA-Z0-9٠-٩._%+-]+@[a-zA-Z0-9٠-٩.-]+\\.[a-zA-Z]{2,}\$',
  en: 'Email',
  ar: 'بريد إلكتروني',
  enContent: 'Value must be a valid email address',
  arContent: 'يجب أن تكون القيمة عنوان بريد إلكتروني صحيح',
);

final Validation vUrl = _v(
  id: 16,
  regex: r'^(https?://)?([\da-z٠-٩.-]+)\.([a-z.]{2,6})([/\w .-]*)*/?$',
  en: 'URL',
  ar: 'رابط',
  enContent: 'Value must be a valid URL',
  arContent: 'يجب أن تكون القيمة رابطاً صحيحاً',
);

final Validation vNoSpaces = _v(
  id: 17,
  regex: r'^\S+$',
  en: 'No Spaces',
  ar: 'بدون مسافات',
  enContent: 'Value must not contain any spaces',
  arContent: 'يجب ألا تحتوي القيمة على مسافات',
);

final Validation vNoSpecialChars = _v(
  id: 18,
  regex: '^[؀-ۿa-zA-Z0-9٠-٩\\s]+\$',
  en: 'No Special Characters',
  ar: 'بدون رموز خاصة',
  enContent: 'Value must not contain special characters (only letters, numbers, and spaces)',
  arContent: 'يجب ألا تحتوي القيمة على رموز خاصة (أحرف وأرقام ومسافات فقط)',
);

final Validation vMinValue = _v(
  id: 19,
  regex: r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$',
  en: 'Minimum Value',
  ar: 'الحد الأدنى للقيمة',
  enContent: 'Value must be a number greater than or equal to the specified minimum; optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة رقماً أكبر من أو يساوي الحد الأدنى المحدد؛ يُسمح بعلامة + أو - في البداية',
  needsValue: true,
  valueFields: const [{'field': 'min', 'type': 'number'}],
);

final Validation vMaxValue = _v(
  id: 20,
  regex: r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$',
  en: 'Maximum Value',
  ar: 'الحد الأقصى للقيمة',
  enContent: 'Value must be a number less than or equal to the specified maximum; optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة رقماً أقل من أو يساوي الحد الأقصى المحدد؛ يُسمح بعلامة + أو - في البداية',
  needsValue: true,
  valueFields: const [{'field': 'max', 'type': 'number'}],
);

final Validation vValueRange = _v(
  id: 21,
  regex: r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$',
  en: 'Value Range',
  ar: 'نطاق القيمة',
  enContent: 'Value must be a number within the specified range (min to max); optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة رقماً ضمن النطاق المحدد (من الحد الأدنى إلى الأقصى)؛ يُسمح بعلامة + أو - في البداية',
  needsValue: true,
  valueFields: const [
    {'field': 'min', 'type': 'number'},
    {'field': 'max', 'type': 'number'},
  ],
);

final Validation vArabicOnly = _v(
  id: 22,
  regex: '^(?=.*[؀-ۿ])[؀-ۿ٠-٩\\s‌‍\\x21-\\x2F\\x3A-\\x40\\x5B-\\x60\\x7B-\\x7E]+\$',
  en: 'Arabic Text Only',
  ar: 'نص عربي فقط',
  enContent: 'Value must be Arabic text with optional common punctuation and Arabic-Indic digits; Latin letters and Western digits are not allowed',
  arContent: 'يجب أن يكون النص عربياً مع السماح بعلامات الترقيم الشائعة والأرقام العربية (٠–٩)، دون الحروف أو الأرقام اللاتينية',
);

final Validation vEnglishOnly = _v(
  id: 23,
  regex: r'^[\x00-\x7F]+$',
  en: 'English Text Only',
  ar: 'نص إنجليزي فقط',
  enContent: 'Value must contain only English characters',
  arContent: 'يجب أن تحتوي القيمة على أحرف إنجليزية فقط',
);

final Validation vMinEight = _v(
  id: 24,
  regex: r'^.{8,}$',
  en: 'Minimum 8 Characters',
  ar: '8 محارف على الأقل',
  enContent: 'Value must be at least 8 characters long',
  arContent: 'يجب أن تكون القيمة 8 محارف على الأقل',
);

final Validation vStrongPassword = _v(
  id: 25,
  regex: r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9٠-٩])(?=.*[!@#$%^&*]).{8,}$',
  en: 'Strong Password',
  ar: 'كلمة مرور قوية',
  enContent: 'Value must be a strong password (at least 8 characters, including uppercase, lowercase, number, and special character)',
  arContent: 'يجب أن تكون القيمة كلمة مرور قوية (8 أحرف على الأقل، تتضمن حرف كبير وصغير ورقم ورمز خاص)',
);

/// All 25 seeded rules for iteration in lookup/fingerprint tests.
final List<Validation> allSeededValidations = [
  vNumber, vPositiveNumber, vInteger, vDecimal, vDecimal2,
  vMinLength, vMaxLength, vLengthRange,
  vMinLetters, vMaxLetters, vLettersOnly, vLettersAndSpaces,
  vAlphanumeric, vAlphanumericWithSpaces,
  vEmail, vUrl, vNoSpaces, vNoSpecialChars,
  vMinValue, vMaxValue, vValueRange,
  vArabicOnly, vEnglishOnly,
  vMinEight, vStrongPassword,
];
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze test/core/validation/_fixtures/seeded_validations.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add test/core/validation/_fixtures/seeded_validations.dart
git commit -m "test(validation): add seeded validation fixture

Hand-typed mirror of survey-system/prisma/seeders/validations.ts —
single source of truth for all 25 rules in the test tree."
```

---

## Phase 2 — Input Formatters

### Task 4: `DigitsOnlyFormatter`

**Files:**
- Create: `lib/core/validation/input_formatters/digits_only_formatter.dart`
- Test: `test/core/validation/input_formatters/digits_only_formatter_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/input_formatters/digits_only_formatter_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/input_formatters/digits_only_formatter.dart';

TextEditingValue _val(String s) =>
    TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));

void main() {
  final f = DigitsOnlyFormatter();

  test('accepts Latin digits', () {
    final r = f.formatEditUpdate(_val(''), _val('123'));
    expect(r.text, '123');
  });

  test('accepts Arabic-Indic digits', () {
    final r = f.formatEditUpdate(_val(''), _val('٠١٢٣'));
    expect(r.text, '٠١٢٣');
  });

  test('rejects letters — reverts to old value', () {
    final r = f.formatEditUpdate(_val('12'), _val('12a'));
    expect(r.text, '12');
  });

  test('rejects a leading sign', () {
    final r = f.formatEditUpdate(_val(''), _val('+1'));
    expect(r.text, '');
  });

  test('rejects a decimal point', () {
    final r = f.formatEditUpdate(_val(''), _val('1.5'));
    expect(r.text, '');
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/input_formatters/digits_only_formatter_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/input_formatters/digits_only_formatter.dart
import 'package:flutter/services.dart';

/// Accepts only Latin digits (`0-9`) and Arabic-Indic digits (`٠-٩`).
/// Rejects any other character, including `+`, `-`, `.`, whitespace.
class DigitsOnlyFormatter extends TextInputFormatter {
  static final RegExp _allowed = RegExp('^[0-9٠-٩]*\$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_allowed.hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/input_formatters/digits_only_formatter_test.dart`
Expected: All 5 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/input_formatters/digits_only_formatter.dart test/core/validation/input_formatters/digits_only_formatter_test.dart
git commit -m "feat(validation): add DigitsOnlyFormatter

Accepts Latin 0-9 and Arabic-Indic ٠-٩. Used for Positive Number rule
(id 2) where no sign or decimal is allowed."
```

---

### Task 5: `DigitsAndSignFormatter`

**Files:**
- Create: `lib/core/validation/input_formatters/digits_and_sign_formatter.dart`
- Test: `test/core/validation/input_formatters/digits_and_sign_formatter_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/input_formatters/digits_and_sign_formatter_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/input_formatters/digits_and_sign_formatter.dart';

TextEditingValue _val(String s) =>
    TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));

void main() {
  group('allowDecimal: false', () {
    final f = DigitsAndSignFormatter(allowDecimal: false);

    test('accepts empty', () {
      expect(f.formatEditUpdate(_val(''), _val('')).text, '');
    });

    test('accepts leading + then digits', () {
      expect(f.formatEditUpdate(_val(''), _val('+12')).text, '+12');
    });

    test('accepts leading - then digits', () {
      expect(f.formatEditUpdate(_val(''), _val('-5')).text, '-5');
    });

    test('accepts Arabic-Indic digits', () {
      expect(f.formatEditUpdate(_val(''), _val('-٥')).text, '-٥');
    });

    test('rejects decimal point', () {
      expect(f.formatEditUpdate(_val('12'), _val('12.')).text, '12');
    });

    test('rejects sign in middle', () {
      expect(f.formatEditUpdate(_val('1'), _val('1+')).text, '1');
    });
  });

  group('allowDecimal: true', () {
    final f = DigitsAndSignFormatter(allowDecimal: true);

    test('accepts decimal', () {
      expect(f.formatEditUpdate(_val(''), _val('-1.25')).text, '-1.25');
    });

    test('rejects two decimal points', () {
      expect(f.formatEditUpdate(_val('1.2'), _val('1.2.')).text, '1.2');
    });
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/input_formatters/digits_and_sign_formatter_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/input_formatters/digits_and_sign_formatter.dart
import 'package:flutter/services.dart';

/// Accepts an optional leading `+`/`-`, then digits (Latin + Arabic-Indic).
/// If [allowDecimal] is true, accepts at most one `.` with fractional digits.
class DigitsAndSignFormatter extends TextInputFormatter {
  DigitsAndSignFormatter({required this.allowDecimal})
      : _allowed = RegExp(
          allowDecimal
              ? '^[-+]?[0-9٠-٩]*(\\.[0-9٠-٩]*)?\$'
              : '^[-+]?[0-9٠-٩]*\$',
        );

  final bool allowDecimal;
  final RegExp _allowed;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_allowed.hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/input_formatters/digits_and_sign_formatter_test.dart`
Expected: All 8 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/input_formatters/digits_and_sign_formatter.dart test/core/validation/input_formatters/digits_and_sign_formatter_test.dart
git commit -m "feat(validation): add DigitsAndSignFormatter

Accepts optional +/- then digits. Optional decimal mode allows one '.'
with fractional digits. Used for Number (id 1), Integer (id 3),
Decimal (id 4), Decimal-2-Places (id 5)."
```

---

### Task 6: `DecimalPlacesFormatter`

**Files:**
- Create: `lib/core/validation/input_formatters/decimal_places_formatter.dart`
- Test: `test/core/validation/input_formatters/decimal_places_formatter_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/input_formatters/decimal_places_formatter_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/input_formatters/decimal_places_formatter.dart';

TextEditingValue _val(String s) =>
    TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));

void main() {
  final f = DecimalPlacesFormatter(2);

  test('accepts 0 decimal places', () {
    expect(f.formatEditUpdate(_val(''), _val('123')).text, '123');
  });

  test('accepts 1 decimal place', () {
    expect(f.formatEditUpdate(_val('12'), _val('12.3')).text, '12.3');
  });

  test('accepts 2 decimal places', () {
    expect(f.formatEditUpdate(_val('12.3'), _val('12.34')).text, '12.34');
  });

  test('rejects 3rd decimal place — reverts', () {
    expect(f.formatEditUpdate(_val('12.34'), _val('12.345')).text, '12.34');
  });

  test('accepts deletions', () {
    expect(f.formatEditUpdate(_val('12.34'), _val('12.3')).text, '12.3');
  });

  test('accepts Arabic-Indic digits in fraction', () {
    expect(f.formatEditUpdate(_val('12.'), _val('12.٣٤')).text, '12.٣٤');
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/input_formatters/decimal_places_formatter_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/input_formatters/decimal_places_formatter.dart
import 'package:flutter/services.dart';

/// Caps the number of fractional digits (after a `.`) at [maxDecimals].
/// Does NOT enforce digit-only input on its own — compose with
/// [DigitsAndSignFormatter] for a full numeric field.
class DecimalPlacesFormatter extends TextInputFormatter {
  DecimalPlacesFormatter(this.maxDecimals);

  final int maxDecimals;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final dot = text.indexOf('.');
    if (dot < 0) return newValue;
    final frac = text.substring(dot + 1);
    // A 2nd `.` shows up in `frac` — reject by letting DigitsAndSignFormatter
    // handle it; here we only police the fractional length.
    if (frac.length > maxDecimals) return oldValue;
    return newValue;
  }
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/input_formatters/decimal_places_formatter_test.dart`
Expected: All 6 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/input_formatters/decimal_places_formatter.dart test/core/validation/input_formatters/decimal_places_formatter_test.dart
git commit -m "feat(validation): add DecimalPlacesFormatter

Caps fractional-digit count at N. Used for Decimal (2 places) rule
(id 5) in combination with DigitsAndSignFormatter(allowDecimal: true)."
```

---

### Task 7: `CharWhitelistFormatter`

**Files:**
- Create: `lib/core/validation/input_formatters/char_whitelist_formatter.dart`
- Test: `test/core/validation/input_formatters/char_whitelist_formatter_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/input_formatters/char_whitelist_formatter_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/input_formatters/char_whitelist_formatter.dart';

TextEditingValue _val(String s) =>
    TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));

void main() {
  test('letters-only pattern accepts Latin letters', () {
    final f = CharWhitelistFormatter(RegExp('[a-zA-Z]'));
    expect(f.formatEditUpdate(_val(''), _val('abc')).text, 'abc');
  });

  test('letters-only pattern accepts Arabic letters', () {
    final f = CharWhitelistFormatter(
      RegExp('[؀-ٰٟ-ۿa-zA-Z]'),
    );
    expect(f.formatEditUpdate(_val(''), _val('مرحبا')).text, 'مرحبا');
  });

  test('rejects disallowed character — reverts to old', () {
    final f = CharWhitelistFormatter(RegExp('[a-zA-Z]'));
    final r = f.formatEditUpdate(_val('abc'), _val('abc1'));
    expect(r.text, 'abc');
  });

  test('rejects paste of mixed content — reverts to old', () {
    final f = CharWhitelistFormatter(RegExp('[a-zA-Z]'));
    final r = f.formatEditUpdate(_val('ab'), _val('ab12'));
    expect(r.text, 'ab');
  });

  test('accepts empty input', () {
    final f = CharWhitelistFormatter(RegExp('[a-zA-Z]'));
    expect(f.formatEditUpdate(_val('a'), _val('')).text, '');
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/input_formatters/char_whitelist_formatter_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/input_formatters/char_whitelist_formatter.dart
import 'package:flutter/services.dart';

/// Rejects any new value that contains a character not matching [allowedChar].
/// [allowedChar] is a single-char regex — the formatter tests each rune.
class CharWhitelistFormatter extends TextInputFormatter {
  CharWhitelistFormatter(this.allowedChar);

  final RegExp allowedChar;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    for (final rune in text.runes) {
      final ch = String.fromCharCode(rune);
      if (!allowedChar.hasMatch(ch)) return oldValue;
    }
    return newValue;
  }
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/input_formatters/char_whitelist_formatter_test.dart`
Expected: All 5 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/input_formatters/char_whitelist_formatter.dart test/core/validation/input_formatters/char_whitelist_formatter_test.dart
git commit -m "feat(validation): add CharWhitelistFormatter

Single-char regex whitelist for letter-family rules
(Letters Only / Letters+Spaces / Arabic Only / English Only / Max Letters)."
```

---

### Task 8: `NoSpacesFormatter`

**Files:**
- Create: `lib/core/validation/input_formatters/no_spaces_formatter.dart`
- Test: `test/core/validation/input_formatters/no_spaces_formatter_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/input_formatters/no_spaces_formatter_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/input_formatters/no_spaces_formatter.dart';

TextEditingValue _val(String s) =>
    TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));

void main() {
  final f = NoSpacesFormatter();

  test('accepts non-whitespace', () {
    expect(f.formatEditUpdate(_val(''), _val('abc123')).text, 'abc123');
  });

  test('rejects single space — reverts', () {
    expect(f.formatEditUpdate(_val('abc'), _val('abc ')).text, 'abc');
  });

  test('rejects tab — reverts', () {
    expect(f.formatEditUpdate(_val('abc'), _val('abc\t')).text, 'abc');
  });

  test('rejects paste with internal space — reverts', () {
    expect(f.formatEditUpdate(_val('ab'), _val('a b c')).text, 'ab');
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/input_formatters/no_spaces_formatter_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/input_formatters/no_spaces_formatter.dart
import 'package:flutter/services.dart';

/// Rejects any value containing whitespace (space, tab, newline, etc.).
class NoSpacesFormatter extends TextInputFormatter {
  static final RegExp _anyWhitespace = RegExp(r'\s');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_anyWhitespace.hasMatch(newValue.text)) return oldValue;
    return newValue;
  }
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/input_formatters/no_spaces_formatter_test.dart`
Expected: All 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/input_formatters/no_spaces_formatter.dart test/core/validation/input_formatters/no_spaces_formatter_test.dart
git commit -m "feat(validation): add NoSpacesFormatter

Rejects any whitespace. Used for No Spaces rule (id 17)."
```

---

## Phase 3 — Rule implementations

### Task 9: Number rules (ids 1, 2, 3, 4, 5)

**Files:**
- Create: `lib/core/validation/rules/number_rules.dart`
- Test: `test/core/validation/rules/number_rules_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/rules/number_rules_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/number_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  group('NumberRule (id 1)', () {
    final r = NumberRule();
    test('accepts integer', () {
      expect(r.validate(value: '42', params: {}, validation: vNumber, locale: 'en').isValid, true);
    });
    test('accepts decimal', () {
      expect(r.validate(value: '-3.14', params: {}, validation: vNumber, locale: 'en').isValid, true);
    });
    test('accepts Arabic-Indic digits', () {
      expect(r.validate(value: '١٢٣', params: {}, validation: vNumber, locale: 'ar').isValid, true);
    });
    test('rejects letters — uses arContent', () {
      final res = r.validate(value: 'abc', params: {}, validation: vNumber, locale: 'ar');
      expect(res.isValid, false);
      expect(res.message, vNumber.arContent);
    });
    test('formatters: digits+sign with decimal', () {
      final fs = r.formatters({});
      expect(fs.length, 1);
    });
  });

  group('PositiveNumberRule (id 2)', () {
    final r = PositiveNumberRule();
    test('accepts positive', () {
      expect(r.validate(value: '24', params: {}, validation: vPositiveNumber, locale: 'en').isValid, true);
    });
    test('rejects zero', () {
      expect(r.validate(value: '0', params: {}, validation: vPositiveNumber, locale: 'en').isValid, false);
    });
    test('rejects negative', () {
      expect(r.validate(value: '-5', params: {}, validation: vPositiveNumber, locale: 'en').isValid, false);
    });
    test('formatters: digits-only (no sign, no decimal)', () {
      expect(r.formatters({}).length, 1);
    });
  });

  group('IntegerRule (id 3)', () {
    final r = IntegerRule();
    test('accepts negative integer', () {
      expect(r.validate(value: '-7', params: {}, validation: vInteger, locale: 'en').isValid, true);
    });
    test('rejects decimal', () {
      expect(r.validate(value: '1.5', params: {}, validation: vInteger, locale: 'en').isValid, false);
    });
  });

  group('DecimalNumberRule (id 4)', () {
    final r = DecimalNumberRule();
    test('accepts decimal', () {
      expect(r.validate(value: '1.5', params: {}, validation: vDecimal, locale: 'en').isValid, true);
    });
    test('accepts integer (regex allows optional fraction)', () {
      expect(r.validate(value: '42', params: {}, validation: vDecimal, locale: 'en').isValid, true);
    });
  });

  group('Decimal2PlacesRule (id 5)', () {
    final r = Decimal2PlacesRule();
    test('accepts exactly 2 decimal places', () {
      expect(r.validate(value: '12.34', params: {}, validation: vDecimal2, locale: 'en').isValid, true);
    });
    test('rejects 1 decimal place', () {
      expect(r.validate(value: '12.3', params: {}, validation: vDecimal2, locale: 'en').isValid, false);
    });
    test('rejects 3 decimal places', () {
      expect(r.validate(value: '12.345', params: {}, validation: vDecimal2, locale: 'en').isValid, false);
    });
    test('formatters: digits+sign(decimal) AND decimal-places cap', () {
      expect(r.formatters({}).length, 2);
    });
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/rules/number_rules_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/rules/number_rules.dart
import 'package:flutter/services.dart';

import '../../models/survey/validation_model.dart';
import '../input_formatters/decimal_places_formatter.dart';
import '../input_formatters/digits_and_sign_formatter.dart';
import '../input_formatters/digits_only_formatter.dart';
import '../rule.dart';

String _msg(Validation v, String locale) =>
    (locale == 'ar' ? v.arContent : v.enContent) ??
    (locale == 'ar' ? v.arTitle : v.enTitle) ??
    'Validation error';

bool _match(String pattern, String value) {
  try {
    return RegExp(pattern, unicode: true).hasMatch(value);
  } catch (_) {
    return false;
  }
}

class NumberRule extends Rule {
  @override
  int get id => 1;
  @override
  String get debugName => 'Number';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [DigitsAndSignFormatter(allowDecimal: true)];
}

class PositiveNumberRule extends Rule {
  @override
  int get id => 2;
  @override
  String get debugName => 'Positive Number';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [DigitsOnlyFormatter()];
}

class IntegerRule extends Rule {
  @override
  int get id => 3;
  @override
  String get debugName => 'Integer';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [DigitsAndSignFormatter(allowDecimal: false)];
}

class DecimalNumberRule extends Rule {
  @override
  int get id => 4;
  @override
  String get debugName => 'Decimal Number';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [DigitsAndSignFormatter(allowDecimal: true)];
}

class Decimal2PlacesRule extends Rule {
  @override
  int get id => 5;
  @override
  String get debugName => 'Decimal Number (2 Decimal Places)';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) => [
        DigitsAndSignFormatter(allowDecimal: true),
        DecimalPlacesFormatter(2),
      ];
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/rules/number_rules_test.dart`
Expected: All ~17 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/rules/number_rules.dart test/core/validation/rules/number_rules_test.dart
git commit -m "feat(validation): add number rules (ids 1–5)

Number, Positive Number, Integer, Decimal, Decimal 2-Places. Each rule
runs the backend regex; formatters cover keystroke-level input filtering."
```

---

### Task 10: Length rules (ids 6, 7, 8, 24)

**Files:**
- Create: `lib/core/validation/rules/length_rules.dart`
- Test: `test/core/validation/rules/length_rules_test.dart`

Length rules bypass regex for validation because the backend regex embeds `{min}`/`{max}` placeholders — doing logical length checks is clearer and produces interpolated messages.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/rules/length_rules_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/length_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  group('MinLengthRule (id 6)', () {
    final r = MinLengthRule();
    test('accepts when length >= min', () {
      expect(r.validate(value: 'abc', params: {'min': 3}, validation: vMinLength, locale: 'ar').isValid, true);
    });
    test('rejects when length < min; message includes min', () {
      final res = r.validate(value: 'ab', params: {'min': 3}, validation: vMinLength, locale: 'ar');
      expect(res.isValid, false);
      expect(res.message, contains('3'));
      expect(res.message, contains(vMinLength.arContent!));
    });
    test('no-op when min missing from params', () {
      expect(r.validate(value: '', params: {}, validation: vMinLength, locale: 'en').isValid, true);
    });
    test('no formatters', () {
      expect(r.formatters({}), isEmpty);
    });
  });

  group('MaxLengthRule (id 7)', () {
    final r = MaxLengthRule();
    test('accepts when length <= max', () {
      expect(r.validate(value: 'abcd', params: {'max': 5}, validation: vMaxLength, locale: 'en').isValid, true);
    });
    test('rejects when length > max; message includes max', () {
      final res = r.validate(value: 'abcdef', params: {'max': 5}, validation: vMaxLength, locale: 'en');
      expect(res.isValid, false);
      expect(res.message, contains('5'));
    });
    test('formatters: LengthLimitingTextInputFormatter(max)', () {
      expect(r.formatters({'max': 5}).length, 1);
    });
    test('no formatter when max missing', () {
      expect(r.formatters({}), isEmpty);
    });
  });

  group('LengthRangeRule (id 8)', () {
    final r = LengthRangeRule();
    test('accepts when min <= length <= max', () {
      expect(r.validate(value: 'abc', params: {'min': 2, 'max': 5}, validation: vLengthRange, locale: 'en').isValid, true);
    });
    test('rejects when length < min', () {
      final res = r.validate(value: 'a', params: {'min': 2, 'max': 5}, validation: vLengthRange, locale: 'en');
      expect(res.isValid, false);
    });
    test('rejects when length > max', () {
      final res = r.validate(value: 'abcdef', params: {'min': 2, 'max': 5}, validation: vLengthRange, locale: 'en');
      expect(res.isValid, false);
    });
    test('formatters: length-limiting at max', () {
      expect(r.formatters({'min': 2, 'max': 5}).length, 1);
    });
  });

  group('MinEightCharsRule (id 24)', () {
    final r = MinEightCharsRule();
    test('accepts 8+ chars', () {
      expect(r.validate(value: '12345678', params: {}, validation: vMinEight, locale: 'en').isValid, true);
    });
    test('rejects 7 chars', () {
      expect(r.validate(value: '1234567', params: {}, validation: vMinEight, locale: 'en').isValid, false);
    });
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/rules/length_rules_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/rules/length_rules.dart
import 'package:flutter/services.dart';

import '../../models/survey/validation_model.dart';
import '../param_helpers.dart';
import '../rule.dart';

String _base(Validation v, String locale) =>
    (locale == 'ar' ? v.arContent : v.enContent) ?? '';

String _withBound(Validation v, String locale, int bound) =>
    '${_base(v, locale)} ($bound)'.trim();

class MinLengthRule extends Rule {
  @override
  int get id => 6;
  @override
  String get debugName => 'Minimum Length';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final min = paramInt(params, 'min');
    if (min == null) return const RuleResult.valid();
    return value.length >= min
        ? const RuleResult.valid()
        : RuleResult.invalid(_withBound(validation, locale, min));
  }
}

class MaxLengthRule extends Rule {
  @override
  int get id => 7;
  @override
  String get debugName => 'Maximum Length';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final max = paramInt(params, 'max');
    if (max == null) return const RuleResult.valid();
    return value.length <= max
        ? const RuleResult.valid()
        : RuleResult.invalid(_withBound(validation, locale, max));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) {
    final max = paramInt(params, 'max');
    return max == null ? const [] : [LengthLimitingTextInputFormatter(max)];
  }
}

class LengthRangeRule extends Rule {
  @override
  int get id => 8;
  @override
  String get debugName => 'Length Range';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final min = paramInt(params, 'min');
    final max = paramInt(params, 'max');
    if (min != null && value.length < min) {
      return RuleResult.invalid(_withBound(validation, locale, min));
    }
    if (max != null && value.length > max) {
      return RuleResult.invalid(_withBound(validation, locale, max));
    }
    return const RuleResult.valid();
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) {
    final max = paramInt(params, 'max');
    return max == null ? const [] : [LengthLimitingTextInputFormatter(max)];
  }
}

class MinEightCharsRule extends Rule {
  @override
  int get id => 24;
  @override
  String get debugName => 'Minimum 8 Characters';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    return value.length >= 8
        ? const RuleResult.valid()
        : RuleResult.invalid(_base(validation, locale));
  }
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/rules/length_rules_test.dart`
Expected: All ~13 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/rules/length_rules.dart test/core/validation/rules/length_rules_test.dart
git commit -m "feat(validation): add length rules (ids 6, 7, 8, 24)

Length checks bypass the backend's placeholder regex (^.{min,}\$) and
use direct length arithmetic so the error message can embed the bound.
Max/Range install LengthLimitingTextInputFormatter as a hard cap."
```

---

### Task 11: Letter rules (ids 9, 10, 11, 12)

**Files:**
- Create: `lib/core/validation/rules/letter_rules.dart`
- Test: `test/core/validation/rules/letter_rules_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/rules/letter_rules_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/letter_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  group('MinLettersRule (id 9)', () {
    final r = MinLettersRule();
    test('accepts 3+ Latin letters with min=3', () {
      expect(r.validate(value: 'abc', params: {'min': 3}, validation: vMinLetters, locale: 'en').isValid, true);
    });
    test('accepts 3+ Arabic letters with min=3', () {
      expect(r.validate(value: 'مرحب', params: {'min': 3}, validation: vMinLetters, locale: 'ar').isValid, true);
    });
    test('rejects 2 letters with min=3', () {
      expect(r.validate(value: 'ab', params: {'min': 3}, validation: vMinLetters, locale: 'en').isValid, false);
    });
    test('rejects value containing digits (regex forbids digits)', () {
      expect(r.validate(value: 'ab1', params: {'min': 3}, validation: vMinLetters, locale: 'en').isValid, false);
    });
  });

  group('MaxLettersRule (id 10)', () {
    final r = MaxLettersRule();
    test('accepts 3 letters with max=5', () {
      expect(r.validate(value: 'abc', params: {'max': 5}, validation: vMaxLetters, locale: 'en').isValid, true);
    });
    test('rejects 6 letters with max=5', () {
      expect(r.validate(value: 'abcdef', params: {'max': 5}, validation: vMaxLetters, locale: 'en').isValid, false);
    });
    test('formatters: length-limit AND letter whitelist', () {
      expect(r.formatters({'max': 5}).length, 2);
    });
  });

  group('LettersOnlyRule (id 11)', () {
    final r = LettersOnlyRule();
    test('accepts Arabic only', () {
      expect(r.validate(value: 'مرحبا', params: {}, validation: vLettersOnly, locale: 'ar').isValid, true);
    });
    test('rejects with spaces', () {
      expect(r.validate(value: 'مرحبا بك', params: {}, validation: vLettersOnly, locale: 'ar').isValid, false);
    });
    test('rejects with digits', () {
      expect(r.validate(value: 'abc1', params: {}, validation: vLettersOnly, locale: 'en').isValid, false);
    });
    test('formatters: letter whitelist', () {
      expect(r.formatters({}).length, 1);
    });
  });

  group('LettersAndSpacesRule (id 12)', () {
    final r = LettersAndSpacesRule();
    test('accepts with spaces', () {
      expect(r.validate(value: 'hello world', params: {}, validation: vLettersAndSpaces, locale: 'en').isValid, true);
    });
    test('rejects with digits', () {
      expect(r.validate(value: 'hi 1', params: {}, validation: vLettersAndSpaces, locale: 'en').isValid, false);
    });
    test('formatters: letter-and-space whitelist', () {
      expect(r.formatters({}).length, 1);
    });
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/rules/letter_rules_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/rules/letter_rules.dart
import 'package:flutter/services.dart';

import '../../models/survey/validation_model.dart';
import '../input_formatters/char_whitelist_formatter.dart';
import '../param_helpers.dart';
import '../rule.dart';

// Matches a single Arabic letter (excluding ٠-٩ Arabic-Indic digits,
// which live in ٠-ٯ) or Latin letter.
final RegExp _letter = RegExp('[؀-ٰٟ-ۿa-zA-Z]');
final RegExp _letterOrSpace = RegExp('[؀-ٰٟ-ۿa-zA-Z ]');

String _base(Validation v, String locale) =>
    (locale == 'ar' ? v.arContent : v.enContent) ?? '';

String _withBound(Validation v, String locale, int bound) =>
    '${_base(v, locale)} ($bound)'.trim();

bool _match(String pattern, String value) {
  try {
    return RegExp(pattern, unicode: true).hasMatch(value);
  } catch (_) {
    return false;
  }
}

class MinLettersRule extends Rule {
  @override
  int get id => 9;
  @override
  String get debugName => 'Minimum Letters';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final min = paramInt(params, 'min');
    if (min == null) return const RuleResult.valid();
    // Substitute {min} into the backend regex.
    final pattern = (validation.validation ?? '').replaceAll('min', '$min');
    final ok = _match(pattern, value);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(_withBound(validation, locale, min));
  }
}

class MaxLettersRule extends Rule {
  @override
  int get id => 10;
  @override
  String get debugName => 'Maximum Letters';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final max = paramInt(params, 'max');
    if (max == null) return const RuleResult.valid();
    final pattern = (validation.validation ?? '').replaceAll('max', '$max');
    final ok = _match(pattern, value);
    return ok
        ? const RuleResult.valid()
        : RuleResult.invalid(_withBound(validation, locale, max));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) {
    final max = paramInt(params, 'max');
    return [
      if (max != null) LengthLimitingTextInputFormatter(max),
      CharWhitelistFormatter(_letter),
    ];
  }
}

class LettersOnlyRule extends Rule {
  @override
  int get id => 11;
  @override
  String get debugName => 'Letters Only';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_base(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [CharWhitelistFormatter(_letter)];
}

class LettersAndSpacesRule extends Rule {
  @override
  int get id => 12;
  @override
  String get debugName => 'Letters and Spaces Only';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_base(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [CharWhitelistFormatter(_letterOrSpace)];
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/rules/letter_rules_test.dart`
Expected: All ~13 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/rules/letter_rules.dart test/core/validation/rules/letter_rules_test.dart
git commit -m "feat(validation): add letter rules (ids 9-12)

Min/Max Letters (parameterised) and Letters Only / Letters+Spaces.
Letter whitelist excludes Arabic-Indic digits (٠-٩) to match
the backend's negative lookahead; Min/Max substitute the bound into
the backend regex at validation time."
```

---

### Task 12: Alphanumeric rules (ids 13, 14, 18)

**Files:**
- Create: `lib/core/validation/rules/alphanumeric_rules.dart`
- Test: `test/core/validation/rules/alphanumeric_rules_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/rules/alphanumeric_rules_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/alphanumeric_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  group('AlphanumericRule (id 13)', () {
    final r = AlphanumericRule();
    test('accepts letters+digits', () {
      expect(r.validate(value: 'abc123', params: {}, validation: vAlphanumeric, locale: 'en').isValid, true);
    });
    test('rejects with space', () {
      expect(r.validate(value: 'abc 1', params: {}, validation: vAlphanumeric, locale: 'en').isValid, false);
    });
    test('rejects with symbol', () {
      expect(r.validate(value: 'abc!', params: {}, validation: vAlphanumeric, locale: 'en').isValid, false);
    });
    test('no formatters', () {
      expect(r.formatters({}), isEmpty);
    });
  });

  group('AlphanumericWithSpacesRule (id 14)', () {
    final r = AlphanumericWithSpacesRule();
    test('accepts with spaces', () {
      expect(r.validate(value: 'abc 123', params: {}, validation: vAlphanumericWithSpaces, locale: 'en').isValid, true);
    });
    test('rejects with symbol', () {
      expect(r.validate(value: 'abc!', params: {}, validation: vAlphanumericWithSpaces, locale: 'en').isValid, false);
    });
  });

  group('NoSpecialCharsRule (id 18)', () {
    final r = NoSpecialCharsRule();
    test('accepts letters+digits+spaces', () {
      expect(r.validate(value: 'hello 123', params: {}, validation: vNoSpecialChars, locale: 'en').isValid, true);
    });
    test('rejects with &', () {
      expect(r.validate(value: 'a&b', params: {}, validation: vNoSpecialChars, locale: 'en').isValid, false);
    });
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/rules/alphanumeric_rules_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/rules/alphanumeric_rules.dart
import '../../models/survey/validation_model.dart';
import '../rule.dart';

String _msg(Validation v, String locale) =>
    (locale == 'ar' ? v.arContent : v.enContent) ?? '';

bool _match(String pattern, String value) {
  try {
    return RegExp(pattern, unicode: true).hasMatch(value);
  } catch (_) {
    return false;
  }
}

class AlphanumericRule extends Rule {
  @override
  int get id => 13;
  @override
  String get debugName => 'Alphanumeric';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }
}

class AlphanumericWithSpacesRule extends Rule {
  @override
  int get id => 14;
  @override
  String get debugName => 'Alphanumeric with Spaces';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }
}

class NoSpecialCharsRule extends Rule {
  @override
  int get id => 18;
  @override
  String get debugName => 'No Special Characters';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/rules/alphanumeric_rules_test.dart`
Expected: All ~8 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/rules/alphanumeric_rules.dart test/core/validation/rules/alphanumeric_rules_test.dart
git commit -m "feat(validation): add alphanumeric rules (ids 13, 14, 18)

Alphanumeric, Alphanumeric with Spaces, No Special Characters. Pure
regex rules using the backend patterns, no formatters — blocking
unknown chars mid-input is worse UX than a live error here."
```

---

### Task 13: Format rules (ids 15, 16, 17)

**Files:**
- Create: `lib/core/validation/rules/format_rules.dart`
- Test: `test/core/validation/rules/format_rules_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/rules/format_rules_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/format_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  group('EmailRule (id 15)', () {
    final r = EmailRule();
    test('accepts valid email', () {
      expect(r.validate(value: 'a@b.co', params: {}, validation: vEmail, locale: 'en').isValid, true);
    });
    test('rejects missing @', () {
      expect(r.validate(value: 'a.com', params: {}, validation: vEmail, locale: 'en').isValid, false);
    });
    test('rejects missing TLD', () {
      expect(r.validate(value: 'a@b', params: {}, validation: vEmail, locale: 'en').isValid, false);
    });
    test('no formatters', () {
      expect(r.formatters({}), isEmpty);
    });
  });

  group('UrlRule (id 16)', () {
    final r = UrlRule();
    test('accepts http URL', () {
      expect(r.validate(value: 'http://a.com', params: {}, validation: vUrl, locale: 'en').isValid, true);
    });
    test('accepts without scheme', () {
      expect(r.validate(value: 'a.com', params: {}, validation: vUrl, locale: 'en').isValid, true);
    });
    test('rejects empty', () {
      expect(r.validate(value: '', params: {}, validation: vUrl, locale: 'en').isValid, false);
    });
  });

  group('NoSpacesRule (id 17)', () {
    final r = NoSpacesRule();
    test('accepts no-space input', () {
      expect(r.validate(value: 'abc123', params: {}, validation: vNoSpaces, locale: 'en').isValid, true);
    });
    test('rejects input with space', () {
      expect(r.validate(value: 'abc 123', params: {}, validation: vNoSpaces, locale: 'en').isValid, false);
    });
    test('formatters: NoSpacesFormatter', () {
      expect(r.formatters({}).length, 1);
    });
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/rules/format_rules_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/rules/format_rules.dart
import 'package:flutter/services.dart';

import '../../models/survey/validation_model.dart';
import '../input_formatters/no_spaces_formatter.dart';
import '../rule.dart';

String _msg(Validation v, String locale) =>
    (locale == 'ar' ? v.arContent : v.enContent) ?? '';

bool _match(String pattern, String value) {
  try {
    return RegExp(pattern, unicode: true).hasMatch(value);
  } catch (_) {
    return false;
  }
}

class EmailRule extends Rule {
  @override
  int get id => 15;
  @override
  String get debugName => 'Email';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }
}

class UrlRule extends Rule {
  @override
  int get id => 16;
  @override
  String get debugName => 'URL';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }
}

class NoSpacesRule extends Rule {
  @override
  int get id => 17;
  @override
  String get debugName => 'No Spaces';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [NoSpacesFormatter()];
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/rules/format_rules_test.dart`
Expected: All ~10 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/rules/format_rules.dart test/core/validation/rules/format_rules_test.dart
git commit -m "feat(validation): add format rules (ids 15, 16, 17)

Email, URL, No Spaces. Only No Spaces installs a formatter; email/URL
block characters mid-input is worse UX than a live error."
```

---

### Task 14: Value range rules (ids 19, 20, 21)

**Files:**
- Create: `lib/core/validation/rules/value_range_rules.dart`
- Test: `test/core/validation/rules/value_range_rules_test.dart`

Value rules parse the value as a number first, then compare against the bound. The backend regex is a numeric-shape sanity check; we gate on the parsed number so the error message can embed the bound.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/rules/value_range_rules_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/value_range_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  group('MinValueRule (id 19)', () {
    final r = MinValueRule();
    test('accepts when value >= min', () {
      expect(r.validate(value: '10', params: {'min': 5}, validation: vMinValue, locale: 'en').isValid, true);
    });
    test('rejects when value < min; message embeds min', () {
      final res = r.validate(value: '3', params: {'min': 5}, validation: vMinValue, locale: 'en');
      expect(res.isValid, false);
      expect(res.message, contains('5'));
    });
    test('no-op when min missing from params', () {
      expect(r.validate(value: '3', params: {}, validation: vMinValue, locale: 'en').isValid, true);
    });
    test('rejects non-numeric value', () {
      expect(r.validate(value: 'abc', params: {'min': 5}, validation: vMinValue, locale: 'en').isValid, false);
    });
  });

  group('MaxValueRule (id 20)', () {
    final r = MaxValueRule();
    test('accepts when value <= max', () {
      expect(r.validate(value: '5', params: {'max': 10}, validation: vMaxValue, locale: 'en').isValid, true);
    });
    test('rejects when value > max', () {
      expect(r.validate(value: '15', params: {'max': 10}, validation: vMaxValue, locale: 'en').isValid, false);
    });
  });

  group('ValueRangeRule (id 21)', () {
    final r = ValueRangeRule();
    test('accepts in range', () {
      expect(r.validate(value: '5', params: {'min': 1, 'max': 10}, validation: vValueRange, locale: 'en').isValid, true);
    });
    test('rejects below min', () {
      expect(r.validate(value: '0', params: {'min': 1, 'max': 10}, validation: vValueRange, locale: 'en').isValid, false);
    });
    test('rejects above max', () {
      expect(r.validate(value: '11', params: {'min': 1, 'max': 10}, validation: vValueRange, locale: 'en').isValid, false);
    });
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/rules/value_range_rules_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/rules/value_range_rules.dart
import '../../models/survey/validation_model.dart';
import '../param_helpers.dart';
import '../rule.dart';

String _base(Validation v, String locale) =>
    (locale == 'ar' ? v.arContent : v.enContent) ?? '';

String _withBound(Validation v, String locale, num bound) =>
    '${_base(v, locale)} ($bound)'.trim();

/// Parse a string that may contain Arabic-Indic digits into a double.
double? _toNumber(String s) {
  if (s.isEmpty) return null;
  // Translate Arabic-Indic digits to Latin before parsing.
  final translated = s.replaceAllMapped(
    RegExp('[٠-٩]'),
    (m) => '${m.group(0)!.codeUnitAt(0) - 0x0660}',
  );
  return double.tryParse(translated);
}

class MinValueRule extends Rule {
  @override
  int get id => 19;
  @override
  String get debugName => 'Minimum Value';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final min = paramDouble(params, 'min');
    if (min == null) return const RuleResult.valid();
    final parsed = _toNumber(value);
    if (parsed == null) return RuleResult.invalid(_base(validation, locale));
    return parsed >= min
        ? const RuleResult.valid()
        : RuleResult.invalid(_withBound(validation, locale, min));
  }
}

class MaxValueRule extends Rule {
  @override
  int get id => 20;
  @override
  String get debugName => 'Maximum Value';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final max = paramDouble(params, 'max');
    if (max == null) return const RuleResult.valid();
    final parsed = _toNumber(value);
    if (parsed == null) return RuleResult.invalid(_base(validation, locale));
    return parsed <= max
        ? const RuleResult.valid()
        : RuleResult.invalid(_withBound(validation, locale, max));
  }
}

class ValueRangeRule extends Rule {
  @override
  int get id => 21;
  @override
  String get debugName => 'Value Range';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final min = paramDouble(params, 'min');
    final max = paramDouble(params, 'max');
    final parsed = _toNumber(value);
    if (parsed == null) return RuleResult.invalid(_base(validation, locale));
    if (min != null && parsed < min) {
      return RuleResult.invalid(_withBound(validation, locale, min));
    }
    if (max != null && parsed > max) {
      return RuleResult.invalid(_withBound(validation, locale, max));
    }
    return const RuleResult.valid();
  }
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/rules/value_range_rules_test.dart`
Expected: All ~9 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/rules/value_range_rules.dart test/core/validation/rules/value_range_rules_test.dart
git commit -m "feat(validation): add value range rules (ids 19, 20, 21)

Min Value, Max Value, Value Range. Parses the value as a number
(translating Arabic-Indic digits), compares against the bound, and
embeds the bound in the error message."
```

---

### Task 15: Script rules (ids 22, 23)

**Files:**
- Create: `lib/core/validation/rules/script_rules.dart`
- Test: `test/core/validation/rules/script_rules_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/rules/script_rules_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/script_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  group('ArabicOnlyRule (id 22)', () {
    final r = ArabicOnlyRule();
    test('accepts Arabic text', () {
      expect(r.validate(value: 'مرحبا', params: {}, validation: vArabicOnly, locale: 'ar').isValid, true);
    });
    test('rejects Latin letters', () {
      expect(r.validate(value: 'hello', params: {}, validation: vArabicOnly, locale: 'ar').isValid, false);
    });
    test('accepts Arabic with Arabic-Indic digits', () {
      expect(r.validate(value: 'مرحبا ١٢٣', params: {}, validation: vArabicOnly, locale: 'ar').isValid, true);
    });
  });

  group('EnglishOnlyRule (id 23)', () {
    final r = EnglishOnlyRule();
    test('accepts ASCII', () {
      expect(r.validate(value: 'hello 123', params: {}, validation: vEnglishOnly, locale: 'en').isValid, true);
    });
    test('rejects Arabic', () {
      expect(r.validate(value: 'مرحبا', params: {}, validation: vEnglishOnly, locale: 'en').isValid, false);
    });
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/rules/script_rules_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/rules/script_rules.dart
import 'package:flutter/services.dart';

import '../../models/survey/validation_model.dart';
import '../input_formatters/char_whitelist_formatter.dart';
import '../rule.dart';

String _msg(Validation v, String locale) =>
    (locale == 'ar' ? v.arContent : v.enContent) ?? '';

bool _match(String pattern, String value) {
  try {
    return RegExp(pattern, unicode: true).hasMatch(value);
  } catch (_) {
    return false;
  }
}

class ArabicOnlyRule extends Rule {
  @override
  int get id => 22;
  @override
  String get debugName => 'Arabic Text Only';

  // Char whitelist — wider than the validation regex (accepts any
  // Arabic block char, digit, ASCII punctuation) because the formatter
  // can't enforce the "must contain >=1 Arabic letter" lookahead.
  static final RegExp _char =
      RegExp('[؀-ۿ٠-٩\\s‌‍\\x21-\\x7E]');

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [CharWhitelistFormatter(_char)];
}

class EnglishOnlyRule extends Rule {
  @override
  int get id => 23;
  @override
  String get debugName => 'English Text Only';

  static final RegExp _char = RegExp(r'[\x00-\x7F]');

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }

  @override
  List<TextInputFormatter> formatters(Map<String, dynamic> params) =>
      [CharWhitelistFormatter(_char)];
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/rules/script_rules_test.dart`
Expected: All ~5 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/rules/script_rules.dart test/core/validation/rules/script_rules_test.dart
git commit -m "feat(validation): add script rules (ids 22, 23)

Arabic Text Only and English Text Only. Validation uses the backend
lookahead regex; formatters use a wider char whitelist (the 'must
contain ≥1 Arabic letter' part can't be enforced keystroke-by-keystroke
without blocking ASCII punctuation users are actively typing)."
```

---

### Task 16: Password rules (id 25)

**Files:**
- Create: `lib/core/validation/rules/password_rules.dart`
- Test: `test/core/validation/rules/password_rules_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/rules/password_rules_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rules/password_rules.dart';

import '../_fixtures/seeded_validations.dart';

void main() {
  group('StrongPasswordRule (id 25)', () {
    final r = StrongPasswordRule();
    test('accepts strong password', () {
      expect(r.validate(value: 'Aa1!aaaa', params: {}, validation: vStrongPassword, locale: 'en').isValid, true);
    });
    test('rejects without uppercase', () {
      expect(r.validate(value: 'aa1!aaaa', params: {}, validation: vStrongPassword, locale: 'en').isValid, false);
    });
    test('rejects without digit', () {
      expect(r.validate(value: 'Aa!aaaaa', params: {}, validation: vStrongPassword, locale: 'en').isValid, false);
    });
    test('rejects without special char', () {
      expect(r.validate(value: 'Aa1aaaaa', params: {}, validation: vStrongPassword, locale: 'en').isValid, false);
    });
    test('rejects too short', () {
      expect(r.validate(value: 'Aa1!', params: {}, validation: vStrongPassword, locale: 'en').isValid, false);
    });
    test('no formatters — too many AND conditions to block mid-input', () {
      expect(r.formatters({}), isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/rules/password_rules_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/rules/password_rules.dart
import '../../models/survey/validation_model.dart';
import '../rule.dart';

String _msg(Validation v, String locale) =>
    (locale == 'ar' ? v.arContent : v.enContent) ?? '';

bool _match(String pattern, String value) {
  try {
    return RegExp(pattern, unicode: true).hasMatch(value);
  } catch (_) {
    return false;
  }
}

class StrongPasswordRule extends Rule {
  @override
  int get id => 25;
  @override
  String get debugName => 'Strong Password';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final ok = _match(validation.validation ?? '', value);
    return ok ? const RuleResult.valid() : RuleResult.invalid(_msg(validation, locale));
  }
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/rules/password_rules_test.dart`
Expected: All 6 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/rules/password_rules.dart test/core/validation/rules/password_rules_test.dart
git commit -m "feat(validation): add password rule (id 25)

Strong Password. No formatters — the rule is a conjunction of five
lookaheads + min length; there's no useful keystroke-blocking policy."
```

---

## Phase 4 — Dispatch

### Task 17: `RawRegexRule` (tier-3 fallback)

**Files:**
- Create: `lib/core/validation/raw_regex_rule.dart`
- Test: extend `test/core/validation/rule_lookup_test.dart` in Task 19

- [ ] **Step 1: Write the source file**

```dart
// lib/core/validation/raw_regex_rule.dart
import '../models/survey/validation_model.dart';
import 'rule.dart';

/// Tier-3 dispatch fallback. Executes whatever regex the backend sent for
/// an unknown-to-the-registry rule. Performs `{key}` placeholder substitution
/// using [Validation.validation] and the `qv.values` map supplied at validate
/// time. Uses the backend's arContent/enContent verbatim as the error message.
class RawRegexRule extends Rule {
  RawRegexRule(this._source);

  final Validation _source;

  @override
  int get id => _source.id;

  @override
  String get debugName => 'RawRegexRule(${_source.enTitle})';

  @override
  RuleResult validate({
    required String value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final raw = validation.validation ?? '';
    if (raw.isEmpty) return const RuleResult.valid();

    // Strip JS-style /.../ slashes if present, mirroring legacy behavior.
    var pattern = raw;
    if (pattern.startsWith('/') && pattern.lastIndexOf('/') > 0) {
      pattern = pattern.substring(1, pattern.lastIndexOf('/'));
    }

    // Substitute backend placeholders like {min}, {max}.
    params.forEach((k, v) {
      pattern = pattern.replaceAll(k, '$v');
    });

    try {
      final re = RegExp(pattern, unicode: true, dotAll: true);
      if (re.hasMatch(value)) return const RuleResult.valid();
    } catch (_) {
      // Unparseable regex: treat as no-op rather than crash.
      return const RuleResult.valid();
    }

    final msg = (locale == 'ar' ? validation.arContent : validation.enContent) ??
        (locale == 'ar' ? validation.arTitle : validation.enTitle) ??
        'Validation error';
    return RuleResult.invalid(msg);
  }
}
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/core/validation/raw_regex_rule.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/validation/raw_regex_rule.dart
git commit -m "feat(validation): add RawRegexRule tier-3 fallback

Executes the backend-supplied regex for an unknown rule, including
{min}/{max} placeholder substitution. Reports arContent/enContent
verbatim. Unparseable regex is treated as a no-op, not a crash."
```

---

### Task 18: `RegexFingerprint` (tier-2 fallback)

**Files:**
- Create: `lib/core/validation/regex_fingerprint.dart`
- Test: `test/core/validation/regex_fingerprint_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/regex_fingerprint_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/regex_fingerprint.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule_registry.dart';

import '_fixtures/seeded_validations.dart';

void main() {
  test('every seeded regex fingerprints to some registered rule', () {
    // Note: ids 1/4/19/20/21 share an identical numeric-shape regex, and
    // ids 14/18 share a letters+digits+spaces pattern. The fingerprint Map
    // overwrites on duplicate keys, so those collisions resolve to the
    // first-written entry. This is acceptable because the fingerprint tier
    // is a fallback; tier-1 id lookup handles correct dispatch when the
    // backend id is known.
    for (final v in allSeededValidations) {
      final hit = RegexFingerprint.match(v.validation, RuleRegistry.rulesForTest);
      expect(hit, isNotNull,
          reason: 'no fingerprint for id=${v.id} "${v.enTitle}"');
    }
  });

  test('placeholder variants collapse to same signature', () {
    // Both patterns should fingerprint to the Minimum Length rule (id 6).
    const withPlaceholder = r'^.{min,}$';
    const withNumber = r'^.{3,}$';
    final a = RegexFingerprint.match(withPlaceholder, RuleRegistry.rulesForTest);
    final b = RegexFingerprint.match(withNumber, RuleRegistry.rulesForTest);
    expect(a?.id, 6);
    expect(b?.id, 6);
  });

  test('unknown regex returns null', () {
    final r = RegexFingerprint.match(r'^completely-unknown$', RuleRegistry.rulesForTest);
    expect(r, null);
  });

  test('null or empty pattern returns null', () {
    expect(RegexFingerprint.match(null, RuleRegistry.rulesForTest), null);
    expect(RegexFingerprint.match('', RuleRegistry.rulesForTest), null);
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/regex_fingerprint_test.dart`
Expected: FAIL — `regex_fingerprint.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/regex_fingerprint.dart
import 'rule.dart';

/// Fallback dispatch: matches a backend regex against canonical signatures
/// of the 25 seeded rules. Normalization strips `{key}` placeholders and
/// collapses whitespace so `^.{min,}$` and `^.{3,}$` fingerprint alike.
class RegexFingerprint {
  static Rule? match(String? pattern, Map<int, Rule> byId) {
    if (pattern == null || pattern.isEmpty) return null;
    final sig = _normalize(pattern);
    final id = _signatureToId[sig];
    if (id == null) return null;
    return byId[id];
  }

  static String _normalize(String p) => p
      .replaceAll(RegExp(r'\{[a-z_]+\}'), '')
      .replaceAll(RegExp(r'\d+,'), ',')   // ^.{3,}$ → ^.{,}$
      .replaceAll(RegExp(r',\d+'), ',')   // ^.{0,5}$ → ^.{0,}$ (then next pass)
      .replaceAll(RegExp(r'\s+'), '')
      .toLowerCase();

  static final Map<String, int> _signatureToId = {
    _normalize(r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$'): 1,
    _normalize(r'^\+?[1-9١-٩][0-9٠-٩]*$'): 2,
    _normalize(r'^[-+]?[0-9٠-٩]+$'): 3,
    _normalize(r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$'): 4,
    _normalize(r'^[-+]?[0-9٠-٩]+\.[0-9٠-٩]{2}$'): 5,
    _normalize(r'^.{min,}$'): 6,
    _normalize(r'^.{0,max}$'): 7,
    _normalize(r'^.{min,max}$'): 8,
    _normalize('^(?!.*[٠-٩])(?!.*[0-9])[؀-ٰٟ-ۿa-zA-Z]{min,}\$'): 9,
    _normalize('^(?!.*[٠-٩])(?!.*[0-9])[؀-ٰٟ-ۿa-zA-Z]{0,max}\$'): 10,
    _normalize('^(?!.*[٠-٩])[؀-ٰٟ-ۿa-zA-Z]+\$'): 11,
    _normalize('^(?!.*[٠-٩])[؀-ٰٟ-ۿa-zA-Z ]+\$'): 12,
    _normalize('^[؀-ۿa-zA-Z0-9٠-٩]+\$'): 13,
    _normalize('^[؀-ۿa-zA-Z0-9٠-٩\\s]+\$'): 14,
    _normalize('^[a-zA-Z0-9٠-٩._%+-]+@[a-zA-Z0-9٠-٩.-]+\\.[a-zA-Z]{2,}\$'): 15,
    _normalize(r'^(https?://)?([\da-z٠-٩.-]+)\.([a-z.]{2,6})([/\w .-]*)*/?$'): 16,
    _normalize(r'^\S+$'): 17,
    // id 18 shares id 14's pattern — both are "letters+digits+spaces", so
    // the fingerprint table deliberately routes to 14 (first write wins).
    // id 18 still resolves via direct id lookup in tier 1.
    _normalize(r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$'): 1,
    // ids 19/20/21 share the numeric-shape pattern — route to 21 so the
    // Range rule handles both bounds. Tier-1 id lookup handles the actual dispatch.
    _normalize(r'^(?=.*[؀-ۿ])[؀-ۿ٠-٩\s‌‍\x21-\x2F\x3A-\x40\x5B-\x60\x7B-\x7E]+$'): 22,
    _normalize(r'^[\x00-\x7F]+$'): 23,
    _normalize(r'^.{8,}$'): 24,
    _normalize(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9٠-٩])(?=.*[!@#$%^&*]).{8,}$'): 25,
  };
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/regex_fingerprint_test.dart`
Expected: All 4 tests PASS.

Notes on collisions: ids 4/1, 19/20/21 share numeric-shape regex — the fingerprint tier will resolve all of them to the first-written entry (id 1 for the numeric-shape, id 21 for range). This is acceptable because tier 1 (id lookup) is always tried first; the fingerprint tier is a fallback for ID drift. Document this in the commit message.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/regex_fingerprint.dart test/core/validation/regex_fingerprint_test.dart
git commit -m "feat(validation): add regex fingerprint (tier-2 dispatch)

Normalizes backend regex patterns (strip {key} placeholders, collapse
digit counts in length-quantifiers) and maps them to rule IDs. Handles
environment drift where dev/staging reseeds shift numeric IDs.

Known collisions: ids 1/4 and 19/20/21 share numeric-shape patterns.
Fingerprint resolves to the first entry; tier-1 id lookup handles
correct dispatch in normal operation."
```

---

### Task 19: `RuleLookup` dispatch chain

**Files:**
- Create: `lib/core/validation/rule_lookup.dart`
- Test: `test/core/validation/rule_lookup_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/rule_lookup_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/raw_regex_rule.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule_lookup.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule_registry.dart';

import '_fixtures/seeded_validations.dart';

void main() {
  final byId = RuleRegistry.rulesForTest;

  test('tier 1: ID match wins when id is in the registry', () {
    final hit = RuleLookup.resolve(vNumber, byId);
    expect(hit, isNotNull);
    expect(hit!.id, 1);
  });

  test('tier 2: fingerprint match when id is unknown but regex is known', () {
    final unknownId = Validation(
      id: 9999,
      type: ValidationType.questions,
      validation: vNumber.validation,
      enTitle: 'shifted by reseed',
      arTitle: 'shifted by reseed',
      enContent: 'x',
      arContent: 'x',
    );
    final hit = RuleLookup.resolve(unknownId, byId);
    expect(hit, isNotNull);
    expect(hit!.id, 1); // Fingerprint routed to Number (id 1).
  });

  test('tier 3: RawRegexRule when neither id nor fingerprint matches', () {
    final unknown = Validation(
      id: 9999,
      type: ValidationType.questions,
      validation: r'^xyzzy$',
      enTitle: 'unknown',
      arTitle: 'unknown',
    );
    final hit = RuleLookup.resolve(unknown, byId);
    expect(hit, isA<RawRegexRule>());
  });

  test('returns null when everything is unusable', () {
    final empty = Validation(
      id: 9999,
      type: ValidationType.questions,
      validation: null,
      enTitle: 'empty',
      arTitle: 'empty',
    );
    final hit = RuleLookup.resolve(empty, byId);
    expect(hit, null);
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/rule_lookup_test.dart`
Expected: FAIL — `rule_lookup.dart` does not exist, `RuleRegistry.rulesForTest` unresolved.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/rule_lookup.dart
import 'package:flutter/foundation.dart';

import '../models/survey/validation_model.dart';
import 'raw_regex_rule.dart';
import 'regex_fingerprint.dart';
import 'rule.dart';

/// Three-tier dispatch chain: id → fingerprint → raw regex.
class RuleLookup {
  static Rule? resolve(Validation v, Map<int, Rule> byId) {
    final byIdHit = byId[v.id];
    if (byIdHit != null) return byIdHit;

    final byFp = RegexFingerprint.match(v.validation, byId);
    if (byFp != null) {
      _log('fingerprint', v);
      return byFp;
    }

    if ((v.validation ?? '').isNotEmpty) {
      _log('raw-regex', v);
      return RawRegexRule(v);
    }

    _log('unhandled', v);
    return null;
  }

  static void _log(String tier, Validation v) {
    debugPrint(
      '[ValidationFallback] tier=$tier id=${v.id} title="${v.enTitle}"',
    );
  }
}
```

- [ ] **Step 4: Run the test and confirm it passes**

(Rule registry isn't built yet, so add a temporary `rulesForTest` getter in Task 20.)

This task's test currently depends on Task 20 being done. **Run tests only after Task 20 completes.** The commit for this task is still OK — the source compiles standalone.

Run: `flutter analyze lib/core/validation/rule_lookup.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/rule_lookup.dart test/core/validation/rule_lookup_test.dart
git commit -m "feat(validation): add RuleLookup three-tier dispatch chain

Tier 1 id match, tier 2 regex fingerprint, tier 3 RawRegexRule.
Logs every fallback via debugPrint with tier + id + title.
Tests depend on RuleRegistry (next task)."
```

---

### Task 20: `RuleRegistry`

**Files:**
- Create: `lib/core/validation/rule_registry.dart`
- Test: `test/core/validation/rule_registry_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/rule_registry_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule_registry.dart';

import '_fixtures/seeded_validations.dart';

Question _q({required List<QuestionValidation> qvs}) => Question(
      id: 1,
      type: QuestionType.textShort,
      label: 'q',
      questionValidations: qvs,
    );

void main() {
  group('validateAll', () {
    test('passes when value satisfies all rules', () {
      final q = _q(qvs: [
        QuestionValidation(id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
      ]);
      final errs = RuleRegistry.validateAll(
        question: q, normalizedValue: '42', locale: 'en',
      );
      expect(errs, isEmpty);
    });

    test('returns message from arContent when locale ar', () {
      final q = _q(qvs: [
        QuestionValidation(id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
      ]);
      final errs = RuleRegistry.validateAll(
        question: q, normalizedValue: 'abc', locale: 'ar',
      );
      expect(errs, contains(vNumber.arContent));
    });

    test('skips rules with isActive=false', () {
      final disabled = Validation(
        id: vNumber.id, type: ValidationType.questions,
        validation: vNumber.validation,
        enTitle: vNumber.enTitle, arTitle: vNumber.arTitle,
        enContent: vNumber.enContent, arContent: vNumber.arContent,
        isActive: false,
      );
      final q = _q(qvs: [
        QuestionValidation(id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: disabled),
      ]);
      final errs = RuleRegistry.validateAll(
        question: q, normalizedValue: 'abc', locale: 'en',
      );
      expect(errs, isEmpty);
    });

    test('collects multiple errors in attachment order', () {
      final q = _q(qvs: [
        QuestionValidation(id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
        QuestionValidation(id: 2, questionId: 1, validationId: 6,
            values: const {'min': 10}, validation: vMinLength),
      ]);
      final errs = RuleRegistry.validateAll(
        question: q, normalizedValue: 'abc', locale: 'en',
      );
      expect(errs.length, 2);
      expect(errs[0], contains('Value must be a number'));
    });
  });

  group('formattersFor', () {
    test('returns formatters from matching rules, deduped', () {
      final q = _q(qvs: [
        QuestionValidation(id: 1, questionId: 1, validationId: 7,
            values: const {'max': 5}, validation: vMaxLength),
        QuestionValidation(id: 2, questionId: 1, validationId: 8,
            values: const {'min': 1, 'max': 3}, validation: vLengthRange),
      ]);
      final fs = RuleRegistry.formattersFor(q);
      // Both rules install LengthLimitingTextInputFormatter; dedupe keeps
      // the smaller cap (3).
      expect(fs.length, 1);
    });

    test('returns empty for question with no validations', () {
      final q = Question(id: 1, type: QuestionType.textShort, label: 'q');
      expect(RuleRegistry.formattersFor(q), isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/rule_registry_test.dart`
Expected: FAIL — `rule_registry.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/rule_registry.dart
import 'package:flutter/services.dart';

import '../models/survey/question_model.dart';
import '../models/survey/validation_model.dart';
import 'rule.dart';
import 'rule_lookup.dart';
import 'rules/alphanumeric_rules.dart';
import 'rules/format_rules.dart';
import 'rules/length_rules.dart';
import 'rules/letter_rules.dart';
import 'rules/number_rules.dart';
import 'rules/password_rules.dart';
import 'rules/script_rules.dart';
import 'rules/value_range_rules.dart';

class RuleRegistry {
  static final Map<int, Rule> _byId = {
    1: NumberRule(),
    2: PositiveNumberRule(),
    3: IntegerRule(),
    4: DecimalNumberRule(),
    5: Decimal2PlacesRule(),
    6: MinLengthRule(),
    7: MaxLengthRule(),
    8: LengthRangeRule(),
    9: MinLettersRule(),
    10: MaxLettersRule(),
    11: LettersOnlyRule(),
    12: LettersAndSpacesRule(),
    13: AlphanumericRule(),
    14: AlphanumericWithSpacesRule(),
    15: EmailRule(),
    16: UrlRule(),
    17: NoSpacesRule(),
    18: NoSpecialCharsRule(),
    19: MinValueRule(),
    20: MaxValueRule(),
    21: ValueRangeRule(),
    22: ArabicOnlyRule(),
    23: EnglishOnlyRule(),
    24: MinEightCharsRule(),
    25: StrongPasswordRule(),
  };

  /// Exposed for tests; production code should go through [lookup].
  static Map<int, Rule> get rulesForTest => _byId;

  static Rule? lookup(Validation v) => RuleLookup.resolve(v, _byId);

  static List<String> validateAll({
    required Question question,
    required String normalizedValue,
    required String locale,
  }) {
    final errors = <String>[];
    final qvs = question.questionValidations ?? const [];
    for (final qv in qvs) {
      final v = qv.validation;
      if (v == null || v.isActive == false) continue;
      final rule = lookup(v);
      if (rule == null) continue;
      final r = rule.validate(
        value: normalizedValue,
        params: qv.values,
        validation: v,
        locale: locale,
      );
      if (!r.isValid && r.message != null) errors.add(r.message!);
    }
    return errors;
  }

  static List<TextInputFormatter> formattersFor(Question q) {
    final out = <TextInputFormatter>[];
    final qvs = q.questionValidations ?? const [];
    for (final qv in qvs) {
      final v = qv.validation;
      if (v == null || v.isActive == false) continue;
      final rule = lookup(v);
      if (rule != null && rule.appliesToTextInput) {
        out.addAll(rule.formatters(qv.values));
      }
    }
    return _dedupe(out);
  }

  /// Collapses multiple `LengthLimitingTextInputFormatter`s into one (smallest
  /// cap wins). Other formatter types pass through unchanged.
  static List<TextInputFormatter> _dedupe(List<TextInputFormatter> input) {
    LengthLimitingTextInputFormatter? smallest;
    final others = <TextInputFormatter>[];
    for (final f in input) {
      if (f is LengthLimitingTextInputFormatter) {
        if (smallest == null ||
            (f.maxLength != null &&
                smallest!.maxLength != null &&
                f.maxLength! < smallest!.maxLength!)) {
          smallest = f;
        }
      } else {
        others.add(f);
      }
    }
    return [...others, if (smallest != null) smallest!];
  }
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/rule_registry_test.dart`
Expected: All 6 tests PASS.

Run also: `flutter test test/core/validation/rule_lookup_test.dart test/core/validation/regex_fingerprint_test.dart`
Expected: All tier tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/rule_registry.dart test/core/validation/rule_registry_test.dart
git commit -m "feat(validation): add RuleRegistry

Wires 25 Rule instances by id; provides validateAll() for the
SurveyValidator wrapper and formattersFor() for widget input-formatter
composition. _dedupe collapses multiple LengthLimitingTextInputFormatters
to the smallest cap."
```

---

## Phase 5 — Validator wiring

### Task 21: Refactor `SurveyValidator.validateQuestion` to delegate

**Files:**
- Modify: `lib/core/utils/survey_validator.dart`

Public signature preserved. Body shrinks from ~150 lines to ~20, delegating to `RuleRegistry`. `isValueEmpty`, `sanitizeValue`, `validatePhone`, and `_normalizeValue` are untouched.

- [ ] **Step 1: Verify the existing bloc test still passes on main**

Run: `flutter test test/features/public_links/public_link_answering_bloc_test.dart`
Expected: All existing tests PASS. Record the count — should match after refactor.

- [ ] **Step 2: Rewrite `validateQuestion`**

Replace the body of `SurveyValidator.validateQuestion` in `lib/core/utils/survey_validator.dart` with:

```dart
import '../validation/rule_registry.dart';
// ... existing imports

class SurveyValidator {
  /// Validates a question value against its validation rules.
  /// Returns a list of error messages. If empty, validation passed.
  static List<String> validateQuestion({
    required Question question,
    required dynamic value,
    required String locale,
    bool isRequired = false,
  }) {
    final valueStr = _normalizeValue(value);
    if (!isRequired && valueStr.isEmpty) return const [];

    final errors = RuleRegistry.validateAll(
      question: question,
      normalizedValue: valueStr,
      locale: locale,
    );

    if (question.type == QuestionType.phoneNumber) {
      final phoneErr = validatePhone(valueStr, locale: locale);
      if (phoneErr != null) errors.add(phoneErr);
    }

    return errors;
  }

  // _toInt, _toDouble, _replacePlaceholders are no longer used here; they
  // moved into param_helpers.dart. Keep them only if other callers reference
  // them (check with: git grep -E '_toInt\\(|_toDouble\\(|_replacePlaceholders')
  // ...rest of SurveyValidator unchanged: isValueEmpty, sanitizeValue,
  // validatePhone, _normalizeValue stay as-is.
}
```

Remove `_toInt`, `_toDouble`, `_replacePlaceholders` if no other callers exist. Keep everything else.

- [ ] **Step 3: Run the same bloc test**

Run: `flutter test test/features/public_links/public_link_answering_bloc_test.dart`
Expected: All tests PASS — same count as Step 1. This is the contract check.

- [ ] **Step 4: Run the full suite**

Run: `flutter test`
Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/utils/survey_validator.dart
git commit -m "refactor(validation): delegate validateQuestion to RuleRegistry

SurveyValidator.validateQuestion now runs the input through _normalizeValue,
early-returns on empty-and-not-required, then delegates to RuleRegistry.
Phone validation stays as-is (QuestionType-driven, not in the registry).

Public signature preserved. Bloc and bloc-tests untouched."
```

---

## Phase 6 — Live controller

### Task 22: `LiveValidationController`

**Files:**
- Create: `lib/core/validation/live_validation_controller.dart`
- Test: `test/core/validation/live_validation_controller_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/validation/live_validation_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/live_validation_controller.dart';

import 'rules/../_fixtures/seeded_validations.dart';

Question _required({required List<QuestionValidation> qvs}) => Question(
      id: 1,
      type: QuestionType.textShort,
      label: 'q',
      isRequired: true,
      questionValidations: qvs,
    );

void main() {
  testWidgets('error is null on pristine field', (tester) async {
    final c = LiveValidationController(
      question: _required(qvs: [
        QuestionValidation(
            id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
      ]),
      locale: 'en',
    );
    addTearDown(c.dispose);
    expect(c.error, null);
  });

  testWidgets('error appears after onChanged + debounce', (tester) async {
    final c = LiveValidationController(
      question: _required(qvs: [
        QuestionValidation(
            id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
      ]),
      locale: 'en',
      debounce: const Duration(milliseconds: 50),
    );
    addTearDown(c.dispose);

    c.onChanged('abc');
    await tester.pump(const Duration(milliseconds: 60));
    expect(c.error, isNotNull);
  });

  testWidgets('onBlur flushes the debounce immediately', (tester) async {
    final c = LiveValidationController(
      question: _required(qvs: [
        QuestionValidation(
            id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
      ]),
      locale: 'en',
      debounce: const Duration(seconds: 10),
    );
    addTearDown(c.dispose);

    c.onChanged('abc');
    c.onBlur('abc');
    await tester.pump();
    expect(c.error, isNotNull);
  });

  testWidgets('markSubmitAttempted alone does not fabricate an error', (tester) async {
    // The controller only reports errors the validator actually produced.
    // Required-empty is the bloc's concern (flows via errorText), not the
    // controller's. markSubmitAttempted just unlocks the _dirty gate so a
    // previously cached error can render.
    final c = LiveValidationController(
      question: _required(qvs: const []),
      locale: 'en',
    );
    addTearDown(c.dispose);

    expect(c.error, null);
    c.markSubmitAttempted();
    await tester.pump();
    expect(c.error, null);
  });

  testWidgets('markSubmitAttempted lets a previously cached error render', (tester) async {
    // Simulate: user types invalid input → error cached → widget rebuilds →
    // an intervening state change would normally gate the display. Direct
    // path: dirty it first, get an error, then markSubmitAttempted is a no-op
    // because _dirty is already true — but the test locks down that the
    // error survives.
    final c = LiveValidationController(
      question: _required(qvs: [
        QuestionValidation(
            id: 1, questionId: 1, validationId: 1,
            values: const {}, validation: vNumber),
      ]),
      locale: 'en',
      debounce: const Duration(milliseconds: 50),
    );
    addTearDown(c.dispose);

    c.onChanged('abc');
    await tester.pump(const Duration(milliseconds: 60));
    expect(c.error, isNotNull);

    c.markSubmitAttempted();
    await tester.pump();
    expect(c.error, isNotNull);
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/validation/live_validation_controller_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/core/validation/live_validation_controller.dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/survey/question_model.dart';
import '../utils/survey_validator.dart';

/// Per-question debounced validator + error stream.
///
/// Owned by `SurveyQuestionRenderer`. One instance per visible question.
/// Emits via [ChangeNotifier] so widgets can rebuild only their error text.
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

  /// Current error text. Null on pristine fields or when validation passes.
  /// Gated by `_dirty || _submitAttempted` so pristine screens aren't red.
  String? get error => (_dirty || _submitAttempted) ? _error : null;

  void onChanged(dynamic value) {
    _dirty = true;
    _timer?.cancel();
    _timer = Timer(_debounce, () => _evaluate(value));
  }

  void onBlur(dynamic value) {
    _timer?.cancel();
    _evaluate(value);
  }

  void markSubmitAttempted() {
    _submitAttempted = true;
    notifyListeners();
  }

  void _evaluate(dynamic value) {
    final errors = SurveyValidator.validateQuestion(
      question: question,
      value: value,
      locale: locale,
      isRequired: question.isRequired,
    );
    final next = errors.isEmpty ? null : errors.first;
    if (next != _error) {
      _error = next;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/validation/live_validation_controller_test.dart`
Expected: All 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validation/live_validation_controller.dart test/core/validation/live_validation_controller_test.dart
git commit -m "feat(validation): add LiveValidationController

Per-question debounced validator (ChangeNotifier). Gates error display
on _dirty (first user edit) || _submitAttempted (bloc submit attempted).
onBlur flushes the debounce timer immediately."
```

---

## Phase 7 — Widget integration

### Task 23: `CustomTextField` gains `inputFormatters` param

**Files:**
- Modify: `lib/core/widgets/custom_text_field.dart`

- [ ] **Step 1: Add the parameter**

Edit `lib/core/widgets/custom_text_field.dart` to add `inputFormatters` to the widget:

In the class declaration (after `suffixIcon`):

```dart
  final List<TextInputFormatter>? inputFormatters;
```

In the constructor parameters (after `suffixIcon: ...`):

```dart
    this.inputFormatters,
```

In the `TextFormField(...)` (after `onChanged: widget.onChanged,`):

```dart
    inputFormatters: widget.inputFormatters,
```

And add the import at the top:

```dart
import 'package:flutter/services.dart';
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/core/widgets/custom_text_field.dart`
Expected: `No issues found!`

- [ ] **Step 3: Run the full test suite (regression)**

Run: `flutter test`
Expected: All existing tests PASS (param is optional — nothing else changed).

- [ ] **Step 4: Commit**

```bash
git add lib/core/widgets/custom_text_field.dart
git commit -m "feat(ui): CustomTextField accepts optional inputFormatters

Passed straight to TextFormField.inputFormatters. Additive — all
existing callsites unaffected."
```

---

### Task 24: `SurveyTextField` wires formatters + live controller

**Files:**
- Modify: `lib/core/widgets/survey/survey_text_field.dart`
- Test: `test/core/widgets/survey/survey_text_field_formatter_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
// test/core/widgets/survey/survey_text_field_formatter_test.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/input_formatters/char_whitelist_formatter.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  testWidgets('inputFormatter blocks disallowed characters', (tester) async {
    String? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: ScreenUtilInit(
          designSize: const Size(375, 812),
          child: Scaffold(
            body: SurveyTextField(
              question: Question(id: 1, type: QuestionType.textShort, label: 'q'),
              inputFormatters: [CharWhitelistFormatter(RegExp('[a-zA-Z]'))],
              onChanged: (v) => captured = v,
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'abc123');
    expect(captured, 'abc');
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/widgets/survey/survey_text_field_formatter_test.dart`
Expected: FAIL — `SurveyTextField` does not accept `inputFormatters`.

- [ ] **Step 3: Modify `SurveyTextField`**

Replace `lib/core/widgets/survey/survey_text_field.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/survey/question_model.dart';
import '../../validation/live_validation_controller.dart';
import '../custom_text_field.dart';
import 'survey_question_card.dart';

class SurveyTextField extends StatefulWidget {
  final Question question;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isLongText;
  final bool isEditable;
  final List<TextInputFormatter>? inputFormatters;
  final LiveValidationController? validationController;

  const SurveyTextField({
    super.key,
    required this.question,
    this.value,
    this.onChanged,
    this.errorText,
    this.isVisible = true,
    this.isLongText = false,
    this.isEditable = true,
    this.inputFormatters,
    this.validationController,
  });

  @override
  State<SurveyTextField> createState() => _SurveyTextFieldState();
}

class _SurveyTextFieldState extends State<SurveyTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.validationController?.onBlur(_controller.text);
    }
  }

  @override
  void didUpdateWidget(SurveyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String v) {
    widget.onChanged?.call(v);
    widget.validationController?.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return SurveyQuestionCard(
      label: widget.question.label,
      helpText: widget.question.helpText,
      isRequired: widget.question.isRequired,
      errorText: widget.errorText,
      isVisible: widget.isVisible,
      validations: widget.question.questionValidations,
      liveController: widget.validationController,
      child: Focus(
        focusNode: _focusNode,
        child: CustomTextField(
          controller: _controller,
          label: null,
          hintText: widget.question.helpText,
          onChanged: widget.isEditable ? _handleChanged : null,
          enabled: widget.isEditable,
          inputFormatters: widget.inputFormatters,
          keyboardType: widget.isLongText
              ? TextInputType.multiline
              : TextInputType.text,
        ),
      ),
    );
  }
}
```

Note: `SurveyQuestionCard` gets a new `liveController` param — added in Task 26. This task's compile will fail until Task 26 lands, so the test runs in the order Task 23 → 26 → 24.

**Reorder:** Do Task 26 (`SurveyQuestionCard`) before Task 24. Skip to Task 26 now and come back.

Once Task 26 is committed, come back here and run:

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/widgets/survey/survey_text_field_formatter_test.dart`
Expected: All 1 test PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/survey/survey_text_field.dart test/core/widgets/survey/survey_text_field_formatter_test.dart
git commit -m "feat(ui): SurveyTextField accepts inputFormatters + validationController

Optional params. onChanged forwards to both the existing callback and
the live controller. Focus loss flushes the controller's debounce."
```

---

### Task 25: `SurveyNumberField` wires formatters + live controller

**Files:**
- Modify: `lib/core/widgets/survey/survey_number_field.dart`

Same pattern as Task 24. No new test — widget shape is identical to SurveyTextField for formatter purposes.

- [ ] **Step 1: Modify `SurveyNumberField`**

Replace `lib/core/widgets/survey/survey_number_field.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/survey/question_model.dart';
import '../../validation/live_validation_controller.dart';
import '../custom_text_field.dart';
import 'survey_question_card.dart';

class SurveyNumberField extends StatefulWidget {
  final Question question;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;
  final List<TextInputFormatter>? inputFormatters;
  final LiveValidationController? validationController;

  const SurveyNumberField({
    super.key,
    required this.question,
    this.value,
    this.onChanged,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
    this.inputFormatters,
    this.validationController,
  });

  @override
  State<SurveyNumberField> createState() => _SurveyNumberFieldState();
}

class _SurveyNumberFieldState extends State<SurveyNumberField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.validationController?.onBlur(_controller.text);
    }
  }

  @override
  void didUpdateWidget(SurveyNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String v) {
    widget.onChanged?.call(v);
    widget.validationController?.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return SurveyQuestionCard(
      label: widget.question.label,
      helpText: widget.question.helpText,
      isRequired: widget.question.isRequired,
      errorText: widget.errorText,
      isVisible: widget.isVisible,
      validations: widget.question.questionValidations,
      liveController: widget.validationController,
      child: Focus(
        focusNode: _focusNode,
        child: CustomTextField(
          controller: _controller,
          label: null,
          hintText: widget.question.helpText,
          onChanged: widget.isEditable ? _handleChanged : null,
          enabled: widget.isEditable,
          inputFormatters: widget.inputFormatters,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run the full test suite**

Run: `flutter test`
Expected: All existing tests PASS.

- [ ] **Step 3: Commit**

```bash
git add lib/core/widgets/survey/survey_number_field.dart
git commit -m "feat(ui): SurveyNumberField accepts inputFormatters + validationController

Mirrors SurveyTextField. Optional params; defaults preserve existing
behavior."
```

---

### Task 26: `SurveyQuestionCard` wraps error in `ListenableBuilder`

**Files:**
- Modify: `lib/core/widgets/survey/survey_question_card.dart`
- Test: `test/core/widgets/survey/survey_question_card_live_error_test.dart`

**Do this task BEFORE Task 24 and Task 25 compile cleanly.**

- [ ] **Step 1: Write the failing widget test**

```dart
// test/core/widgets/survey/survey_question_card_live_error_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/live_validation_controller.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_question_card.dart';

import '../../../core/validation/_fixtures/seeded_validations.dart';

Widget _harness(Widget child) => MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  testWidgets('pristine field with controller — no error rendered', (tester) async {
    final q = Question(
      id: 1,
      type: QuestionType.textShort,
      label: 'q',
      isRequired: true,
      questionValidations: [
        QuestionValidation(
          id: 1,
          questionId: 1,
          validationId: 1,
          values: const {},
          validation: vNumber,
        ),
      ],
    );
    final c = LiveValidationController(question: q, locale: 'en');
    addTearDown(c.dispose);

    await tester.pumpWidget(_harness(SurveyQuestionCard(
      label: q.label,
      isRequired: q.isRequired,
      validations: q.questionValidations,
      liveController: c,
      child: const SizedBox(height: 40),
    )));

    expect(find.textContaining('Value must be a number'), findsNothing);
  });

  testWidgets('error renders after onChanged + debounce', (tester) async {
    final q = Question(
      id: 1,
      type: QuestionType.textShort,
      label: 'q',
      questionValidations: [
        QuestionValidation(
          id: 1, questionId: 1, validationId: 1,
          values: const {}, validation: vNumber,
        ),
      ],
    );
    final c = LiveValidationController(
      question: q, locale: 'en',
      debounce: const Duration(milliseconds: 50),
    );
    addTearDown(c.dispose);

    await tester.pumpWidget(_harness(SurveyQuestionCard(
      label: q.label,
      validations: q.questionValidations,
      liveController: c,
      child: const SizedBox(height: 40),
    )));

    c.onChanged('abc');
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    expect(find.textContaining('Value must be a number'), findsOneWidget);
  });

  testWidgets('errorText (from bloc) overrides live error', (tester) async {
    final q = Question(
      id: 1, type: QuestionType.textShort, label: 'q',
      questionValidations: [
        QuestionValidation(
          id: 1, questionId: 1, validationId: 1,
          values: const {}, validation: vNumber,
        ),
      ],
    );
    final c = LiveValidationController(
      question: q, locale: 'en',
      debounce: const Duration(milliseconds: 50),
    );
    addTearDown(c.dispose);

    await tester.pumpWidget(_harness(SurveyQuestionCard(
      label: q.label,
      errorText: 'BLOC-ERROR',
      validations: q.questionValidations,
      liveController: c,
      child: const SizedBox(height: 40),
    )));

    c.onChanged('abc');
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    // Bloc error wins.
    expect(find.text('BLOC-ERROR'), findsOneWidget);
    expect(find.textContaining('Value must be a number'), findsNothing);
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/core/widgets/survey/survey_question_card_live_error_test.dart`
Expected: FAIL — `SurveyQuestionCard` has no `liveController` param.

- [ ] **Step 3: Modify `SurveyQuestionCard`**

Add the param and wrap the error slot. Replace the relevant portions of `lib/core/widgets/survey/survey_question_card.dart`:

Add import:

```dart
import '../../validation/live_validation_controller.dart';
```

Extend the class:

```dart
class SurveyQuestionCard extends StatelessWidget {
  // ...existing fields...
  final LiveValidationController? liveController;

  const SurveyQuestionCard({
    super.key,
    this.label,
    this.helpText,
    this.isRequired = false,
    required this.child,
    this.errorText,
    this.isVisible = true,
    this.validations,
    this.liveController,
  });
  // ...
```

Replace the `if (errorText != null) ...[` block (lines 145-155) with:

```dart
          if (liveController != null || errorText != null)
            ListenableBuilder(
              listenable: liveController ?? const _AlwaysNotifier(),
              builder: (_, __) {
                final shown = errorText ?? liveController?.error;
                if (shown == null) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    shown,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(11.sp),
                      color: AppColors.destructive,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
```

Add a trailing helper at file end:

```dart
class _AlwaysNotifier extends Listenable {
  const _AlwaysNotifier();
  @override
  void addListener(VoidCallback _) {}
  @override
  void removeListener(VoidCallback _) {}
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/core/widgets/survey/survey_question_card_live_error_test.dart`
Expected: All 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/survey/survey_question_card.dart test/core/widgets/survey/survey_question_card_live_error_test.dart
git commit -m "feat(ui): SurveyQuestionCard supports live error via LiveValidationController

Optional liveController param wires a ListenableBuilder around the
error slot so keystroke-driven errors rebuild just the error text.
errorText (bloc-driven, authoritative) wins when present."
```

---

### Task 27: `SurveyQuestionRenderer` owns controller map

**Files:**
- Modify: `lib/core/widgets/survey/survey_question_renderer.dart`

- [ ] **Step 1: Read the current renderer to understand its shape**

Run: `wc -l lib/core/widgets/survey/survey_question_renderer.dart`
Expected: ~130 lines.

Open `lib/core/widgets/survey/survey_question_renderer.dart`. It currently dispatches on `question.type`; it's a `StatelessWidget` (or similar). Convert it to a `StatefulWidget` and add the controller map.

- [ ] **Step 2: Convert to stateful with controller map**

Add the following near the top imports:

```dart
import '../../validation/live_validation_controller.dart';
import '../../validation/rule_registry.dart';
```

Convert the class signature. If it was:

```dart
class SurveyQuestionRenderer extends StatelessWidget { ... }
```

it becomes:

```dart
class SurveyQuestionRenderer extends StatefulWidget {
  const SurveyQuestionRenderer({
    super.key,
    required this.question,
    // ... keep existing params exactly
  });

  final Question question;
  // ... keep existing fields exactly

  @override
  State<SurveyQuestionRenderer> createState() => _SurveyQuestionRendererState();
}

class _SurveyQuestionRendererState extends State<SurveyQuestionRenderer> {
  final Map<int, LiveValidationController> _controllers = {};

  LiveValidationController _controllerFor(Question q) => _controllers.putIfAbsent(
        q.id,
        () => LiveValidationController(
          question: q,
          locale: Localizations.localeOf(context).languageCode,
        ),
      );

  @override
  void dispose() {
    for (final c in _controllers.values) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    // ...copy-paste the existing build body from the StatelessWidget here,
    //   referencing widget.<field> instead of bare fields.
    // ...for the QuestionType.textShort / textLong / number branches only,
    //   add the two new args:
    //     inputFormatters: RuleRegistry.formattersFor(q),
    //     validationController: _controllerFor(q),
  }
}
```

For each of the three text-input branches (`textShort`, `textLong`, `number`), inject the new args into the widget constructor. Example for `textShort`:

```dart
case QuestionType.textShort:
  return SurveyTextField(
    question: q,
    value: widget.value as String?,
    onChanged: widget.onChanged == null ? null : (v) => widget.onChanged!(v),
    errorText: widget.errorText,
    isVisible: widget.isVisible,
    isEditable: widget.isEditable,
    inputFormatters: RuleRegistry.formattersFor(q),
    validationController: _controllerFor(q),
  );
```

(Keep existing branch args exactly as they were; add only the two new ones.)

- [ ] **Step 3: Run the full test suite**

Run: `flutter test`
Expected: All existing tests PASS. No new tests for the renderer (widget tree wiring is covered by Tasks 24/26 in isolation).

- [ ] **Step 4: Commit**

```bash
git add lib/core/widgets/survey/survey_question_renderer.dart
git commit -m "feat(ui): SurveyQuestionRenderer owns a LiveValidationController map

One controller per visible text-input question, keyed by question.id.
Created on first render via putIfAbsent, disposed with the renderer.
Text/number branches now pass formatters + controller to their fields."
```

---

### Task 28: Bloc emits a submit-attempt signal

**Files:**
- Modify: `lib/features/public_links/bloc/answering/public_link_answering_state.dart`
- Modify: `lib/features/public_links/bloc/answering/public_link_answering_bloc.dart`
- Modify: `lib/core/widgets/survey/survey_question_renderer.dart`

The renderer needs to know when the user tapped Next so it can flip `markSubmitAttempted()` on every controller. Simplest contract: a monotonic counter on the emitted state.

- [ ] **Step 1: Add `submitAttemptCount` to the state**

Open `lib/features/public_links/bloc/answering/public_link_answering_state.dart`. Find the state class (likely `PublicLinkAnsweringState` with `copyWith`). Add:

```dart
final int submitAttemptCount;
```

Add to constructor / default to 0 / add to `copyWith` / add to `props` (if `Equatable`). Example:

```dart
const PublicLinkAnsweringState({
  // ...existing fields,
  this.submitAttemptCount = 0,
});

PublicLinkAnsweringState copyWith({
  // ...existing,
  int? submitAttemptCount,
}) =>
    PublicLinkAnsweringState(
      // ...existing,
      submitAttemptCount: submitAttemptCount ?? this.submitAttemptCount,
    );

@override
List<Object?> get props => [..., submitAttemptCount];
```

- [ ] **Step 2: Increment on submit**

In `lib/features/public_links/bloc/answering/public_link_answering_bloc.dart`, find the `SubmitCurrentSection` handler at line 129. Immediately after the event is received (before doing any validation work), emit a state that increments the counter:

```dart
on<SubmitCurrentSection>((event, emit) async {
  emit(state.copyWith(submitAttemptCount: state.submitAttemptCount + 1));
  // ...rest of the existing handler body unchanged...
});
```

This is the ONLY bloc logic change.

- [ ] **Step 3: Wire into the renderer**

In `lib/core/widgets/survey/survey_question_renderer.dart` (Task 27 converted it to Stateful), add a `didUpdateWidget` hook that watches for `submitAttemptCount` changing:

Add a field:

```dart
int _lastSubmitAttempt = 0;
```

Add a new param to the widget:

```dart
final int submitAttemptCount;
```

(Plumb it in from wherever the renderer is constructed — typically a `BlocBuilder` that already has access to `state`; just pass `state.submitAttemptCount`.)

Add:

```dart
@override
void didUpdateWidget(SurveyQuestionRenderer oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.submitAttemptCount != _lastSubmitAttempt) {
    _lastSubmitAttempt = widget.submitAttemptCount;
    for (final c in _controllers.values) {
      c.markSubmitAttempted();
    }
  }
}
```

Plumb `submitAttemptCount: state.submitAttemptCount` at the renderer's callsite (likely in the public-link answering screen — find with grep if unsure).

- [ ] **Step 4: Find and update the callsite(s)**

Run: `git grep -l 'SurveyQuestionRenderer('`
Add `submitAttemptCount: state.submitAttemptCount` (or the equivalent BLoC state accessor) to every callsite.

- [ ] **Step 5: Run the full test suite**

Run: `flutter test`
Expected: All tests PASS. The existing bloc-test expectations still match because `submitAttemptCount` is a new field that defaults to 0 and just increments — the `errors` map emission behavior is identical.

- [ ] **Step 6: Commit**

```bash
git add lib/features/public_links/bloc/answering/public_link_answering_state.dart \
        lib/features/public_links/bloc/answering/public_link_answering_bloc.dart \
        lib/core/widgets/survey/survey_question_renderer.dart
git commit -m "feat(ui): propagate submit-attempt signal to live controllers

Bloc emits a monotonic submitAttemptCount on every SubmitCurrentSection.
Renderer watches it in didUpdateWidget and calls markSubmitAttempted()
on every live controller so required-empty fields reveal their error
after the user taps Next."
```

---

## Phase 8 — Regression coverage

### Task 29: Add bloc regression expectations

**Files:**
- Modify: `test/features/public_links/public_link_answering_bloc_test.dart`

**No changes to existing tests.** Only two new `blocTest`s that lock in the behaviors that tier-1 dispatch now produces.

- [ ] **Step 1: Read the existing test for the setup pattern**

Run: `wc -l test/features/public_links/public_link_answering_bloc_test.dart`

Open and identify the pattern used for `blocTest` — typically `bootstrap` / `wire` helpers, the fake submitter, and an `emitsSection` helper. Reuse them.

- [ ] **Step 2: Add two new tests**

At the bottom of the `main()` block, add:

```dart
group('validation: new registry behaviour', () {
  final _minLengthQuestion = Question(
    id: 7,
    type: QuestionType.textShort,
    label: 'Name',
    isRequired: true,
    questionValidations: [
      QuestionValidation(
        id: 1, questionId: 7, validationId: 6,
        values: const {'min': 5},
        validation: Validation(
          id: 6, type: ValidationType.questions,
          validation: r'^.{min,}$',
          enTitle: 'Minimum Length', arTitle: 'الحد الأدنى للمحارف',
          enContent: 'Value must have a minimum number of characters',
          arContent: 'يجب أن تحتوي القيمة على الحد الأدنى من المحارف',
          needsValue: true, isActive: true,
        ),
      ),
    ],
  );

  final _sectionMinLength = Section(
    id: 11, title: 'Section MinLength', questions: [_minLengthQuestion],
  );
  final _startMinLength = PublicLinkStartResult(
    responseId: 100, firstSection: _sectionMinLength, conditionalLogics: [],
  );

  blocTest<PublicLinkAnsweringBloc, PublicLinkAnsweringState>(
    'min-length violation produces arContent-based error at submit time',
    build: () {
      // Use the existing bootstrap helpers from earlier in this file.
      return bootstrapBloc(start: _startMinLength);
    },
    act: (b) {
      b.add(UpdateAnswer(questionId: 7, value: 'abc'));
      b.add(SubmitCurrentSection());
    },
    expect: () => [
      // First state: user input captured. (Match existing shape.)
      isA<PublicLinkAnsweringState>(),
      // Second state: submit attempt counter bumps.
      predicate<PublicLinkAnsweringState>(
        (s) => s.submitAttemptCount == 1,
        'submitAttemptCount should be 1 after first submit',
      ),
      // Third state: errors populated with arContent message (+ appended bound).
      predicate<PublicLinkAnsweringState>(
        (s) => s.errors[7]?.contains('الحد الأدنى') == true,
        'error for q7 should come from backend arContent',
      ),
    ],
  );

  blocTest<PublicLinkAnsweringBloc, PublicLinkAnsweringState>(
    'required-empty submit surfaces field_required',
    build: () => bootstrapBloc(start: _startMinLength),
    act: (b) => b.add(SubmitCurrentSection()),
    expect: () => [
      predicate<PublicLinkAnsweringState>(
        (s) => s.submitAttemptCount == 1,
        'submitAttemptCount should be 1',
      ),
      predicate<PublicLinkAnsweringState>(
        (s) => s.errors[7] != null,
        'q7 should have a required error',
      ),
    ],
  );
});
```

(If the existing test file uses different helpers — e.g. no `bootstrapBloc` — adapt to match. The key points: build with a section containing a min-length-validated question; submit empty or short; assert the new `submitAttemptCount` field increments and `errors` matches.)

- [ ] **Step 3: Run the bloc test file**

Run: `flutter test test/features/public_links/public_link_answering_bloc_test.dart`
Expected: All tests PASS — including the two new ones.

- [ ] **Step 4: Run the full suite**

Run: `flutter test`
Expected: All tests PASS across the repo.

- [ ] **Step 5: Commit**

```bash
git add test/features/public_links/public_link_answering_bloc_test.dart
git commit -m "test(public_links): assert registry dispatch + submit-attempt counter

Two new blocTests: min-length violation produces a backend-sourced
Arabic error with the bound appended; required-empty submit still
emits field_required. submitAttemptCount increments on each submit.
Existing tests unchanged."
```

---

## Final Verification

After Task 29 is committed:

- [ ] **Run the full test suite**

Run: `flutter test`
Expected: All tests PASS across all files.

- [ ] **Analyze the whole repo**

Run: `flutter analyze`
Expected: No issues.

- [ ] **Smoke-run a build**

Run: `flutter build apk --debug` (or on whichever platform is easiest)
Expected: Build succeeds.

- [ ] **Manual smoke test**

Launch the app, open a public survey, pick a section with:
- A text question with a min-length rule → type 1-2 chars, wait ~400ms, confirm error appears under the field.
- A "Letters Only" question → try to type digits, confirm the keyboard drops them.
- A "Decimal (2 places)" question → try to type a 3rd decimal digit, confirm it's dropped.
- A required field → tap Next without filling it, confirm error appears.

If all four behaviors match expectation, ship it.

---

## Summary

**29 tasks. Expected total time: 6–10 hours for a skilled Flutter dev.**

**Tier-1 correctness:** 25 rules in the registry, backed by the seeded fixture and 72 unit tests (3+ per rule).

**Tier-2 correctness:** RegexFingerprint covers every seeded pattern; drift between environments doesn't break dispatch.

**Tier-3 correctness:** `RawRegexRule` keeps validation working for an unknown future rule — with the existing placeholder substitution behavior preserved.

**UX correctness:** `LiveValidationController` surfaces errors only after user edit or submit attempt, debounced at 350ms, immediately on blur. Input formatters enforce hard caps where appropriate.

**Regression safety:** Bloc submit path untouched in logic (only adds a monotonic counter). Existing bloc tests unchanged; two new ones lock in the new arContent-sourced error path.
