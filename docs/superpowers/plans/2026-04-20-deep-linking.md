# Deep Linking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable HTTPS App Links / Universal Links into the Flutter app for (1) device registration with a pre-filled token, and (2) direct survey access via shortCode — bypassing the browser and working regardless of auth state.

**Architecture:** A new `features/deep_linking/` module owns link reception, parsing, gating, and dispatch via `GoRouter`. It drives two existing features: `device_registration/` (pre-filled token mode) and `assignment/` (new `survey_by_short_code` entry into `SurveyAnsweringPage`). Native config uses Android product flavors and iOS build configurations to inject the env-specific host.

**Tech Stack:** Flutter, `app_links` (new), `flutter_bloc`, `go_router`, `connectivity_plus`, `flutter_dotenv`, Dio-backed `APIRequest`. Android Gradle flavors, iOS xcconfigs + entitlements.

**Spec:** `docs/superpowers/specs/2026-04-20-deep-linking-design.md`

---

## File map

### New

- `lib/features/deep_linking/config/deep_link_config.dart`
- `lib/features/deep_linking/models/deep_link.dart`
- `lib/features/deep_linking/models/device_registration_args.dart`
- `lib/features/deep_linking/models/survey_deep_link_args.dart`
- `lib/features/deep_linking/service/deep_link_parser.dart`
- `lib/features/deep_linking/service/deep_link_service.dart`
- `lib/features/deep_linking/bloc/deep_link_bloc.dart`
- `lib/features/deep_linking/bloc/deep_link_event.dart`
- `lib/features/deep_linking/bloc/deep_link_state.dart`
- `lib/features/deep_linking/presentation/deep_link_listener.dart`
- `lib/features/deep_linking/presentation/widgets/discard_survey_dialog.dart`
- `lib/features/assignment/bloc/survey_by_short_code/survey_by_short_code_bloc.dart`
- `lib/features/assignment/bloc/survey_by_short_code/survey_by_short_code_event.dart`
- `lib/features/assignment/bloc/survey_by_short_code/survey_by_short_code_state.dart`
- `lib/features/assignment/presentation/pages/survey_deep_link_page.dart`
- `test/features/deep_linking/deep_link_parser_test.dart`
- `test/features/deep_linking/deep_link_service_test.dart`
- `test/features/deep_linking/deep_link_bloc_test.dart`
- `test/features/deep_linking/deep_link_listener_test.dart`
- `test/features/assignment/survey_by_short_code_bloc_test.dart`
- `android/app/src/main/AndroidManifest.xml` (modify)
- `ios/Flutter/Dev.xcconfig`, `Staging.xcconfig`, `Prod.xcconfig`
- `ios/Runner/Runner.entitlements` (modify)

### Modify

- `pubspec.yaml` — add `app_links`
- `lib/core/routes/app_routes.dart` — add `surveyDeepLinkPath`
- `lib/core/routes/app_pages.dart` — register `SurveyDeepLinkPage`, update `deviceRegistrationPath` builder to accept typed args
- `lib/main.dart` — wire `DeepLinkService`, `DeepLinkBloc`, `DeepLinkListener`, lifecycle observer
- `lib/features/public_links/repository/public_links_online_repository.dart` — add **public** `getPublicSurveyByShortCode(shortCode)` method (unauthenticated endpoint)
- `lib/features/device_registration/presentation/device_registration_page.dart` — accept `DeviceRegistrationArgs(token, fromDeepLink)`, surface invalid/expired/already-registered states
- `android/app/build.gradle` — add `flavorDimensions` + three `productFlavors`
- `ios/Runner.xcodeproj/project.pbxproj` — add three build configurations + schemes (manually via Xcode)

---

## Task 1: Add `app_links` dependency

**Files:** Modify `pubspec.yaml`.

- [ ] **Step 1: Add dep**

Edit `pubspec.yaml`, add under `dependencies:` (alphabetical by convention, or at end):

```yaml
  app_links: ^6.3.2
```

- [ ] **Step 2: Fetch**

Run: `flutter pub get`
Expected: resolves with no errors; `app_links` appears in `pubspec.lock`.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore(deps): add app_links for deep linking"
```

---

## Task 2: Typed route argument objects

**Files:**
- Create: `lib/features/deep_linking/models/device_registration_args.dart`
- Create: `lib/features/deep_linking/models/survey_deep_link_args.dart`

- [ ] **Step 1: Create `DeviceRegistrationArgs`**

```dart
// lib/features/deep_linking/models/device_registration_args.dart
import 'package:equatable/equatable.dart';

class DeviceRegistrationArgs extends Equatable {
  final String token;
  final bool fromDeepLink;

  const DeviceRegistrationArgs({
    required this.token,
    this.fromDeepLink = false,
  });

  @override
  List<Object?> get props => [token, fromDeepLink];
}
```

- [ ] **Step 2: Create `SurveyDeepLinkArgs`**

```dart
// lib/features/deep_linking/models/survey_deep_link_args.dart
import 'package:equatable/equatable.dart';

class SurveyDeepLinkArgs extends Equatable {
  final String shortCode;

  const SurveyDeepLinkArgs({required this.shortCode});

  @override
  List<Object?> get props => [shortCode];
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/deep_linking/models/
git commit -m "feat(deep_linking): add typed route argument objects"
```

---

## Task 3: `DeepLink` sealed model

**Files:** Create `lib/features/deep_linking/models/deep_link.dart`.

- [ ] **Step 1: Write the model**

```dart
// lib/features/deep_linking/models/deep_link.dart
import 'package:equatable/equatable.dart';

sealed class DeepLink extends Equatable {
  const DeepLink();
}

class RegisterDeviceLink extends DeepLink {
  final String token;
  const RegisterDeviceLink(this.token);
  @override
  List<Object?> get props => [token];
}

class SurveyLink extends DeepLink {
  final String shortCode;
  const SurveyLink(this.shortCode);
  @override
  List<Object?> get props => [shortCode];
}

class UnknownLink extends DeepLink {
  final Uri uri;
  const UnknownLink(this.uri);
  @override
  List<Object?> get props => [uri];
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/deep_linking/models/deep_link.dart
git commit -m "feat(deep_linking): add DeepLink sealed model"
```

---

## Task 4: `DeepLinkConfig`

**Files:** Create `lib/features/deep_linking/config/deep_link_config.dart`.

Host is injected at build time via `--dart-define=DEEP_LINK_HOST=...` (wired per flavor in Task 14/15). A fallback default is provided for unit tests and dev runs without a flavor.

- [ ] **Step 1: Write config**

```dart
// lib/features/deep_linking/config/deep_link_config.dart
class DeepLinkConfig {
  DeepLinkConfig._();

  /// Active host for App Links / Universal Links.
  /// Injected at build time per flavor via --dart-define=DEEP_LINK_HOST=...
  static const String expectedHost = String.fromEnvironment(
    'DEEP_LINK_HOST',
    defaultValue: 'survey-frontend.system2030.com',
  );

  static const List<String> supportedLocales = ['ar', 'en'];

