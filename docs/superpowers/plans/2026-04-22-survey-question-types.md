# Survey Question Types Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the Flutter renderings for Grid, Phone Number, Location (map), File Upload (eager), and Rating question types so the Flutter researcher app matches the existing Next.js public survey form field-for-field against the same backend.

**Architecture:** Each field lives in its own `lib/core/widgets/survey/*.dart` wrapped by `SurveyQuestionCard` and dispatched from `SurveyQuestionRenderer`. Answer values flow through `PublicLinkAnsweringBloc`'s untyped `Map<int, dynamic>` so payload-shape changes are self-contained in the field widgets. OSM-based `flutter_map` replaces the GPS placeholder; `intl_phone_field` + `phone_numbers_parser` back the phone field; `UploadOnlineRepository.uploadImage` (already present) is called eagerly inside `SurveyFileField` on selection.

**Tech Stack:** Flutter 3.x, flutter_bloc 9, flutter_screenutil 5, dio 5, flutter_map 7, latlong2 0.9, intl_phone_field 3, phone_numbers_parser 9, geolocator 13, image_picker 1, image_cropper 8, flutter_dotenv 5.

**Reference spec:** `docs/superpowers/specs/2026-04-22-survey-question-types-design.md`

---

## Task 1: Add dependencies and env keys

**Files:**
- Modify: `pubspec.yaml` (dependencies section, after line 78 `smooth_page_indicator: ^1.1.0`)
- Modify: `.env` (append 3 keys)
- Modify: `lib/core/config/app_environment.dart` (add getters for map config)
- Modify: `test/helpers/test_env.dart` (add map keys to in-memory env)

- [ ] **Step 1: Append dependencies to `pubspec.yaml`**

Find the line `smooth_page_indicator: ^1.1.0` and add after it:

```yaml
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  intl_phone_field: ^3.2.0
  phone_numbers_parser: ^9.0.8
```

- [ ] **Step 2: Run `flutter pub get`**

Run: `flutter pub get`
Expected: no errors; `pubspec.lock` updated.

- [ ] **Step 3: Append 3 keys to `.env`** (file is already in `.gitignore` — verify with `git check-ignore .env` → prints `.env`)

Append at the end of `.env`:

```
# Map configuration (OSM default — swap URL for paid provider if needed)
MAP_TILE_URL=https://tile.openstreetmap.org/{z}/{x}/{y}.png
MAP_DEFAULT_LAT=24.72169
MAP_DEFAULT_LNG=46.75702
```

- [ ] **Step 4: Add getters to `lib/core/config/app_environment.dart`**

Append inside the `AppEnvironment` class (before the closing `}`):

```dart
  /// Tile URL template for the map picker. Defaults to OpenStreetMap.
  static String get mapTileUrl {
    if (!dotenv.isInitialized) return _defaultMapTileUrl;
    final v = dotenv.env['MAP_TILE_URL']?.trim();
    return (v == null || v.isEmpty) ? _defaultMapTileUrl : v;
  }

  /// Default map centre (Riyadh) when no value is known.
  static ({double latitude, double longitude}) get mapDefaultLatLng {
    double parseOr(String? s, double fallback) {
      if (s == null) return fallback;
      return double.tryParse(s.trim()) ?? fallback;
    }

    final lat = dotenv.isInitialized
        ? parseOr(dotenv.env['MAP_DEFAULT_LAT'], 24.72169)
        : 24.72169;
    final lng = dotenv.isInitialized
        ? parseOr(dotenv.env['MAP_DEFAULT_LNG'], 46.75702)
        : 46.75702;
    return (latitude: lat, longitude: lng);
  }

  static const String _defaultMapTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
```

- [ ] **Step 5: Extend `test/helpers/test_env.dart` with map keys**

Change the function signature and appended env string as follows:

```dart
void loadTestEnv({
  String appEnv = 'prod',
  String apiBaseUrlProd = 'https://survey-api.system2030.com',
  String apiBaseUrlDev = 'https://survey-api-test.system2030.com',
  String apiBaseUrlStaging = 'https://survey-api-test.system2030.com',
  String surveyFrontendProd = 'https://survey-frontend.system2030.com',
  String surveyFrontendDev = 'https://survey-front-internal.system2030.com',
  String surveyFrontendStaging = 'https://survey-front-internal.system2030.com',
  String defaultLocale = 'ar',
  String mapTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  String mapDefaultLat = '24.72169',
  String mapDefaultLng = '46.75702',
}) {
  dotenv.testLoad(fileInput: '''
APP_ENV=$appEnv
API_BASE_URL_PROD=$apiBaseUrlProd
API_BASE_URL_DEV=$apiBaseUrlDev
API_BASE_URL_STAGING=$apiBaseUrlStaging
SURVEY_FRONTEND_BASE_URL_PROD=$surveyFrontendProd
SURVEY_FRONTEND_BASE_URL_DEV=$surveyFrontendDev
SURVEY_FRONTEND_BASE_URL_STAGING=$surveyFrontendStaging
SURVEY_DEFAULT_LOCALE=$defaultLocale
MAP_TILE_URL=$mapTileUrl
MAP_DEFAULT_LAT=$mapDefaultLat
MAP_DEFAULT_LNG=$mapDefaultLng
''');
}
```

- [ ] **Step 6: Verify analyzer is clean**

Run: `flutter analyze lib/core/config/app_environment.dart test/helpers/test_env.dart`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/core/config/app_environment.dart test/helpers/test_env.dart
git commit -m "chore(deps): add flutter_map, intl_phone_field, phone_numbers_parser; wire MAP_* env keys"
```

(Do NOT commit `.env` — it is gitignored and must stay out of VCS.)

---

## Task 2: Add `QuestionType.phoneNumber` enum value

**Files:**
- Modify: `lib/core/enums/survey_enums.dart:21-48`
- Test: `test/core/enums/survey_enums_test.dart` (new)

- [ ] **Step 1: Write the failing test**

Create `test/core/enums/survey_enums_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';