  // Path constants (without leading locale).
  static const String registerDevicePath = '/register-device';
  static const String surveyPathPrefix = '/survey';
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/deep_linking/config/
git commit -m "feat(deep_linking): add DeepLinkConfig with build-time host"
```

---

## Task 5: `DeepLinkParser` — TDD

**Files:**
- Create: `lib/features/deep_linking/service/deep_link_parser.dart`
- Create: `test/features/deep_linking/deep_link_parser_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
// test/features/deep_linking/deep_link_parser_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/config/deep_link_config.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/models/deep_link.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/service/deep_link_parser.dart';

void main() {
  final host = DeepLinkConfig.expectedHost;

  group('DeepLinkParser', () {
    test('parses register-device with token', () {
      final uri = Uri.parse('https://$host/register-device?token=ABC123');
      final result = DeepLinkParser.parse(uri);
      expect(result, isA<RegisterDeviceLink>());
      expect((result as RegisterDeviceLink).token, 'ABC123');
    });

    test('parses register-device under locale prefix', () {
      final uri = Uri.parse('https://$host/ar/register-device?token=XYZ');
      final result = DeepLinkParser.parse(uri);
      expect(result, isA<RegisterDeviceLink>());
      expect((result as RegisterDeviceLink).token, 'XYZ');
    });

    test('returns UnknownLink when token is missing', () {
      final uri = Uri.parse('https://$host/register-device');
      expect(DeepLinkParser.parse(uri), isA<UnknownLink>());
    });

    test('returns UnknownLink when token is empty/whitespace', () {
      expect(
        DeepLinkParser.parse(Uri.parse('https://$host/register-device?token=')),
        isA<UnknownLink>(),
      );
      expect(
        DeepLinkParser.parse(Uri.parse('https://$host/register-device?token=%20')),
        isA<UnknownLink>(),
      );
    });

    test('parses /survey/<shortCode>', () {
      final uri = Uri.parse('https://$host/survey/ABC9z');
      final result = DeepLinkParser.parse(uri);
      expect(result, isA<SurveyLink>());
      expect((result as SurveyLink).shortCode, 'ABC9z');
    });

    test('parses /<locale>/survey/<shortCode>', () {
      final result = DeepLinkParser.parse(Uri.parse('https://$host/en/survey/XZ9'));
      expect(result, isA<SurveyLink>());
      expect((result as SurveyLink).shortCode, 'XZ9');
    });

    test('normalizes trailing slash and duplicate slashes', () {
      final result = DeepLinkParser.parse(Uri.parse('https://$host//survey//XZ9/'));
      expect(result, isA<SurveyLink>());
      expect((result as SurveyLink).shortCode, 'XZ9');
    });

    test('rejects non-https scheme', () {
      expect(
        DeepLinkParser.parse(Uri.parse('http://$host/register-device?token=x')),
        isA<UnknownLink>(),
      );
    });

    test('rejects cross-host link', () {
      expect(
        DeepLinkParser.parse(Uri.parse('https://evil.example.com/register-device?token=x')),
        isA<UnknownLink>(),
      );
    });

    test('rejects empty survey shortCode', () {
      expect(DeepLinkParser.parse(Uri.parse('https://$host/survey/')), isA<UnknownLink>());
      expect(DeepLinkParser.parse(Uri.parse('https://$host/survey')), isA<UnknownLink>());
    });

    test('unknown path returns UnknownLink', () {
      expect(
        DeepLinkParser.parse(Uri.parse('https://$host/something-else')),
        isA<UnknownLink>(),
      );
    });
  });
}
```

- [ ] **Step 2: Run tests — expect fail**

Run: `flutter test test/features/deep_linking/deep_link_parser_test.dart`
Expected: compile error (parser does not exist yet).

- [ ] **Step 3: Implement parser**

```dart
// lib/features/deep_linking/service/deep_link_parser.dart
import '../config/deep_link_config.dart';
import '../models/deep_link.dart';

class DeepLinkParser {
  DeepLinkParser._();

  static DeepLink parse(Uri uri) {
    if (uri.scheme != 'https') return UnknownLink(uri);
    if (uri.host != DeepLinkConfig.expectedHost) return UnknownLink(uri);

    final segments = _normalize(uri.pathSegments);
    if (segments.isEmpty) return UnknownLink(uri);

    final afterLocale = _stripLocale(segments);
    if (afterLocale.isEmpty) return UnknownLink(uri);

    // /register-device?token=...
    if (afterLocale.length == 1 && afterLocale.first == 'register-device') {
      final raw = uri.queryParameters['token'];
      final token = raw?.trim() ?? '';
      if (token.isEmpty) return UnknownLink(uri);
      return RegisterDeviceLink(token);
    }

    // /survey/<shortCode>
    if (afterLocale.length == 2 && afterLocale.first == 'survey') {
      final code = afterLocale[1].trim();
      if (code.isEmpty) return UnknownLink(uri);
      return SurveyLink(code);
    }

    return UnknownLink(uri);
  }

  static List<String> _normalize(List<String> segments) {
    return segments
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static List<String> _stripLocale(List<String> segments) {
    if (segments.isEmpty) return segments;
    final first = segments.first;
    if (DeepLinkConfig.supportedLocales.contains(first)) {
      return segments.sublist(1);
    }
    return segments;
  }
}
```

> Note: the `shortCode` comparison in tests is case-sensitive against `'ABC9z'` but `_normalize` lowercases. Change expected `shortCode` values in tests to lowercase before running (e.g., `'abc9z'`, `'xz9'`). Update `Task 5 Step 1` tests accordingly if you catch this during implementation — shortCodes on the backend are case-insensitive; the mobile side normalizes to lowercase. Update the expected values: `'ABC9z' → 'abc9z'`, `'XZ9' → 'xz9'`.

- [ ] **Step 4: Run tests — expect pass**

Run: `flutter test test/features/deep_linking/deep_link_parser_test.dart`
Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/deep_linking/service/deep_link_parser.dart test/features/deep_linking/deep_link_parser_test.dart
git commit -m "feat(deep_linking): add DeepLinkParser with tests"
```

---

## Task 6: `DeepLinkService` — TDD

Wraps `app_links`; exposes `initialLink()` + `linkStream`; applies a 2s dedup window.

**Files:**
- Create: `lib/features/deep_linking/service/deep_link_service.dart`
- Create: `test/features/deep_linking/deep_link_service_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
// test/features/deep_linking/deep_link_service_test.dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/service/deep_link_service.dart';

void main() {
  group('DeepLinkService dedup', () {
    test('drops identical URI within 2 seconds', () async {
      final controller = StreamController<Uri>();
      final service = DeepLinkService.test(
        initial: null,
        sourceStream: controller.stream,
        clock: () => DateTime(2026, 1, 1, 0, 0, 0),
      );

      final received = <Uri>[];
      final sub = service.linkStream.listen(received.add);

      final u = Uri.parse('https://example.com/a');
      controller.add(u);
      controller.add(u);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(received, [u]);
      await sub.cancel();
      await controller.close();
    });

    test('does not drop when outside window', () async {
      final controller = StreamController<Uri>();
      var now = DateTime(2026, 1, 1, 0, 0, 0);
      final service = DeepLinkService.test(
        initial: null,
        sourceStream: controller.stream,
        clock: () => now,
      );

      final received = <Uri>[];
      final sub = service.linkStream.listen(received.add);

      final u = Uri.parse('https://example.com/a');
      controller.add(u);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      now = now.add(const Duration(seconds: 3));
      controller.add(u);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(received.length, 2);
      await sub.cancel();
      await controller.close();
    });

    test('passes distinct URIs through immediately', () async {
      final controller = StreamController<Uri>();
      final service = DeepLinkService.test(
        initial: null,
        sourceStream: controller.stream,
        clock: () => DateTime(2026, 1, 1),
      );

      final received = <Uri>[];
      final sub = service.linkStream.listen(received.add);

      controller.add(Uri.parse('https://example.com/a'));
      controller.add(Uri.parse('https://example.com/b'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(received.length, 2);
      await sub.cancel();
      await controller.close();
    });
  });
}
```

- [ ] **Step 2: Run tests — expect fail**

Run: `flutter test test/features/deep_linking/deep_link_service_test.dart`
Expected: compile error.

- [ ] **Step 3: Implement service**

```dart
// lib/features/deep_linking/service/deep_link_service.dart
import 'dart:async';
import 'package:app_links/app_links.dart';

typedef _Clock = DateTime Function();

class DeepLinkService {
  static const Duration _dedupWindow = Duration(seconds: 2);

  final AppLinks? _appLinks;
  final Stream<Uri>? _sourceStreamOverride;
  final Uri? _initialOverride;
  final _Clock _clock;

  Uri? _lastUri;
  DateTime? _lastAt;

  late final Stream<Uri> _filtered;

  DeepLinkService()
      : _appLinks = AppLinks(),
        _sourceStreamOverride = null,
        _initialOverride = null,
        _clock = DateTime.now {
    _filtered = _appLinks!.uriLinkStream.where(_notDuplicate);
  }

  DeepLinkService.test({
    required Uri? initial,
    required Stream<Uri> sourceStream,
    required _Clock clock,
  })  : _appLinks = null,
        _initialOverride = initial,
        _sourceStreamOverride = sourceStream,
        _clock = clock {
    _filtered = _sourceStreamOverride!.where(_notDuplicate);
  }

  Stream<Uri> get linkStream => _filtered;

  Future<Uri?> initialLink() async {
    if (_appLinks != null) {
      final uri = await _appLinks!.getInitialAppLink();
      if (uri == null) return null;
      if (!_notDuplicate(uri)) return null;
      return uri;
    }
    final initial = _initialOverride;
    if (initial != null && _notDuplicate(initial)) return initial;
    return null;
  }

  /// Called on AppLifecycleState.resumed to pick up any delivered-while-suspended link.
  Future<Uri?> refreshOnResume() => initialLink();

  bool _notDuplicate(Uri uri) {
    final now = _clock();
    final last = _lastUri;
    final lastAt = _lastAt;
    if (last != null &&
        lastAt != null &&
        last == uri &&
        now.difference(lastAt) < _dedupWindow) {
      return false;
    }
    _lastUri = uri;
    _lastAt = now;
    return true;
  }
}
```

- [ ] **Step 4: Run tests — expect pass**

Run: `flutter test test/features/deep_linking/deep_link_service_test.dart`
Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/deep_linking/service/deep_link_service.dart test/features/deep_linking/deep_link_service_test.dart
git commit -m "feat(deep_linking): add DeepLinkService with dedup"
```

---

## Task 7: `DeepLinkBloc` — events, states, transitions (TDD)

The bloc needs a way to ask "is a survey being answered right now?" without depending on `assignment/` internals. Use a callback injected at construction (Dart-level seam; wiring at app root reads the assignment bloc).

**Files:**
- Create: `lib/features/deep_linking/bloc/deep_link_event.dart`
- Create: `lib/features/deep_linking/bloc/deep_link_state.dart`
- Create: `lib/features/deep_linking/bloc/deep_link_bloc.dart`
- Create: `test/features/deep_linking/deep_link_bloc_test.dart`

- [ ] **Step 1: Write event file**

```dart
// lib/features/deep_linking/bloc/deep_link_event.dart
import 'package:equatable/equatable.dart';

sealed class DeepLinkEvent extends Equatable {
  const DeepLinkEvent();
  @override
  List<Object?> get props => const [];
}

class DeepLinkReceived extends DeepLinkEvent {
  final Uri uri;
  const DeepLinkReceived(this.uri);
  @override
  List<Object?> get props => [uri];
}

class ConfirmDiscardActiveSurvey extends DeepLinkEvent {
  final String shortCode;
  const ConfirmDiscardActiveSurvey(this.shortCode);
  @override
  List<Object?> get props => [shortCode];
}

class CancelDiscardActiveSurvey extends DeepLinkEvent {
  const CancelDiscardActiveSurvey();
}

class NavigationHandled extends DeepLinkEvent {
  const NavigationHandled();
}
```

- [ ] **Step 2: Write state file**

```dart
// lib/features/deep_linking/bloc/deep_link_state.dart
import 'package:equatable/equatable.dart';

sealed class DeepLinkState extends Equatable {
  const DeepLinkState();
  @override
  List<Object?> get props => const [];
}

class DeepLinkIdle extends DeepLinkState {
  const DeepLinkIdle();
}

class NavigateToDeviceRegistration extends DeepLinkState {
  final String token;
  const NavigateToDeviceRegistration(this.token);
  @override
  List<Object?> get props => [token];
}

class NavigateToSurvey extends DeepLinkState {
  final String shortCode;
  const NavigateToSurvey(this.shortCode);
  @override
  List<Object?> get props => [shortCode];
}

class AwaitingDiscardConfirmation extends DeepLinkState {
  final String pendingShortCode;
  const AwaitingDiscardConfirmation(this.pendingShortCode);
  @override
  List<Object?> get props => [pendingShortCode];
}
```

- [ ] **Step 3: Write failing tests**

```dart
// test/features/deep_linking/deep_link_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/bloc/deep_link_bloc.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/bloc/deep_link_event.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/bloc/deep_link_state.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/config/deep_link_config.dart';

void main() {
  final host = DeepLinkConfig.expectedHost;

  DeepLinkBloc make({bool surveyInProgress = false}) => DeepLinkBloc(
        isSurveyInProgress: () => surveyInProgress,
      );

  group('DeepLinkBloc', () {
    blocTest<DeepLinkBloc, DeepLinkState>(
      'register-device → NavigateToDeviceRegistration',
      build: () => make(),
      act: (b) => b.add(DeepLinkReceived(Uri.parse('https://$host/register-device?token=abc'))),
      expect: () => [const NavigateToDeviceRegistration('abc')],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'survey link with no active survey → NavigateToSurvey',
      build: () => make(),
      act: (b) => b.add(DeepLinkReceived(Uri.parse('https://$host/survey/xyz'))),
      expect: () => [const NavigateToSurvey('xyz')],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'survey link while active survey → AwaitingDiscardConfirmation',
      build: () => make(surveyInProgress: true),
      act: (b) => b.add(DeepLinkReceived(Uri.parse('https://$host/survey/xyz'))),
      expect: () => [const AwaitingDiscardConfirmation('xyz')],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'confirm discard → NavigateToSurvey',
      build: () => make(surveyInProgress: true),
      seed: () => const AwaitingDiscardConfirmation('xyz'),
      act: (b) => b.add(const ConfirmDiscardActiveSurvey('xyz')),
      expect: () => [const NavigateToSurvey('xyz')],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'cancel discard → Idle',
      build: () => make(surveyInProgress: true),
      seed: () => const AwaitingDiscardConfirmation('xyz'),
      act: (b) => b.add(const CancelDiscardActiveSurvey()),
      expect: () => [const DeepLinkIdle()],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'last-link-wins: new link while awaiting confirmation supersedes',
      build: () => make(surveyInProgress: true),
      seed: () => const AwaitingDiscardConfirmation('old'),
      act: (b) => b.add(DeepLinkReceived(Uri.parse('https://$host/survey/new'))),
      expect: () => [const AwaitingDiscardConfirmation('new')],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'unknown link does not emit',
      build: () => make(),
      act: (b) => b.add(DeepLinkReceived(Uri.parse('https://evil.example.com/x'))),
      expect: () => <DeepLinkState>[],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'NavigationHandled clears nav state',
      build: () => make(),
      seed: () => const NavigateToSurvey('xyz'),
      act: (b) => b.add(const NavigationHandled()),
      expect: () => [const DeepLinkIdle()],
    );
  });
}
```

- [ ] **Step 4: Add `bloc_test` dev dependency**

Edit `pubspec.yaml` under `dev_dependencies:`:

```yaml
  bloc_test: ^9.1.7
```

Run: `flutter pub get`

- [ ] **Step 5: Run tests — expect fail**

Run: `flutter test test/features/deep_linking/deep_link_bloc_test.dart`
Expected: compile error.

- [ ] **Step 6: Implement bloc**

```dart
// lib/features/deep_linking/bloc/deep_link_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/deep_link.dart';
import '../service/deep_link_parser.dart';
import 'deep_link_event.dart';
import 'deep_link_state.dart';

typedef SurveyInProgressCheck = bool Function();

class DeepLinkBloc extends Bloc<DeepLinkEvent, DeepLinkState> {
  final SurveyInProgressCheck isSurveyInProgress;

  DeepLinkBloc({required this.isSurveyInProgress}) : super(const DeepLinkIdle()) {
    on<DeepLinkReceived>(_onReceived);
    on<ConfirmDiscardActiveSurvey>(_onConfirm);
    on<CancelDiscardActiveSurvey>(_onCancel);
    on<NavigationHandled>((_, emit) => emit(const DeepLinkIdle()));
  }