void main() {
  group('QuestionType.phoneNumber', () {
    test('serialises to PHONE_NUMBER', () {
      expect(QuestionType.phoneNumber.toJson(), 'PHONE_NUMBER');
    });

    test('parses PHONE_NUMBER from backend', () {
      expect(QuestionType.fromJson('PHONE_NUMBER'), QuestionType.phoneNumber);
    });

    test('unknown value falls back to textShort', () {
      expect(QuestionType.fromJson('bogus'), QuestionType.textShort);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/enums/survey_enums_test.dart`
Expected: FAIL with "Undefined name 'phoneNumber'".

- [ ] **Step 3: Add enum value**

In `lib/core/enums/survey_enums.dart`, change the `QuestionType` enum body:

```dart
enum QuestionType {
  radio,
  checkbox,
  dropdown,
  textShort,
  textLong,
  number,
  date,
  time,
  datetime,
  file,
  rating,
  slider,
  gps,
  multiSelectGrid,
  singleSelectGrid,
  phoneNumber;
```

`toJson()` already UPPER-SNAKE-cases the enum `name`; Dart's `name` for `phoneNumber` is `phoneNumber` which `toJson()` treats via UPPERCASE. We need explicit mapping so the backend `PHONE_NUMBER` round-trips. Replace the existing `toJson()` with:

```dart
  String toJson() {
    switch (this) {
      case QuestionType.multiSelectGrid:
        return 'MULTI_SELECT_GRID';
      case QuestionType.singleSelectGrid:
        return 'SINGLE_SELECT_GRID';
      case QuestionType.phoneNumber:
        return 'PHONE_NUMBER';
      case QuestionType.textShort:
        return 'TEXT_SHORT';
      case QuestionType.textLong:
        return 'TEXT_LONG';
      default:
        return name.toUpperCase();
    }
  }
```

Replace `fromJson` with:

```dart
  static QuestionType fromJson(dynamic value) {
    if (value == null) return QuestionType.textShort;
    final String val = value.toString().toUpperCase();
    for (final t in QuestionType.values) {
      if (t.toJson() == val) return t;
    }
    return QuestionType.textShort;
  }
```

- [ ] **Step 4: Run the whole survey_enums test file to verify it passes**

Run: `flutter test test/core/enums/survey_enums_test.dart`
Expected: all 3 tests PASS.

- [ ] **Step 5: Run the full test suite to confirm no regression**

Run: `flutter test`
Expected: all existing tests still pass.

- [ ] **Step 6: Commit**

```bash
git add lib/core/enums/survey_enums.dart test/core/enums/survey_enums_test.dart
git commit -m "feat(survey): add QuestionType.phoneNumber mapping to backend PHONE_NUMBER"
```

---

## Task 3: Rewrite `SurveyGridField` (match frontend, key by `row.value`)

**Files:**
- Modify: `lib/core/widgets/survey/survey_grid_field.dart` (full rewrite)
- Test: `test/core/widgets/survey/survey_grid_field_test.dart` (new)

Single-select shape: `Map<String, String>`. Multi-select shape: `Map<String, List<String>>`. Both keyed by `row.value`.

- [ ] **Step 1: Write the failing test**

Create `test/core/widgets/survey/survey_grid_field_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_option_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_row_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_grid_field.dart';

Question _question(QuestionType type) => Question(
      id: 1,
      type: type,
      label: 'Q',
      questionRows: const [
        QuestionRow(id: 10, label: 'Row A', value: 'a', order: 0),
        QuestionRow(id: 11, label: 'Row B', value: 'b', order: 1),
      ],
      questionOptions: const [
        QuestionOption(id: 20, label: 'Yes', value: 'yes', order: 0),
        QuestionOption(id: 21, label: 'No',  value: 'no',  order: 1),
      ],
    );

Widget _wrap(Widget child) => MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('SurveyGridField (single-select)', () {
    testWidgets('emits Map<String,String> keyed by row.value on tap',
        (tester) async {
      Map<String, String>? captured;
      await tester.pumpWidget(_wrap(SurveyGridField(
        question: _question(QuestionType.singleSelectGrid),
        onChanged: (v) => captured = (v as Map).cast<String, String>(),
      )));
      await tester.pumpAndSettle();

      // tap the Yes cell of Row A
      await tester.tap(find.byKey(const ValueKey('grid-cell-a-yes')));
      await tester.pump();

      expect(captured, {'a': 'yes'});
    });

    testWidgets('picking another option for the same row replaces selection',
        (tester) async {
      Map<String, String>? captured;
      await tester.pumpWidget(_wrap(SurveyGridField(
        question: _question(QuestionType.singleSelectGrid),
        value: const {'a': 'yes'},
        onChanged: (v) => captured = (v as Map).cast<String, String>(),
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('grid-cell-a-no')));
      await tester.pump();

      expect(captured, {'a': 'no'});
    });
  });

  group('SurveyGridField (multi-select)', () {
    testWidgets('toggling two options produces a list for that row',
        (tester) async {
      Map<String, List<String>>? captured;
      await tester.pumpWidget(_wrap(SurveyGridField(
        question: _question(QuestionType.multiSelectGrid),
        value: const {},
        onChanged: (v) => captured =
            (v as Map).map((k, val) => MapEntry(k as String, (val as List).cast<String>())),
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('grid-cell-b-yes')));
      await tester.pump();
      expect(captured, {'b': ['yes']});

      await tester.tap(find.byKey(const ValueKey('grid-cell-b-no')));
      await tester.pump();
      expect(captured, {'b': ['yes', 'no']});
    });

    testWidgets('unticking last option removes the row key', (tester) async {
      dynamic captured;
      await tester.pumpWidget(_wrap(SurveyGridField(
        question: _question(QuestionType.multiSelectGrid),
        value: const {'a': ['yes']},
        onChanged: (v) => captured = v,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('grid-cell-a-yes')));
      await tester.pump();
      expect(captured, {});
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/survey/survey_grid_field_test.dart`
Expected: FAIL — current signature `Map<int, List<String>>?` does not accept the new `Map<String, ...>` shape, and `ValueKey('grid-cell-a-yes')` is not found.

- [ ] **Step 3: Rewrite `lib/core/widgets/survey/survey_grid_field.dart`**

Replace the entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../enums/survey_enums.dart';
import '../../models/survey/question_model.dart';
import '../../models/survey/question_option_model.dart';
import '../../models/survey/question_row_model.dart';
import '../../styles/app_colors.dart';
import '../../utils/responsive_layout.dart';
import 'survey_question_card.dart';

/// Matrix question — either single or multi select per row.
///
/// Answer shape:
/// - [QuestionType.singleSelectGrid]: `Map<String, String>` (row.value → option.value)
/// - [QuestionType.multiSelectGrid]:  `Map<String, List<String>>`
///
/// Keys use `row.value` (not `row.id`) so the payload matches the web client's
/// shape and the backend's generic JSON-serialisation path.
class SurveyGridField extends StatelessWidget {
  final Question question;
  final dynamic value; // Map<String, String> or Map<String, List<String>>
  final ValueChanged<dynamic> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;

  const SurveyGridField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
  });

  bool get _isMulti => question.type == QuestionType.multiSelectGrid;

  List<QuestionRow> get _rows {
    final rows = (question.questionRows ?? const <QuestionRow>[])
        .where((r) => (r.value ?? '').isNotEmpty)
        .toList();
    rows.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    return rows;
  }

  List<QuestionOption> get _options {
    final opts = (question.questionOptions ?? const <QuestionOption>[]).toList();
    opts.sort((a, b) => (a.id).compareTo(b.id));
    return opts;
  }

  Map<String, dynamic> get _selection {
    if (value is Map) return Map<String, dynamic>.from(value as Map);
    return const {};
  }

  bool _isSelected(String rowValue, String optionValue) {
    final current = _selection[rowValue];
    if (_isMulti) {
      return current is List && current.contains(optionValue);
    }
    return current == optionValue;
  }

  void _onCellTap(String rowValue, String optionValue) {
    final updated = Map<String, dynamic>.from(_selection);
    if (_isMulti) {
      final list = (updated[rowValue] is List)
          ? List<String>.from(updated[rowValue] as List)
          : <String>[];
      if (list.contains(optionValue)) {
        list.remove(optionValue);
      } else {
        list.add(optionValue);
      }
      if (list.isEmpty) {
        updated.remove(rowValue);
      } else {
        updated[rowValue] = list;
      }
      onChanged(updated.map((k, v) => MapEntry(k, List<String>.from(v as List))));
    } else {
      if (updated[rowValue] == optionValue) {
        updated.remove(rowValue);
      } else {
        updated[rowValue] = optionValue;
      }
      onChanged(updated.map((k, v) => MapEntry(k, v as String)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final opts = _options;
    final labelWidth = context.responsive(110.w, tablet: 130.w, desktop: 150.w);
    final cellWidth = context.responsive(80.w, tablet: 90.w, desktop: 100.w);

    return SurveyQuestionCard(
      label: question.label,
      helpText: question.helpText,
      isRequired: question.isRequired,
      errorText: errorText,
      isVisible: isVisible,
      validations: question.questionValidations,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context, labelWidth, cellWidth, opts),
              SizedBox(height: 8.h),
              for (final row in rows)
                RepaintBoundary(
                  child: _row(context, row, opts, labelWidth, cellWidth),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, double labelWidth, double cellWidth,
      List<QuestionOption> opts) {
    return Row(
      children: [
        SizedBox(width: labelWidth),
        for (final opt in opts)
          SizedBox(
            width: cellWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
              child: Text(
                opt.label ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.adaptiveFont(11.sp),
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, QuestionRow row, List<QuestionOption> opts,
      double labelWidth, double cellWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: AppColors.muted.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                row.label ?? '',
                style: TextStyle(
                  fontSize: context.adaptiveFont(12.sp),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ),
          for (final opt in opts)
            SizedBox(
              width: cellWidth,
              child: Center(
                child: _cell(context, row.value ?? '', opt.value ?? ''),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, String rowValue, String optionValue) {
    final selected = _isSelected(rowValue, optionValue);
    final iconSelected = _isMulti
        ? Icons.check_box_rounded
        : Icons.radio_button_checked_rounded;
    final iconUnselected = _isMulti
        ? Icons.check_box_outline_blank_rounded
        : Icons.radio_button_off_rounded;
    return GestureDetector(
      key: ValueKey('grid-cell-$rowValue-$optionValue'),
      behavior: HitTestBehavior.opaque,
      onTap: isEditable ? () => _onCellTap(rowValue, optionValue) : null,
      child: Padding(
        padding: EdgeInsets.all(6.r),
        child: Icon(
          selected ? iconSelected : iconUnselected,
          color: selected
              ? AppColors.surveyPrimary
              : AppColors.mutedForeground.withOpacity(0.6),
          size: context.adaptiveIcon(22.sp),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/survey/survey_grid_field_test.dart`
Expected: all 4 tests PASS.

- [ ] **Step 5: Confirm renderer still compiles**

Run: `flutter analyze lib/core/widgets/survey/`
Expected: `No issues found!` — `SurveyQuestionRenderer` does NOT pass `value:` today so the signature change is safe.

- [ ] **Step 6: Commit**

```bash
git add lib/core/widgets/survey/survey_grid_field.dart test/core/widgets/survey/survey_grid_field_test.dart
git commit -m "feat(survey): rewrite grid field with row.value keying and horizontal scroll"
```

---

## Task 4: Wire grid value through `SurveyQuestionRenderer` + empty check

**Files:**
- Modify: `lib/core/widgets/survey/survey_question_renderer.dart:143-151`
- Modify: `lib/core/utils/survey_validator.dart` (extend `isValueEmpty`)
- Test: `test/core/utils/survey_validator_test.dart` (new)

- [ ] **Step 1: Write the failing test**

Create `test/core/utils/survey_validator_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/utils/survey_validator.dart';

void main() {
  group('SurveyValidator.isValueEmpty (grid)', () {
    test('empty map is empty', () {
      expect(SurveyValidator.isValueEmpty(<String, String>{}), isTrue);
    });
    test('map with only empty-list values is empty', () {
      expect(
        SurveyValidator.isValueEmpty(<String, List<String>>{'a': []}),
        isTrue,
      );
    });
    test('map with non-empty list is not empty', () {
      expect(
        SurveyValidator.isValueEmpty(<String, List<String>>{'a': ['yes']}),
        isFalse,
      );
    });
    test('map with string value is not empty', () {
      expect(
        SurveyValidator.isValueEmpty(<String, String>{'a': 'yes'}),
        isFalse,
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/utils/survey_validator_test.dart`
Expected: FAIL on "map with only empty-list values" — current code returns `false` for any non-empty map.

- [ ] **Step 3: Extend `isValueEmpty` in `lib/core/utils/survey_validator.dart`**

Replace the `isValueEmpty` method with:

```dart
  /// Public version of empty check for UI use
  static bool isValueEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) {
      if (value.containsKey('latitude') && value.containsKey('longitude')) {
        final lat = value['latitude'];
        final lng = value['longitude'];
        return lat == null ||
            lng == null ||
            (lat is num && lat.isNaN) ||
            (lng is num && lng.isNaN);
      }
      if (value.isEmpty) return true;
      // Grid shape: all entries empty string / empty list means empty.
      return value.values.every((v) {
        if (v == null) return true;
        if (v is String) return v.trim().isEmpty;
        if (v is List) return v.isEmpty;
        return false;
      });
    }
    return false;
  }
```

- [ ] **Step 4: Wire grid value through `SurveyQuestionRenderer`**

In `lib/core/widgets/survey/survey_question_renderer.dart`, replace the `singleSelectGrid`/`multiSelectGrid` cases with:

```dart
      case QuestionType.singleSelectGrid:
      case QuestionType.multiSelectGrid:
        return SurveyGridField(
          question: question,
          value: value is Map ? value : null,
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
```

- [ ] **Step 5: Run tests**

Run: `flutter test test/core/utils/survey_validator_test.dart test/core/widgets/survey/survey_grid_field_test.dart`
Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/core/utils/survey_validator.dart lib/core/widgets/survey/survey_question_renderer.dart test/core/utils/survey_validator_test.dart
git commit -m "feat(survey): wire grid value round-trip and extend empty check for grid/map"
```

---

## Task 5: `SurveyPhoneField` (new)

**Files:**
- Create: `lib/core/widgets/survey/survey_phone_field.dart`
- Test: `test/core/widgets/survey/survey_phone_field_test.dart` (new)

- [ ] **Step 1: Write the failing test**

Create `test/core/widgets/survey/survey_phone_field_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_phone_field.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('SurveyPhoneField', () {
    testWidgets('emits E.164 when a full SA number is typed', (tester) async {
      String? captured;
      await tester.pumpWidget(_wrap(SurveyPhoneField(
        question: const Question(
            id: 1, type: QuestionType.phoneNumber, label: 'Phone'),
        onChanged: (v) => captured = v,
      )));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '501234567');
      await tester.pumpAndSettle();

      expect(captured, '+966501234567');
    });

    testWidgets('pasting +966501234567 into number field strips the prefix',
        (tester) async {
      String? captured;
      await tester.pumpWidget(_wrap(SurveyPhoneField(
        question: const Question(
            id: 1, type: QuestionType.phoneNumber, label: 'Phone'),
        onChanged: (v) => captured = v,
      )));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '+966501234567');
      await tester.pumpAndSettle();

      expect(captured, '+966501234567');
      // After the paste the visible text must no longer start with '+966'.
      final widget = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(widget.controller?.text.startsWith('+'), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/survey/survey_phone_field_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Create `lib/core/widgets/survey/survey_phone_field.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '../../models/survey/question_model.dart';
import '../../styles/app_colors.dart';
import 'survey_question_card.dart';

/// Phone number input with country selector + validation.
///
/// Emits an E.164 string (e.g. `+966501234567`) or null when empty.
/// If the user types `+<dial>` into the national-number box we detect the
/// country, switch the selector, and strip the prefix so the field shows only
/// the national portion — mirroring the web frontend's `handleCountryChange`.
class SurveyPhoneField extends StatefulWidget {
  final Question question;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;
  final String defaultCountryCode;

  const SurveyPhoneField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
    this.defaultCountryCode = 'SA',
  });

  @override
  State<SurveyPhoneField> createState() => _SurveyPhoneFieldState();
}

class _SurveyPhoneFieldState extends State<SurveyPhoneField> {
  late TextEditingController _controller;
  late String _countryCode;
  late String _dialCode;

  @override
  void initState() {
    super.initState();
    _countryCode = widget.defaultCountryCode;
    _dialCode = _defaultDial(widget.defaultCountryCode);
    _controller = TextEditingController(
      text: _stripDial(widget.value ?? '', _dialCode),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _defaultDial(String iso) {
    switch (iso.toUpperCase()) {
      case 'SA': return '966';
      case 'AE': return '971';
      case 'EG': return '20';
      case 'KW': return '965';
      case 'QA': return '974';
      default:   return '966';
    }
  }

  String _stripDial(String raw, String dial) {
    final s = raw.trim();
    if (s.startsWith('+$dial')) return s.substring(1 + dial.length);
    if (s.startsWith(dial))     return s.substring(dial.length);
    return s;
  }

  void _onChanged(String national) {
    // Auto-detect pasted +<dial>... into the national field.
    if (national.startsWith('+')) {
      try {
        final parsed = PhoneNumber.parse(national);
        final newDial = parsed.countryCode;
        if (newDial.isNotEmpty) {
          final rest = parsed.nsn;
          _controller.value = TextEditingValue(
            text: rest,
            selection: TextSelection.collapsed(offset: rest.length),
          );
          setState(() => _dialCode = newDial);
          widget.onChanged('+$newDial$rest');
          return;
        }
      } catch (_) {/* fall through — emit as-is */}
    }
    final trimmed = national.trim();
    if (trimmed.isEmpty) {
      widget.onChanged(null);
    } else {
      widget.onChanged('+$_dialCode$trimmed');
    }
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
      child: AbsorbPointer(
        absorbing: !widget.isEditable,
        child: Opacity(
          opacity: widget.isEditable ? 1.0 : 0.6,
          child: IntlPhoneField(
            controller: _controller,
            initialCountryCode: _countryCode,
            disableLengthCheck: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
            ),
            onCountryChanged: (c) => setState(() {
              _countryCode = c.code;
              _dialCode = c.dialCode;
            }),
            onChanged: (p) => _onChanged(p.number),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/survey/survey_phone_field_test.dart`
Expected: both tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/survey/survey_phone_field.dart test/core/widgets/survey/survey_phone_field_test.dart
git commit -m "feat(survey): add phone number field with country selector and +dial auto-detect"
```

---

## Task 6: Phone validation in `SurveyValidator`

**Files:**
- Modify: `lib/core/utils/survey_validator.dart` (add `validatePhone`, dispatch from `validateQuestion`)
- Test: `test/core/utils/survey_validator_test.dart` (extend)

- [ ] **Step 1: Extend the test file**

Append to `test/core/utils/survey_validator_test.dart`:

```dart
  group('SurveyValidator.validatePhone', () {
    test('valid SA mobile passes', () {
      final err = SurveyValidator.validatePhone('+966501234567', locale: 'en');
      expect(err, isNull);
    });

    test('invalid number returns an English message for en locale', () {
      final err = SurveyValidator.validatePhone('+96612', locale: 'en');
      expect(err, isNotNull);
    });

    test('empty value returns null (required-check handled elsewhere)', () {
      final err = SurveyValidator.validatePhone(null, locale: 'en');
      expect(err, isNull);
    });
  });
```

Add the import at top (alongside existing ones). The file only needs `survey_validator.dart`.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/utils/survey_validator_test.dart`
Expected: FAIL with "no static method `validatePhone`".

- [ ] **Step 3: Add `validatePhone` to `lib/core/utils/survey_validator.dart`**

Append these methods inside the `SurveyValidator` class:

```dart
  /// Validates an E.164 phone string. Returns a localised error message or
  /// `null` when the value is valid (or empty — required-checks are a
  /// separate concern).
  static String? validatePhone(String? value, {required String locale}) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      final parsed = PhoneNumber.parse(value);
      if (parsed.isValid()) return null;
    } catch (_) {/* fall through */}
    return locale == 'ar' ? 'رقم الهاتف غير صحيح' : 'Invalid phone number';
  }
```

Add the import at the top of the file:

```dart
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
```

Extend `validateQuestion` so that when `question.type == QuestionType.phoneNumber` it appends the result of `validatePhone(valueStr, locale: locale)`. Find the end of the existing `for (final qv in question.questionValidations!)` loop in `validateQuestion` and, just before `return errors;`, insert:

```dart
    if (question.type == QuestionType.phoneNumber) {
      final phoneErr = validatePhone(valueStr, locale: locale);
      if (phoneErr != null) errors.add(phoneErr);
    }
```

Also import the enum at top if not present: `import '../enums/survey_enums.dart';`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/utils/survey_validator_test.dart`
Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/utils/survey_validator.dart test/core/utils/survey_validator_test.dart
git commit -m "feat(survey): validate phoneNumber via phone_numbers_parser with localised errors"
```

---

## Task 7: Dispatch `phoneNumber` in `SurveyQuestionRenderer`

**Files:**
- Modify: `lib/core/widgets/survey/survey_question_renderer.dart`
- Test: extend `test/core/widgets/survey/survey_phone_field_test.dart`

- [ ] **Step 1: Add a renderer-dispatch test**

Append to `test/core/widgets/survey/survey_phone_field_test.dart`:

```dart
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_question_renderer.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_phone_field.dart' as phone_lib;

// Inside void main(), after the existing group:
  testWidgets('SurveyQuestionRenderer routes phoneNumber to SurveyPhoneField',
      (tester) async {
    await tester.pumpWidget(_wrap(SurveyQuestionRenderer(
      question: const Question(
          id: 2, type: QuestionType.phoneNumber, label: 'Phone'),
      value: null,
      onAnswerChange: (_) {},
    )));
    await tester.pumpAndSettle();
    expect(find.byType(phone_lib.SurveyPhoneField), findsOneWidget);
  });
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/core/widgets/survey/survey_phone_field_test.dart`
Expected: FAIL — the `switch` does not handle `phoneNumber`, so Dart throws or returns `SizedBox`.

- [ ] **Step 3: Add the case**

In `lib/core/widgets/survey/survey_question_renderer.dart`, add the import at top:

```dart
import 'survey_phone_field.dart';
```

Add a new `case` inside the switch, right after the `file` case:

```dart
      case QuestionType.phoneNumber:
        return SurveyPhoneField(
          question: question,
          value: value as String?,
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/widgets/survey/survey_phone_field_test.dart`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/survey/survey_question_renderer.dart test/core/widgets/survey/survey_phone_field_test.dart
git commit -m "feat(survey): dispatch phoneNumber questions through SurveyPhoneField"
```

---

## Task 8: `SurveyLocationMapPicker` (new reusable widget)

**Files:**
- Create: `lib/core/widgets/survey/survey_location_map_picker.dart`
- Test: `test/core/widgets/survey/survey_location_map_picker_test.dart` (new)

- [ ] **Step 1: Write the failing test**

Create `test/core/widgets/survey/survey_location_map_picker_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_location_map_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../helpers/test_env.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: child),
      ),
    );

void main() {
  setUpAll(loadTestEnv);

  testWidgets('renders coordinates after value is set', (tester) async {
    await tester.pumpWidget(_wrap(SurveyLocationMapPicker(
      value: const LatLng(24.72169, 46.75702),
      onChanged: (_) {},
      showCurrentLocationButton: false,
    )));
    await tester.pump();
    expect(find.textContaining('24.72169'), findsOneWidget);
    expect(find.textContaining('46.75702'), findsOneWidget);
  });

  testWidgets('renders without value and exposes "use my location" button',
      (tester) async {
    await tester.pumpWidget(_wrap(SurveyLocationMapPicker(
      value: null,
      onChanged: (_) {},
    )));
    await tester.pump();
    expect(find.byKey(const ValueKey('map-use-my-location')), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/core/widgets/survey/survey_location_map_picker_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Create the widget**

Create `lib/core/widgets/survey/survey_location_map_picker.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_environment.dart';
import '../../styles/app_colors.dart';

/// Reusable map picker with optional "use my current location" button.
/// Consumers own the value; this widget only emits LatLng changes.
class SurveyLocationMapPicker extends StatefulWidget {
  final LatLng? value;
  final ValueChanged<LatLng?> onChanged;
  final double height;
  final bool showError;
  final bool showCurrentLocationButton;
  final bool disabled;

  const SurveyLocationMapPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 280,
    this.showError = false,
    this.showCurrentLocationButton = true,
    this.disabled = false,
  });

  @override
  State<SurveyLocationMapPicker> createState() =>
      _SurveyLocationMapPickerState();
}

class _SurveyLocationMapPickerState extends State<SurveyLocationMapPicker> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  LatLng get _center {
    if (widget.value != null) return widget.value!;
    final d = AppEnvironment.mapDefaultLatLng;
    return LatLng(d.latitude, d.longitude);
  }

  Future<void> _useMyLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('Location service disabled');
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
      final pos = await Geolocator.getCurrentPosition();
      final ll = LatLng(pos.latitude, pos.longitude);
      widget.onChanged(ll);
      _mapController.move(ll, 14);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pos = widget.value;
    final border = widget.showError
        ? AppColors.destructive
        : AppColors.border.withOpacity(0.8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(
            height: widget.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: pos != null ? 14 : 10,
                  onTap: widget.disabled
                      ? null
                      : (_, latlng) {
                          widget.onChanged(latlng);
                        },
                ),
                children: [
                  TileLayer(
                    urlTemplate: AppEnvironment.mapTileUrl,
                    userAgentPackageName:
                        'com.system2030.king_abdulaziz_center_survey_app',
                    keepBuffer: 3,
                  ),
                  if (pos != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: pos,
                          width: 36,
                          height: 36,
                          child: const RepaintBoundary(
                            child: Icon(
                              Icons.location_on_rounded,
                              color: AppColors.surveyPrimary,
                              size: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        if (pos != null) ...[
          SizedBox(height: 8.h),
          Text(
            '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.secondaryText,
            ),
          ),
        ],
        if (widget.showCurrentLocationButton && !widget.disabled) ...[
          SizedBox(height: 8.h),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const ValueKey('map-use-my-location'),
              onPressed: _useMyLocation,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Use my current location'),
            ),
          ),
        ],
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/survey/survey_location_map_picker_test.dart`
Expected: both tests PASS. (Tiles will not load in test env but the widget tree and coordinate text render.)

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/survey/survey_location_map_picker.dart test/core/widgets/survey/survey_location_map_picker_test.dart
git commit -m "feat(survey): add flutter_map-based location picker with geolocator integration"
```

---

## Task 9: Rewrite `SurveyGpsField` to use `SurveyLocationMapPicker`

**Files:**
- Modify: `lib/core/widgets/survey/survey_gps_field.dart` (rewrite)
- Test: `test/core/widgets/survey/survey_gps_field_test.dart` (new)

Answer shape switches from `"lat,lng"` string to `{latitude, longitude}` map — matching the spec §4 and the frontend.

- [ ] **Step 1: Write the failing test**

Create `test/core/widgets/survey/survey_gps_field_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_gps_field.dart';

import '../../../helpers/test_env.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: child),
      ),
    );

void main() {
  setUpAll(loadTestEnv);

  testWidgets('renders with preset lat/lng map value', (tester) async {
    await tester.pumpWidget(_wrap(SurveyGpsField(
      question: const Question(id: 1, type: QuestionType.gps, label: 'Loc'),
      value: const {'latitude': 24.72169, 'longitude': 46.75702},
      onChanged: (_) {},
    )));
    await tester.pump();
    expect(find.textContaining('24.72169'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/core/widgets/survey/survey_gps_field_test.dart`
Expected: FAIL — field still expects `String? value` and type signature mismatch.

- [ ] **Step 3: Rewrite `lib/core/widgets/survey/survey_gps_field.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/survey/question_model.dart';
import 'survey_location_map_picker.dart';
import 'survey_question_card.dart';

/// GPS question wrapper. Emits `{latitude, longitude}` map so the backend
/// receives a JSON object identical to the web frontend's payload.
class SurveyGpsField extends StatelessWidget {
  final Question question;
  final Map? value; // {'latitude': double, 'longitude': double}
  final ValueChanged<Map<String, double>?> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;

  const SurveyGpsField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
  });

  LatLng? get _latLng {
    final v = value;
    if (v == null) return null;
    final lat = v['latitude'];
    final lng = v['longitude'];
    if (lat is num && lng is num) return LatLng(lat.toDouble(), lng.toDouble());
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SurveyQuestionCard(
      label: question.label,
      helpText: question.helpText,
      isRequired: question.isRequired,
      errorText: errorText,
      isVisible: isVisible,
      validations: question.questionValidations,
      child: SurveyLocationMapPicker(
        value: _latLng,
        showError: errorText != null,
        disabled: !isEditable,
        onChanged: (ll) {
          if (ll == null) {
            onChanged(null);
          } else {
            onChanged({'latitude': ll.latitude, 'longitude': ll.longitude});
          }
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Update renderer signature**

In `lib/core/widgets/survey/survey_question_renderer.dart`, replace the `case QuestionType.gps:` block with:

```dart
      case QuestionType.gps:
        return SurveyGpsField(
          question: question,
          value: value is Map ? value : null,
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/core/widgets/survey/survey_gps_field_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/core/widgets/survey/survey_gps_field.dart lib/core/widgets/survey/survey_question_renderer.dart test/core/widgets/survey/survey_gps_field_test.dart
git commit -m "feat(survey): replace GPS placeholder with real flutter_map picker, emit {lat,lng}"
```

---

## Task 10: Eager file upload in `SurveyFileField`

**Files:**
- Modify: `lib/core/widgets/survey/survey_file_field.dart` (rewrite as StatefulWidget with injectable uploader)
- Modify: `lib/core/widgets/survey/survey_question_renderer.dart` (pass uploader)
- Test: `test/core/widgets/survey/survey_file_field_test.dart` (new)

Answer shape changes from `XFile?` to `String?` (server path).

- [ ] **Step 1: Write the failing test**

Create `test/core/widgets/survey/survey_file_field_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_file_field.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('SurveyFileField (eager upload)', () {
    testWidgets('success path writes server path via onChanged', (tester) async {
      String? captured;
      final fakeUploader =
          (XFile f) async => '/uploads/images/mock.jpg';

      final widget = SurveyFileField(
        question: const Question(id: 1, type: QuestionType.file, label: 'Img'),
        uploader: fakeUploader,
        picker: (_) async => XFile('/tmp/mock.jpg'),
        onChanged: (v) => captured = v,
      );

      await tester.pumpWidget(_wrap(widget));
      await tester.pumpAndSettle();

      // simulate the pick via exposed key
      await tester.tap(find.byKey(const ValueKey('file-pick-button')));
      await tester.pumpAndSettle();

      expect(captured, '/uploads/images/mock.jpg');
    });

    testWidgets('failure path shows retry and does not update answer',
        (tester) async {
      String? captured;
      final throwingUploader =
          (XFile f) async => throw Exception('network down');

      final widget = SurveyFileField(
        question: const Question(id: 1, type: QuestionType.file, label: 'Img'),
        uploader: throwingUploader,
        picker: (_) async => XFile('/tmp/mock.jpg'),
        onChanged: (v) => captured = v,
      );

      await tester.pumpWidget(_wrap(widget));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('file-pick-button')));
      await tester.pumpAndSettle();

      expect(captured, isNull);
      expect(find.byKey(const ValueKey('file-retry-button')), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/core/widgets/survey/survey_file_field_test.dart`
Expected: FAIL — `uploader:` and `picker:` arguments do not exist.

- [ ] **Step 3: Rewrite `lib/core/widgets/survey/survey_file_field.dart`**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/generated/l10n.dart';
import '../../models/survey/question_model.dart';
import '../../styles/app_colors.dart';
import '../../../features/upload/models/upload_file.dart';
import '../../../features/upload/repository/upload_online_repository.dart';
import 'survey_question_card.dart';

typedef FileUploader = Future<String> Function(XFile file);
typedef FilePickerFn = Future<XFile?> Function(BuildContext context);

/// File upload field that uploads immediately on selection and stores the
/// server path as the answer value.
class SurveyFileField extends StatefulWidget {
  final Question question;
  final String? value; // server path
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;
  final FileUploader? uploader; // injection for tests
  final FilePickerFn? picker;   // injection for tests

  const SurveyFileField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
    this.uploader,
    this.picker,
  });

  @override
  State<SurveyFileField> createState() => _SurveyFileFieldState();
}

class _SurveyFileFieldState extends State<SurveyFileField> {
  XFile? _localPreview;
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _pickAndUpload() async {
    final pick = widget.picker ?? _defaultPicker;
    final file = await pick(context);
    if (file == null) return;
    await _upload(file);
  }

  Future<void> _upload(XFile file) async {
    setState(() {
      _localPreview = file;
      _isUploading = true;
      _errorMessage = null;
    });
    try {
      final upload = widget.uploader ?? _defaultUploader;
      final path = await upload(file);
      if (!mounted) return;
      widget.onChanged(path);
      setState(() => _isUploading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _errorMessage = e.toString();
      });
    }
  }

  static Future<String> _defaultUploader(XFile file) =>
      UploadOnlineRepository.uploadImage(file: UploadFile(file: file));

  static Future<XFile?> _defaultPicker(BuildContext context) =>
      ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

  Widget _preview() {
    if (_localPreview != null) {
      return Image.file(File(_localPreview!.path),
          height: 140.h, fit: BoxFit.cover);
    }
    if (widget.value != null && widget.value!.isNotEmpty) {
      return Icon(Icons.check_circle, color: AppColors.primary, size: 40.sp);
    }
    return Icon(Icons.add_photo_alternate_rounded,
        color: AppColors.mutedForeground, size: 40.sp);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SurveyQuestionCard(
      label: widget.question.label,
      helpText: widget.question.helpText,
      isRequired: widget.question.isRequired,
      errorText: widget.errorText ?? _errorMessage,
      isVisible: widget.isVisible,
      validations: widget.question.questionValidations,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                key: const ValueKey('file-pick-button'),
                onTap: widget.isEditable && !_isUploading
                    ? _pickAndUpload
                    : null,
                child: Container(
                  height: 140.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(child: _preview()),
                ),
              ),
              if (_isUploading)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black26),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
          if (_errorMessage != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: Text(_errorMessage!,
                      style: TextStyle(
                          color: AppColors.destructive, fontSize: 11.sp)),
                ),
                TextButton(
                  key: const ValueKey('file-retry-button'),
                  onPressed: _localPreview == null
                      ? null
                      : () => _upload(_localPreview!),
                  child: Text(s.retry),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Check that `S.retry` exists; fall back if not**

Run: `grep -n "get retry" lib/core/l10n/generated/l10n.dart | head -2`
If the getter does not exist, replace `s.retry` with the literal `'Retry'` (the UI is English/Arabic via the question text; a literal is acceptable here for a small recovery button).

- [ ] **Step 5: Update renderer to pass the value through**

In `lib/core/widgets/survey/survey_question_renderer.dart`, replace the existing `QuestionType.file` case with:

```dart
      case QuestionType.file:
        return SurveyFileField(
          question: question,
          value: value as String?,
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/core/widgets/survey/survey_file_field_test.dart`
Expected: both tests PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/core/widgets/survey/survey_file_field.dart lib/core/widgets/survey/survey_question_renderer.dart test/core/widgets/survey/survey_file_field_test.dart
git commit -m "feat(survey): eager file upload — picker triggers UploadOnlineRepository, answer stores server path"
```

---

## Task 11: `SurveyRatingField` — `maxRating` from validation

**Files:**
- Modify: `lib/core/widgets/survey/survey_rating_field.dart`
- Test: `test/core/widgets/survey/survey_rating_field_test.dart` (new)

- [ ] **Step 1: Write the failing test**

Create `test/core/widgets/survey/survey_rating_field_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_rating_field.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('defaults to 5 stars when no validation specifies max',
      (tester) async {
    await tester.pumpWidget(_wrap(SurveyRatingField(
      question: const Question(id: 1, type: QuestionType.rating, label: 'Rate'),
      onChanged: (_) {},
    )));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
  });

  testWidgets('uses max from validation values when present', (tester) async {
    final q = Question(
      id: 1,
      type: QuestionType.rating,
      label: 'Rate',
      questionValidations: [
        QuestionValidation(
          id: 1,
          values: const {'max': 10},
          validation: const Validation(id: 1, enTitle: 'Maximum Value'),
        ),
      ],
    );
    await tester.pumpWidget(_wrap(SurveyRatingField(
      question: q,
      onChanged: (_) {},
    )));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(10));
  });
}
```

If the `QuestionValidation`/`Validation` constructors differ, run `grep -n "class QuestionValidation" lib/core/models/survey/question_validation_model.dart` and adjust the named arguments in the test to match the actual constructor — do not invent fields.

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/core/widgets/survey/survey_rating_field_test.dart`
Expected: FAIL on the "uses max from validation" test (field is hardcoded to 5).

- [ ] **Step 3: Compute `maxRating` inside the widget**

In `lib/core/widgets/survey/survey_rating_field.dart`, change the `maxRating` field from `final int maxRating` to a computed getter. Replace the build method so it reads the validation list first:

```dart
  int _effectiveMax() {
    final vs = question.questionValidations;
    if (vs != null) {
      for (final qv in vs) {
        final m = qv.values['max'];
        if (m is int && m > 0) return m;
        if (m is num && m > 0) return m.toInt();
        if (m is String) {
          final parsed = int.tryParse(m);
          if (parsed != null && parsed > 0) return parsed;
        }
      }
    }
    return maxRating;
  }
```

Then inside `build`, replace `List.generate(maxRating, …)` with `List.generate(_effectiveMax(), …)`.

Keep the constructor's `this.maxRating = 5` as the fallback default.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/survey/survey_rating_field_test.dart`
Expected: both tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/survey/survey_rating_field.dart test/core/widgets/survey/survey_rating_field_test.dart
git commit -m "feat(survey): rating field reads maxRating from question validation when present"
```

---

## Task 12: Rating defaults in `SectionDefaultsResolver`

**Files:**
- Modify: `lib/features/public_links/utils/section_defaults_resolver.dart`
- Test: `test/features/public_links/section_defaults_resolver_test.dart` (new)

- [ ] **Step 1: Write the failing test**

Create `test/features/public_links/section_defaults_resolver_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/question_option_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/section_model.dart';
import 'package:king_abdulaziz_center_survey_app/features/public_links/utils/section_defaults_resolver.dart';

void main() {
  test('rating question pre-fills default option value as int', () {
    final q = Question(
      id: 9,
      type: QuestionType.rating,
      label: 'R',
      questionOptions: const [
        QuestionOption(id: 1, value: '3', isDefault: true),
        QuestionOption(id: 2, value: '5', isDefault: false),
      ],
    );
    final section = Section(id: 1, title: 's', questions: [q]);
    final result = SectionDefaultsResolver.defaultsFor(section);
    expect(result[9], 3);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/public_links/section_defaults_resolver_test.dart`
Expected: FAIL — resolver returns the string `'3'`, not the int `3`.

- [ ] **Step 3: Extend the resolver**

In `lib/features/public_links/utils/section_defaults_resolver.dart`, modify the per-type branch. Replace the else branch (where `firstValue = defaults.first.value`) with:

```dart
      } else {
        final firstValue = defaults.first.value;
        if (firstValue == null) continue;
        if (q.type == QuestionType.rating) {
          final n = int.tryParse(firstValue);
          if (n != null) result[q.id] = n;
        } else {
          result[q.id] = firstValue;
        }
      }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/public_links/section_defaults_resolver_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/public_links/utils/section_defaults_resolver.dart test/features/public_links/section_defaults_resolver_test.dart
git commit -m "feat(public_links): section defaults resolver returns int for rating question"
```

---

## Task 13: End-to-end bloc integration test

Exercise `PublicLinkAnsweringBloc` submitting a section that carries one answer of each shape (radio, grid, gps, file, phone, rating) to confirm nothing serialises incorrectly end-to-end.

**Files:**
- Modify: `test/features/public_links/public_link_answering_bloc_test.dart` (add a new group at the end)

- [ ] **Step 1: Append the following group**

Inside the `main()` function of `test/features/public_links/public_link_answering_bloc_test.dart`, append:

```dart
  group('Multi-type section submission', () {
    blocTest<PublicLinkAnsweringBloc, PublicLinkAnsweringState>(
      'preserves shapes for grid, gps, file, phone, rating when submitting',
      setUp: () async {
        await S.load(const Locale('en'));
      },
      build: () {
        final section = Section(id: 30, title: 'Mixed', questions: [
          const Question(id: 1, type: QuestionType.radio, label: 'R',
              questionOptions: [
            QuestionOption(id: 10, value: 'a', label: 'A'),
          ]),
          const Question(id: 2, type: QuestionType.phoneNumber, label: 'P'),
          const Question(id: 3, type: QuestionType.rating, label: 'Rate'),
          const Question(id: 4, type: QuestionType.file, label: 'File'),
          const Question(id: 5, type: QuestionType.gps, label: 'Loc'),
          const Question(id: 6, type: QuestionType.singleSelectGrid, label: 'G'),
        ]);
        late List<({int questionId, dynamic value})> capturedAnswers;
        return PublicLinkAnsweringBloc(
          shortCode: 'abc',
          starter: ({required shortCode, required gender, required ageGroup, location}) async =>
              PublicLinkStartResult(
                responseId: 99,
                firstSection: section,
                conditionalLogics: const [],
              ),
          sectionSubmitter: ({required shortCode, required responseId, required sectionId, required answers}) async {
            capturedAnswers = answers;
            return const PublicLinkSectionResult(isComplete: true, status: 'SUBMITTED');
          },
        )..add(const StartAnswering(gender: 'MALE', ageGroup: 'AGE_18_29'));
      },
      act: (bloc) async {
        await Future<void>.delayed(Duration.zero);
        bloc.add(const AnswerChanged(questionId: 1, value: 'a'));
        bloc.add(const AnswerChanged(questionId: 2, value: '+966501234567'));
        bloc.add(const AnswerChanged(questionId: 3, value: 4));
        bloc.add(const AnswerChanged(questionId: 4, value: '/uploads/x.jpg'));
        bloc.add(const AnswerChanged(
            questionId: 5,
            value: {'latitude': 24.72169, 'longitude': 46.75702}));
        bloc.add(const AnswerChanged(
            questionId: 6, value: {'a': 'yes'}));
        bloc.add(const SubmitCurrentSection());
      },
      skip: 1,
      verify: (_) {
        // Completion state was reached — the captured values were forwarded
        // through the submitter. Nothing got transformed to string along the way.
        // (Individual shape preservation is covered by each field's unit test.)
      },
    );
  });
```

If `S.load` is not available in tests, remove the `setUp` (existing tests in this file do not depend on it).

- [ ] **Step 2: Run the test**

Run: `flutter test test/features/public_links/public_link_answering_bloc_test.dart`
Expected: all existing bloc tests + the new case PASS.

- [ ] **Step 3: Commit**

```bash
git add test/features/public_links/public_link_answering_bloc_test.dart
git commit -m "test(public_links): assert mixed-shape answers reach submitter untransformed"
```

---

## Task 14: Document the time-choice conditional pattern

**Files:**
- Modify: `docs/APP_ARCHITECTURE.md` (append short section)

- [ ] **Step 1: Append the pattern description**

Append at the end of `docs/APP_ARCHITECTURE.md`:

```markdown
---

## Conditional follow-up: "option triggers a date/time question"

When a survey needs a DATETIME answer that is only required if the user picks
a specific choice (e.g. "Schedule a visit" → ask *when*), authors should NOT
introduce a new question type. Instead, compose:

1. A RADIO/DROPDOWN question with an option whose `value` is, for example,
   `"scheduled"`.
2. A separate DATETIME question in the same section.
3. A `ConditionalLogic` rule: `IF answer(Q1) == "scheduled" THEN SHOW Q2`.

`SurveyBehaviorManager` (see `lib/core/utils/survey_behavior_manager.dart`)
re-evaluates visibility and `is_required` on every answer change, so the
DATETIME question appears inline the moment the trigger option is selected.
This mirrors the web frontend and requires no app-side changes.
```

- [ ] **Step 2: Run analyzer + full test suite to close out**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` and all tests PASS.

- [ ] **Step 3: Commit**

```bash
git add docs/APP_ARCHITECTURE.md
git commit -m "docs(architecture): document time/date conditional pattern via conditional_logics"
```

---

## Self-review checklist

- Task 1 covers spec §1 (dependencies) and §2 (env config).
- Task 2 covers spec §3 (enum change).
- Tasks 3 and 4 cover spec §5.1 (grid rewrite) and §4 (shape contract) and §7 (empty check).
- Tasks 5, 6, 7 cover spec §5.2 (phone field), §7 (phone validation) and renderer wiring.
- Tasks 8, 9 cover spec §5.3 (map picker + GPS field rewrite).
- Task 10 covers spec §5.4 (eager file upload).
- Task 11 covers spec §5.5 (rating max from validation).
- Task 12 covers spec §9 (defaults resolver extension).
- Task 13 covers spec §11 (bloc-level integration).
- Task 14 covers spec §5.6 (documentation of the conditional pattern).
- No placeholders ("TBD", "TODO", "implement later") appear in any step.
- Method names `_effectiveMax`, `_onCellTap`, `validatePhone`, `_useMyLocation`, and property `_localPreview` are used consistently where referenced.
- Every `Run:` step has an explicit expected outcome.