  void _onReceived(DeepLinkReceived event, Emitter<DeepLinkState> emit) {
    final link = DeepLinkParser.parse(event.uri);
    switch (link) {
      case RegisterDeviceLink(:final token):
        emit(NavigateToDeviceRegistration(token));
      case SurveyLink(:final shortCode):
        if (isSurveyInProgress()) {
          emit(AwaitingDiscardConfirmation(shortCode));
        } else {
          emit(NavigateToSurvey(shortCode));
        }
      case UnknownLink():
        // Silent drop — caller may log separately.
        return;
    }
  }

  void _onConfirm(ConfirmDiscardActiveSurvey event, Emitter<DeepLinkState> emit) {
    emit(NavigateToSurvey(event.shortCode));
  }

  void _onCancel(CancelDiscardActiveSurvey event, Emitter<DeepLinkState> emit) {
    emit(const DeepLinkIdle());
  }
}
```

- [ ] **Step 7: Run tests — expect pass**

Run: `flutter test test/features/deep_linking/deep_link_bloc_test.dart`
Expected: all pass.

- [ ] **Step 8: Commit**

```bash
git add lib/features/deep_linking/bloc/ test/features/deep_linking/deep_link_bloc_test.dart pubspec.yaml pubspec.lock
git commit -m "feat(deep_linking): add DeepLinkBloc with gating and last-link-wins"
```

---

## Task 8: Add `surveyDeepLinkPath` route constant

**Files:** Modify `lib/core/routes/app_routes.dart`.

- [ ] **Step 1: Add constant**

Insert after `surveyAnsweringPath`:

```dart
  static const String surveyDeepLinkPath = '/survey-deep-link';
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/routes/app_routes.dart
git commit -m "feat(routes): add surveyDeepLinkPath"
```

---

## Task 9: Public survey-by-shortCode repository method

The existing `validatePublicLink` hits the **authorized** `/researcher/public-link/:short_code`. Deep-link flow is auth-independent → we need the public `/public-link/:short_code` endpoint.

**Files:** Modify `lib/features/public_links/repository/public_links_online_repository.dart`.

- [ ] **Step 1: Inspect `ValidatedPublicLink` & `APIRequest`**

Read `lib/features/public_links/models/validated_public_link.dart` and `lib/data/network/api_request.dart` to confirm `AuthorizationOption.unauthenticated` (or equivalent) exists. If a distinct response shape is returned by the public endpoint, create a new model class next to `ValidatedPublicLink` called `PublicSurveyDeepLink` with the fields the backend returns; otherwise reuse `ValidatedPublicLink`. This task assumes reuse — adjust if the shapes differ.

- [ ] **Step 2: Add method**

In `public_links_online_repository.dart`, after `validatePublicLink`, add:

```dart
  /// Public (unauthenticated) survey resolution by short code.
  /// Used by the deep-link flow: GET /public-link/:short_code
  static Future<ValidatedPublicLink> getPublicSurveyByShortCode(
    String shortCode,
  ) async {
    final apiRequest = APIRequest(
      path: '/public-link/$shortCode',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.unauthenticated,
    );

    final response = await apiRequest.send();
    final data = response.data['data'] ?? response.data;
    return ValidatedPublicLink.fromJson(data as Map<String, dynamic>);
  }
```

If `AuthorizationOption.unauthenticated` is not the exact name in the codebase, substitute the existing unauthenticated option (e.g., `AuthorizationOption.none`).

- [ ] **Step 3: Commit**

```bash
git add lib/features/public_links/repository/public_links_online_repository.dart
git commit -m "feat(public_links): add public getPublicSurveyByShortCode"
```

---

## Task 10: `SurveyByShortCodeBloc` — TDD

Handles loading, offline, auto-retry on reconnect.

**Files:**
- Create: `lib/features/assignment/bloc/survey_by_short_code/survey_by_short_code_event.dart`
- Create: `lib/features/assignment/bloc/survey_by_short_code/survey_by_short_code_state.dart`
- Create: `lib/features/assignment/bloc/survey_by_short_code/survey_by_short_code_bloc.dart`
- Create: `test/features/assignment/survey_by_short_code_bloc_test.dart`

- [ ] **Step 1: Event file**

```dart
// lib/features/assignment/bloc/survey_by_short_code/survey_by_short_code_event.dart
import 'package:equatable/equatable.dart';

sealed class SurveyByShortCodeEvent extends Equatable {
  const SurveyByShortCodeEvent();
  @override
  List<Object?> get props => const [];
}

class FetchSurvey extends SurveyByShortCodeEvent {
  final String shortCode;
  const FetchSurvey(this.shortCode);
  @override
  List<Object?> get props => [shortCode];
}

class RetrySurveyFetch extends SurveyByShortCodeEvent {
  const RetrySurveyFetch();
}

class ConnectivityRestored extends SurveyByShortCodeEvent {
  const ConnectivityRestored();
}
```

- [ ] **Step 2: State file**

```dart
// lib/features/assignment/bloc/survey_by_short_code/survey_by_short_code_state.dart
import 'package:equatable/equatable.dart';
import '../../../public_links/models/validated_public_link.dart';

enum SurveyFetchErrorKind { offline, notFound, serverError }

sealed class SurveyByShortCodeState extends Equatable {
  const SurveyByShortCodeState();
  @override
  List<Object?> get props => const [];
}

class SurveyByShortCodeIdle extends SurveyByShortCodeState {
  const SurveyByShortCodeIdle();
}

class SurveyByShortCodeLoading extends SurveyByShortCodeState {
  final String shortCode;
  const SurveyByShortCodeLoading(this.shortCode);
  @override
  List<Object?> get props => [shortCode];
}

class SurveyByShortCodeLoaded extends SurveyByShortCodeState {
  final String shortCode;
  final ValidatedPublicLink result;
  const SurveyByShortCodeLoaded(this.shortCode, this.result);
  @override
  List<Object?> get props => [shortCode, result];
}

class SurveyByShortCodeError extends SurveyByShortCodeState {
  final String shortCode;
  final SurveyFetchErrorKind kind;
  const SurveyByShortCodeError(this.shortCode, this.kind);
  @override
  List<Object?> get props => [shortCode, kind];
}
```

- [ ] **Step 3: Write failing tests**

```dart
// test/features/assignment/survey_by_short_code_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/bloc/survey_by_short_code/survey_by_short_code_bloc.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/bloc/survey_by_short_code/survey_by_short_code_event.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/bloc/survey_by_short_code/survey_by_short_code_state.dart';
import 'package:king_abdulaziz_center_survey_app/features/public_links/models/validated_public_link.dart';

class _FakeFetcher {
  SurveyFetchOutcome Function(String) impl;
  _FakeFetcher(this.impl);
  Future<SurveyFetchOutcome> call(String code) async => impl(code);
}

void main() {
  final fakeLink = ValidatedPublicLink.fromJson(const {'short_code': 'x'}); // adapt to real schema

  group('SurveyByShortCodeBloc', () {
    blocTest<SurveyByShortCodeBloc, SurveyByShortCodeState>(
      'FetchSurvey success → Loading → Loaded',
      build: () {
        final f = _FakeFetcher((c) => SurveyFetchOutcome.success(fakeLink));
        return SurveyByShortCodeBloc(fetcher: f.call);
      },
      act: (b) => b.add(const FetchSurvey('abc')),
      expect: () => [
        const SurveyByShortCodeLoading('abc'),
        isA<SurveyByShortCodeLoaded>()
            .having((s) => s.shortCode, 'shortCode', 'abc'),
      ],
    );

    blocTest<SurveyByShortCodeBloc, SurveyByShortCodeState>(
      'offline → Error(offline)',
      build: () => SurveyByShortCodeBloc(
        fetcher: (_) async => SurveyFetchOutcome.offline(),
      ),
      act: (b) => b.add(const FetchSurvey('abc')),
      expect: () => [
        const SurveyByShortCodeLoading('abc'),
        const SurveyByShortCodeError('abc', SurveyFetchErrorKind.offline),
      ],
    );

    blocTest<SurveyByShortCodeBloc, SurveyByShortCodeState>(
      'notFound → Error(notFound)',
      build: () => SurveyByShortCodeBloc(
        fetcher: (_) async => SurveyFetchOutcome.notFound(),
      ),
      act: (b) => b.add(const FetchSurvey('abc')),
      expect: () => [
        const SurveyByShortCodeLoading('abc'),
        const SurveyByShortCodeError('abc', SurveyFetchErrorKind.notFound),
      ],
    );

    blocTest<SurveyByShortCodeBloc, SurveyByShortCodeState>(
      'duplicate FetchSurvey while Loading is a no-op',
      build: () {
        return SurveyByShortCodeBloc(
          fetcher: (_) async {
            await Future.delayed(const Duration(milliseconds: 50));
            return SurveyFetchOutcome.success(fakeLink);
          },
        );
      },
      act: (b) async {
        b.add(const FetchSurvey('abc'));
        b.add(const FetchSurvey('abc'));
        await Future.delayed(const Duration(milliseconds: 100));
      },
      expect: () => [
        const SurveyByShortCodeLoading('abc'),
        isA<SurveyByShortCodeLoaded>(),
      ],
    );

    blocTest<SurveyByShortCodeBloc, SurveyByShortCodeState>(
      'ConnectivityRestored while Error(offline) auto-retries',
      build: () {
        var attempt = 0;
        return SurveyByShortCodeBloc(
          fetcher: (_) async {
            attempt++;
            if (attempt == 1) return SurveyFetchOutcome.offline();
            return SurveyFetchOutcome.success(fakeLink);
          },
        );
      },
      act: (b) async {
        b.add(const FetchSurvey('abc'));
        await Future.delayed(const Duration(milliseconds: 10));
        b.add(const ConnectivityRestored());
      },
      expect: () => [
        const SurveyByShortCodeLoading('abc'),
        const SurveyByShortCodeError('abc', SurveyFetchErrorKind.offline),
        const SurveyByShortCodeLoading('abc'),
        isA<SurveyByShortCodeLoaded>(),
      ],
    );
  });
}
```

> The `fakeLink` construction in tests must match the real `ValidatedPublicLink.fromJson` contract — adjust the JSON body to the smallest valid payload. If that's too invasive, replace with a constructor or a factory on `ValidatedPublicLink` for test use.

- [ ] **Step 4: Run tests — expect fail**

Run: `flutter test test/features/assignment/survey_by_short_code_bloc_test.dart`
Expected: compile error.

- [ ] **Step 5: Implement bloc**

```dart
// lib/features/assignment/bloc/survey_by_short_code/survey_by_short_code_bloc.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../public_links/models/validated_public_link.dart';
import '../../../public_links/repository/public_links_online_repository.dart';
import 'survey_by_short_code_event.dart';
import 'survey_by_short_code_state.dart';

class SurveyFetchOutcome {
  final ValidatedPublicLink? data;
  final SurveyFetchErrorKind? error;
  const SurveyFetchOutcome._(this.data, this.error);
  factory SurveyFetchOutcome.success(ValidatedPublicLink data) =>
      SurveyFetchOutcome._(data, null);
  factory SurveyFetchOutcome.offline() =>
      const SurveyFetchOutcome._(null, SurveyFetchErrorKind.offline);
  factory SurveyFetchOutcome.notFound() =>
      const SurveyFetchOutcome._(null, SurveyFetchErrorKind.notFound);
  factory SurveyFetchOutcome.serverError() =>
      const SurveyFetchOutcome._(null, SurveyFetchErrorKind.serverError);
}

typedef SurveyFetcher = Future<SurveyFetchOutcome> Function(String shortCode);

class SurveyByShortCodeBloc
    extends Bloc<SurveyByShortCodeEvent, SurveyByShortCodeState> {
  final SurveyFetcher fetcher;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  SurveyByShortCodeBloc({SurveyFetcher? fetcher})
      : fetcher = fetcher ?? _defaultFetcher,
        super(const SurveyByShortCodeIdle()) {
    on<FetchSurvey>(_onFetch);
    on<RetrySurveyFetch>(_onRetry);
    on<ConnectivityRestored>(_onConnectivity);

    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) add(const ConnectivityRestored());
    });
  }

  Future<void> _onFetch(
      FetchSurvey event, Emitter<SurveyByShortCodeState> emit) async {
    final current = state;
    if (current is SurveyByShortCodeLoading &&
        current.shortCode == event.shortCode) return;
    if (current is SurveyByShortCodeLoaded &&
        current.shortCode == event.shortCode) return;

    emit(SurveyByShortCodeLoading(event.shortCode));
    final outcome = await fetcher(event.shortCode);
    if (outcome.data != null) {
      emit(SurveyByShortCodeLoaded(event.shortCode, outcome.data!));
    } else {
      emit(SurveyByShortCodeError(event.shortCode, outcome.error!));
    }
  }

  Future<void> _onRetry(
      RetrySurveyFetch event, Emitter<SurveyByShortCodeState> emit) async {
    final s = state;
    if (s is SurveyByShortCodeError) {
      add(FetchSurvey(s.shortCode));
    }
  }

  Future<void> _onConnectivity(
      ConnectivityRestored event, Emitter<SurveyByShortCodeState> emit) async {
    final s = state;
    if (s is SurveyByShortCodeError && s.kind == SurveyFetchErrorKind.offline) {
      add(FetchSurvey(s.shortCode));
    }
  }

  @override
  Future<void> close() {
    _connSub?.cancel();
    return super.close();
  }

  static Future<SurveyFetchOutcome> _defaultFetcher(String code) async {
    try {
      final data = await PublicLinksOnlineRepository.getPublicSurveyByShortCode(code);
      return SurveyFetchOutcome.success(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return SurveyFetchOutcome.offline();
      }
      if (e.response?.statusCode == 404) return SurveyFetchOutcome.notFound();
      return SurveyFetchOutcome.serverError();
    } catch (_) {
      return SurveyFetchOutcome.serverError();
    }
  }
}
```

- [ ] **Step 6: Run tests — expect pass**

Run: `flutter test test/features/assignment/survey_by_short_code_bloc_test.dart`
Expected: all pass.

- [ ] **Step 7: Commit**

```bash
git add lib/features/assignment/bloc/survey_by_short_code/ test/features/assignment/survey_by_short_code_bloc_test.dart
git commit -m "feat(assignment): add SurveyByShortCodeBloc with offline auto-retry"
```

---

## Task 11: `SurveyDeepLinkPage`

Thin orchestration page: renders spinner / error / offline / the existing `SurveyAnsweringPage`.

**Files:** Create `lib/features/assignment/presentation/pages/survey_deep_link_page.dart`.

> **Before coding**: read `lib/features/assignment/presentation/pages/survey_answering_page.dart` and `lib/features/public_links/models/validated_public_link.dart` to understand how to construct `SurveyAnsweringPage` from a `ValidatedPublicLink`. The spec assumes the `ValidatedPublicLink` carries a `Survey` payload (or can be mapped to one) plus an optional `responseId`. If it carries only lightweight metadata, add a follow-up repository call in `_defaultFetcher` to the `/public-link/:short_code/start` endpoint that returns the full survey + response id — treat this as an expected implementation-phase refinement.

- [ ] **Step 1: Implement page**

```dart
// lib/features/assignment/presentation/pages/survey_deep_link_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/survey_by_short_code/survey_by_short_code_bloc.dart';
import '../../bloc/survey_by_short_code/survey_by_short_code_event.dart';
import '../../bloc/survey_by_short_code/survey_by_short_code_state.dart';
import 'survey_answering_page.dart';

class SurveyDeepLinkPage extends StatelessWidget {
  final String shortCode;
  const SurveyDeepLinkPage({super.key, required this.shortCode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SurveyByShortCodeBloc()..add(FetchSurvey(shortCode)),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<SurveyByShortCodeBloc, SurveyByShortCodeState>(
          builder: (context, state) {
            return switch (state) {
              SurveyByShortCodeIdle() ||
              SurveyByShortCodeLoading() =>
                const Center(child: CircularProgressIndicator()),
              SurveyByShortCodeLoaded(result: final r) =>
                _LoadedView(result: r),
              SurveyByShortCodeError(kind: final k) => _ErrorView(
                  kind: k,
                  onRetry: () =>
                      context.read<SurveyByShortCodeBloc>().add(const RetrySurveyFetch()),
                ),
            };
          },
        ),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  // Adapt constructor signature to match ValidatedPublicLink → SurveyAnsweringPage contract.
  // Placeholder shown here; see pre-task note.
  final dynamic result;
  const _LoadedView({required this.result});

  @override
  Widget build(BuildContext context) {
    // Map `result` into the Survey + responseId SurveyAnsweringPage expects.
    // Exact mapping depends on ValidatedPublicLink shape — refine during impl.
    return const Placeholder(); // TODO-IMPL: replace with SurveyAnsweringPage(survey: ..., responseId: ...)
  }
}

class _ErrorView extends StatelessWidget {
  final SurveyFetchErrorKind kind;
  final VoidCallback onRetry;
  const _ErrorView({required this.kind, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final message = switch (kind) {
      SurveyFetchErrorKind.offline => 'No internet connection',
      SurveyFetchErrorKind.notFound => 'Survey not found',
      SurveyFetchErrorKind.serverError => 'Something went wrong',
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
```

> The `TODO-IMPL` in `_LoadedView` is intentional and must be resolved in this task by reading the real shape of `ValidatedPublicLink` and the existing `SurveyAnsweringPage` constructor. Replace the `Placeholder` with the concrete widget. If the mapping requires a second backend call (to `/:short_code/start`), add it to `SurveyByShortCodeBloc`'s fetcher before marking this task done.

- [ ] **Step 2: Commit**

```bash
git add lib/features/assignment/presentation/pages/survey_deep_link_page.dart
git commit -m "feat(assignment): add SurveyDeepLinkPage"
```

---

## Task 12: Register routes, update device-registration builder

**Files:** Modify `lib/core/routes/app_pages.dart`.

- [ ] **Step 1: Import new page and args**

At the top of `app_pages.dart`:

```dart
import '../../features/assignment/presentation/pages/survey_deep_link_page.dart';
import '../../features/deep_linking/models/device_registration_args.dart';
import '../../features/deep_linking/models/survey_deep_link_args.dart';
```

- [ ] **Step 2: Update `deviceRegistrationPath` builder**

Replace the existing `GoRoute` for `Routes.deviceRegistrationPath`:

```dart
    GoRoute(
      path: Routes.deviceRegistrationPath,
      builder: (context, state) {
        final args = state.extra;
        if (args is DeviceRegistrationArgs) {
          return DeviceRegistrationPage(
            token: args.token,
            fromDeepLink: args.fromDeepLink,
          );
        }
        // Legacy query-param entry preserved for backwards compatibility.
        final token = state.uri.queryParameters['token'];
        return DeviceRegistrationPage(token: token);
      },
    ),
```

> `DeviceRegistrationPage` currently has only `token`. Task 13 adds the `fromDeepLink` parameter; the above builder assumes it.

- [ ] **Step 3: Add `surveyDeepLinkPath` route**

After the existing `surveyAnsweringPath` route, add:

```dart
    GoRoute(
      path: Routes.surveyDeepLinkPath,
      builder: (context, state) {
        final args = state.extra as SurveyDeepLinkArgs;
        return SurveyDeepLinkPage(shortCode: args.shortCode);
      },
    ),
```

- [ ] **Step 4: Commit**

```bash
git add lib/core/routes/app_pages.dart
git commit -m "feat(routes): register survey deep link route, typed args for device registration"
```

---

## Task 13: `DeviceRegistrationPage` updates

**Files:** Modify `lib/features/device_registration/presentation/device_registration_page.dart`.

> Read the file first to understand its current structure (bloc wiring, token field widget).

- [ ] **Step 1: Add `fromDeepLink`**

Change the constructor signature:

```dart
  final String? token;
  final bool fromDeepLink;

  const DeviceRegistrationPage({
    super.key,
    this.token,
    this.fromDeepLink = false,
  });
```

- [ ] **Step 2: Wire read-only token**

In the build method, where the token field is rendered: pass `readOnly: widget.fromDeepLink` (or equivalent) and set the initial value to `widget.token`. If the page auto-submits on entry today, add a guard that only auto-submits when `fromDeepLink && token != null`.

Add a small helper text when `fromDeepLink`:

```dart
if (widget.fromDeepLink)
  Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      'Scanned from link',
      style: Theme.of(context).textTheme.bodySmall,
    ),
  ),
```

- [ ] **Step 3: Surface `InvalidToken` / `ExpiredToken` / `AlreadyRegistered`**

Locate the existing `BlocListener`/`BlocBuilder` on `ValidateTokenBloc` (or the equivalent bloc that owns token validation). Add UI for each of the three terminal error states — minimal dialog or inline error with:

- `InvalidToken` / `ExpiredToken` → message + primary "Scan again" button routing to `Routes.qrScannerPath`, secondary "Back" button routing `context.go(Routes.splashPath)` (kept until Task 16 adds the global session refresh).
- `AlreadyRegistered` → non-destructive info banner with a "Back to home" button routing to `Routes.mainScreenPath` (or `splashPath`).

If the existing bloc does not distinguish these states, add the distinguishing logic based on the backend response code/message.

- [ ] **Step 4: Run the app manually; verify device registration page still loads from non-deep-link path (QR scanner)**

Run: `flutter run --flavor dev` (after Task 14 is done) — or until then just `flutter run`.
Verify: scanning via existing QR scanner still routes to device registration with token pre-filled but **editable** (because `fromDeepLink == false`).

- [ ] **Step 5: Commit**

```bash
git add lib/features/device_registration/presentation/device_registration_page.dart
git commit -m "feat(device_registration): support fromDeepLink with read-only token + error states"
```

---

## Task 14: Android — flavors + manifest

**Files:**
- Modify: `android/app/build.gradle`
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Inspect current `build.gradle`**

Read `android/app/build.gradle` to identify the `android { ... }` block and `defaultConfig`.

- [ ] **Step 2: Add flavor dimensions and flavors**

Inside the `android { }` block, after `defaultConfig { }`, add:

```gradle
    flavorDimensions "env"
    productFlavors {
        dev {
            dimension "env"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            manifestPlaceholders = [
                deepLinkHost: "dev.survey-frontend.system2030.com",
                appLabelSuffix: " Dev"
            ]
        }
        staging {
            dimension "env"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            manifestPlaceholders = [
                deepLinkHost: "staging.survey-frontend.system2030.com",
                appLabelSuffix: " Staging"
            ]
        }
        prod {
            dimension "env"
            manifestPlaceholders = [
                deepLinkHost: "survey-frontend.system2030.com",
                appLabelSuffix: ""
            ]
        }
    }
```

- [ ] **Step 3: Pass `DEEP_LINK_HOST` to Dart**

Each `flutter run`/`flutter build` must pass the matching `--dart-define`. Document in `README.md`:

```
flutter run --flavor dev     --dart-define=DEEP_LINK_HOST=dev.survey-frontend.system2030.com
flutter run --flavor staging --dart-define=DEEP_LINK_HOST=staging.survey-frontend.system2030.com
flutter run --flavor prod    --dart-define=DEEP_LINK_HOST=survey-frontend.system2030.com
```

Optionally add a shell script or `Makefile` at repo root with these commands. For this plan, add them to `README.md` under a "Running" section.

- [ ] **Step 4: Update AndroidManifest.xml**

Open `android/app/src/main/AndroidManifest.xml`. Inside the launcher `<activity>` (named `.MainActivity`), alongside the existing `<intent-filter>` for `MAIN`/`LAUNCHER`, add:

```xml
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <category android:name="android.intent.category.BROWSABLE"/>
                <data android:scheme="https"
                      android:host="${deepLinkHost}"
                      android:pathPrefix="/register-device"/>
                <data android:scheme="https"
                      android:host="${deepLinkHost}"
                      android:pathPrefix="/survey"/>
                <data android:scheme="https"
                      android:host="${deepLinkHost}"
                      android:pathPrefix="/ar/register-device"/>
                <data android:scheme="https"
                      android:host="${deepLinkHost}"
                      android:pathPrefix="/ar/survey"/>
                <data android:scheme="https"
                      android:host="${deepLinkHost}"
                      android:pathPrefix="/en/register-device"/>
                <data android:scheme="https"
                      android:host="${deepLinkHost}"
                      android:pathPrefix="/en/survey"/>
            </intent-filter>
```

- [ ] **Step 5: Build all three flavors**

Run (one at a time):

```bash
flutter build apk --flavor dev     --dart-define=DEEP_LINK_HOST=dev.survey-frontend.system2030.com     --debug
flutter build apk --flavor staging --dart-define=DEEP_LINK_HOST=staging.survey-frontend.system2030.com --debug
flutter build apk --flavor prod    --dart-define=DEEP_LINK_HOST=survey-frontend.system2030.com        --debug
```

Expected: each build succeeds.

- [ ] **Step 6: Coordinate `assetlinks.json` hosting**

Add a checklist item in `docs/superpowers/specs/2026-04-20-deep-linking-design.md` §15 (already present) — confirm with frontend team that `/.well-known/assetlinks.json` is hosted at each domain with the correct package name (`com.rs4it.survey.dev`, `.staging`, production) and SHA256 signing fingerprints. This is a blocking prerequisite for `android:autoVerify="true"` to succeed.

- [ ] **Step 7: Commit**

```bash
git add android/ README.md
git commit -m "build(android): add env flavors + App Links intent filters"
```

---

## Task 15: iOS — build configurations + entitlements

**Files:**
- Create: `ios/Flutter/Dev.xcconfig`, `ios/Flutter/Staging.xcconfig`, `ios/Flutter/Prod.xcconfig`
- Modify: `ios/Runner/Runner.entitlements`
- Modify: `ios/Runner.xcodeproj/project.pbxproj` (via Xcode UI)

- [ ] **Step 1: Create per-flavor xcconfigs**

```
# ios/Flutter/Dev.xcconfig
#include "Generated.xcconfig"
DEEP_LINK_HOST = dev.survey-frontend.system2030.com
PRODUCT_BUNDLE_IDENTIFIER = $(PRODUCT_BUNDLE_IDENTIFIER_BASE).dev
```

```
# ios/Flutter/Staging.xcconfig
#include "Generated.xcconfig"
DEEP_LINK_HOST = staging.survey-frontend.system2030.com
PRODUCT_BUNDLE_IDENTIFIER = $(PRODUCT_BUNDLE_IDENTIFIER_BASE).staging
```

```
# ios/Flutter/Prod.xcconfig
#include "Generated.xcconfig"
DEEP_LINK_HOST = survey-frontend.system2030.com
PRODUCT_BUNDLE_IDENTIFIER = $(PRODUCT_BUNDLE_IDENTIFIER_BASE)
```

- [ ] **Step 2: Create build configurations in Xcode**

Open `ios/Runner.xcworkspace` in Xcode:

1. Select the Runner project → **Info** tab → **Configurations** section.
2. Duplicate existing `Debug` into `Debug-Dev`, `Debug-Staging`, `Debug-Prod`. Do the same for `Release` and `Profile`.
3. For each new configuration, set the xcconfig at the project level to the matching file from Step 1.
4. Create three schemes: `Runner-Dev`, `Runner-Staging`, `Runner-Prod` (Product → Scheme → Manage Schemes → +). Assign each scheme's `Run`/`Test`/`Profile`/`Archive` to the matching `Debug-<flavor>`/`Release-<flavor>`/`Profile-<flavor>` configuration.
5. Ensure the schemes are **Shared**.

- [ ] **Step 3: Update entitlements**

Edit `ios/Runner/Runner.entitlements`:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:$(DEEP_LINK_HOST)</string>
</array>
```

- [ ] **Step 4: Enable Associated Domains capability**

In Xcode, Runner target → **Signing & Capabilities** → **+ Capability** → **Associated Domains** → verify `applinks:$(DEEP_LINK_HOST)` is present (the variable will expand at build time based on the active configuration's xcconfig).

- [ ] **Step 5: Build all flavors**

```bash
flutter build ios --flavor dev     --dart-define=DEEP_LINK_HOST=dev.survey-frontend.system2030.com     --debug --no-codesign
flutter build ios --flavor staging --dart-define=DEEP_LINK_HOST=staging.survey-frontend.system2030.com --debug --no-codesign
flutter build ios --flavor prod    --dart-define=DEEP_LINK_HOST=survey-frontend.system2030.com        --debug --no-codesign
```

Expected: each succeeds.

- [ ] **Step 6: Coordinate `apple-app-site-association` hosting**

Confirm with the frontend team that `https://<host>/.well-known/apple-app-site-association` is hosted at each env domain with the correct app ID (`<TEAM_ID>.com.rs4it.survey.dev`, `.staging`, prod) and the `/register-device/*`, `/survey/*`, and locale-prefixed variants in `applinks.details.paths`. Blocking prerequisite for Universal Links to resolve to the app.

- [ ] **Step 7: Commit**

```bash
git add ios/Flutter/ ios/Runner/Runner.entitlements ios/Runner.xcodeproj/
git commit -m "build(ios): add env xcconfigs, Associated Domains entitlement"
```

---

## Task 16: Main app wiring — service, bloc, listener

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/features/deep_linking/presentation/deep_link_listener.dart`
- Create: `lib/features/deep_linking/presentation/widgets/discard_survey_dialog.dart`

- [ ] **Step 1: Implement `DiscardSurveyDialog`**

```dart
// lib/features/deep_linking/presentation/widgets/discard_survey_dialog.dart
import 'package:flutter/material.dart';

Future<bool> showDiscardSurveyDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Discard current survey?'),
      content: const Text(
        'You have a survey in progress. Opening the new survey will discard the current one.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Discard'),
        ),
      ],
    ),
  );
  return result ?? false;
}
```

- [ ] **Step 2: Implement `DeepLinkListener`**

```dart
// lib/features/deep_linking/presentation/deep_link_listener.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../bloc/deep_link_bloc.dart';
import '../bloc/deep_link_event.dart';
import '../bloc/deep_link_state.dart';
import '../models/device_registration_args.dart';
import '../models/survey_deep_link_args.dart';
import 'widgets/discard_survey_dialog.dart';

class DeepLinkListener extends StatelessWidget {
  final Widget child;
  const DeepLinkListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeepLinkBloc, DeepLinkState>(
      listenWhen: (p, c) => p != c,
      listener: (context, state) async {
        final router = GoRouter.of(context);
        final currentLocation =
            router.routerDelegate.currentConfiguration.uri.toString();

        switch (state) {
          case DeepLinkIdle():
            return;

          case NavigateToDeviceRegistration(:final token):
            if (currentLocation.startsWith(Routes.deviceRegistrationPath)) {
              context.read<DeepLinkBloc>().add(const NavigationHandled());
              return;
            }
            router.push(
              Routes.deviceRegistrationPath,
              extra: DeviceRegistrationArgs(token: token, fromDeepLink: true),
            );
            context.read<DeepLinkBloc>().add(const NavigationHandled());

          case NavigateToSurvey(:final shortCode):
            router.push(
              Routes.surveyDeepLinkPath,
              extra: SurveyDeepLinkArgs(shortCode: shortCode),
            );
            context.read<DeepLinkBloc>().add(const NavigationHandled());

          case AwaitingDiscardConfirmation(:final pendingShortCode):
            final confirmed = await showDiscardSurveyDialog(context);
            if (!context.mounted) return;
            if (confirmed) {
              context
                  .read<DeepLinkBloc>()
                  .add(ConfirmDiscardActiveSurvey(pendingShortCode));
            } else {
              context.read<DeepLinkBloc>().add(const CancelDiscardActiveSurvey());
            }
        }
      },
      child: child,
    );
  }
}
```

- [ ] **Step 3: Wire into `main.dart`**

Edit `lib/main.dart`:

Add imports:

```dart
import 'features/deep_linking/bloc/deep_link_bloc.dart';
import 'features/deep_linking/bloc/deep_link_event.dart';
import 'features/deep_linking/presentation/deep_link_listener.dart';
import 'features/deep_linking/service/deep_link_service.dart';
import 'features/assignment/bloc/start_response/start_response_bloc.dart'; // or the bloc that owns "survey in progress"
```

> Replace the last import with whichever existing bloc / state exposes "is a survey being answered now?". If none cleanly exposes this, add a simple boolean via a `SurveyInProgressNotifier` singleton that `SurveyAnsweringPage` sets `true` on `initState` and `false` on `dispose`. Add that class under `lib/features/assignment/state/survey_in_progress_notifier.dart` as an additional commit between this step and the next; keep it a plain `ValueNotifier<bool>`.

In `_MyAppState`:

```dart
  late final DeepLinkService _deepLinkService;
  late final DeepLinkBloc _deepLinkBloc;

  @override
  void initState() {
    super.initState();
    _deepLinkService = DeepLinkService();
    _deepLinkBloc = DeepLinkBloc(
      isSurveyInProgress: () => SurveyInProgressNotifier.instance.value,
    );

    WidgetsBinding.instance.addObserver(_LifecycleObserver(
      onResumed: () async {
        final uri = await _deepLinkService.refreshOnResume();
        if (uri != null) _deepLinkBloc.add(DeepLinkReceived(uri));
      },
    ));

    _deepLinkService.initialLink().then((uri) {
      if (uri != null) _deepLinkBloc.add(DeepLinkReceived(uri));
    });
    _deepLinkService.linkStream.listen((uri) {
      _deepLinkBloc.add(DeepLinkReceived(uri));
    });

    // existing SessionInvalidationCoordinator wiring unchanged below…
  }

  @override
  void dispose() {
    _deepLinkBloc.close();
    super.dispose();
  }
```

Add a small helper class at the bottom of `main.dart`:

```dart
class _LifecycleObserver with WidgetsBindingObserver {
  final Future<void> Function() onResumed;
  _LifecycleObserver({required this.onResumed});
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResumed();
  }
}
```

Add `DeepLinkBloc` to the `MultiBlocProvider` (use `BlocProvider.value`):

```dart
  BlocProvider.value(value: _deepLinkBloc),
```

Wrap the existing builder content with `DeepLinkListener`:

```dart
builder: (context, child) {
  final content = QueueStatusListener(
    child: child ?? const SizedBox.shrink(),
  );
  return DeepLinkListener(
    child: ZoneViolationListener(
      child: LocationPermissionGate(child: content),
    ),
  );
},
```

- [ ] **Step 4: Run full test suite**

Run: `flutter test`
Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart lib/features/deep_linking/presentation/ lib/features/assignment/state/
git commit -m "feat(deep_linking): wire service, bloc, listener into app root"
```

---

## Task 17: `SurveyInProgressNotifier` + integration

(If Task 16 Step 3 added the notifier file but didn't wire it, this task finishes the wiring.)

**Files:**
- Create: `lib/features/assignment/state/survey_in_progress_notifier.dart` (if not already)
- Modify: `lib/features/assignment/presentation/pages/survey_answering_page.dart`

- [ ] **Step 1: Create notifier**

```dart
// lib/features/assignment/state/survey_in_progress_notifier.dart
import 'package:flutter/foundation.dart';

class SurveyInProgressNotifier extends ValueNotifier<bool> {
  SurveyInProgressNotifier._() : super(false);
  static final SurveyInProgressNotifier instance = SurveyInProgressNotifier._();
}
```

- [ ] **Step 2: Toggle in `SurveyAnsweringPage`**

In `initState`: `SurveyInProgressNotifier.instance.value = true;`
In `dispose`: `SurveyInProgressNotifier.instance.value = false;`

- [ ] **Step 3: Commit**

```bash
git add lib/features/assignment/
git commit -m "feat(assignment): expose SurveyInProgressNotifier for deep-link gating"
```

---

## Task 18: Widget test for `DeepLinkListener`

**Files:** Create `test/features/deep_linking/deep_link_listener_test.dart`.

- [ ] **Step 1: Write test**

```dart
// test/features/deep_linking/deep_link_listener_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:king_abdulaziz_center_survey_app/core/routes/app_routes.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/bloc/deep_link_bloc.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/bloc/deep_link_event.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/bloc/deep_link_state.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/presentation/deep_link_listener.dart';

void main() {
  testWidgets('AwaitingDiscardConfirmation shows discard dialog', (tester) async {
    final bloc = DeepLinkBloc(isSurveyInProgress: () => true);
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('home'))),
        GoRoute(path: Routes.surveyDeepLinkPath, builder: (_, __) => const Scaffold()),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => BlocProvider.value(
          value: bloc,
          child: DeepLinkListener(child: child ?? const SizedBox()),
        ),
      ),
    );

    bloc.add(DeepLinkReceived(Uri.parse(
        'https://${/* host */ 'survey-frontend.system2030.com'}/survey/abc')));

    await tester.pumpAndSettle();

    expect(find.text('Discard current survey?'), findsOneWidget);
    await bloc.close();
  });
}
```

- [ ] **Step 2: Run**

Run: `flutter test test/features/deep_linking/deep_link_listener_test.dart`
Expected: pass.

- [ ] **Step 3: Commit**

```bash
git add test/features/deep_linking/deep_link_listener_test.dart
git commit -m "test(deep_linking): widget test for discard confirmation"
```

---

## Task 19: Manual integration QA

Run per flavor (`dev` minimum, `staging` and `prod` when assetlinks/AASA are hosted).

- [ ] Scan HTTPS QR code with phone's native camera → app opens (cold start) directly on register-device with pre-filled, read-only token.
- [ ] Kill app → tap `https://<host>/survey/<code>` link from a note → survey fetches, then opens.
- [ ] App running in foreground → receive a deep link via `adb shell am start -W -a android.intent.action.VIEW -d "https://dev.survey-frontend.system2030.com/survey/abc" com.rs4it.survey.dev` → survey pushes on top of current screen.
- [ ] Deep link while mid-survey → confirmation dialog → "Discard" opens new survey; "Cancel" keeps current.
- [ ] Airplane mode → survey deep link → "No internet" + Retry. Toggle off airplane mode → auto-loads.
- [ ] Rapid A → B deep links while running (`adb` twice) → B wins, no orphaned dialog.
- [ ] Cross-env link (production app receives `dev.survey-frontend...` link) → ignored silently.
- [ ] Expired/invalid token deep link → error UI with "Scan again" (routes to qr_scanner).
- [ ] Background app with discard dialog showing → resume → dialog still shown (or re-presented).
- [ ] iOS Universal Link from Notes app (tap) → opens app. (Requires AASA hosted.)
- [ ] Android App Link from a chat app → opens app directly (no browser picker). (Requires assetlinks.json hosted.)

- [ ] **Commit test plan results** in a new file `docs/superpowers/qa/2026-04-20-deep-linking-qa.md` summarizing what passed / what was blocked by AASA/assetlinks availability.

```bash
git add docs/superpowers/qa/2026-04-20-deep-linking-qa.md
git commit -m "docs(qa): deep linking manual QA results"
```

---

## Self-review notes

- Each spec section (§1–§15) maps to at least one task:
  - §2 link formats → Task 5 (parser), Task 14/15 (native).
  - §3 mechanism + §4 flavors → Tasks 14, 15.
  - §5 module architecture → Tasks 2–11, 16.
  - §6 parsing → Task 5.
  - §7 service → Task 6.
  - §8 bloc/navigation → Task 7, 16, 18.
  - §9 survey feature → Tasks 8, 9, 10, 11, 12.
  - §10 device registration → Task 13.
  - §11 app wiring → Task 16.
  - §12 routes → Tasks 8, 12.
  - §13 testing → Tasks 5, 6, 7, 10, 18, 19.
  - §14 deps → Task 1, Task 7 Step 4.
  - §15 open items → surfaced in Tasks 9, 11, 14 Step 6, 15 Step 6.

- Known intentional deferrals flagged inline:
  - Task 11 `_LoadedView` mapping from `ValidatedPublicLink` → `SurveyAnsweringPage`.
  - Task 13 error-state distinction in existing `ValidateTokenBloc`.
  - Task 16 Step 3 choice of "survey in progress" signal → formalized in Task 17.
