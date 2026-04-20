# Deep Linking — Design Spec

**Date:** 2026-04-20
**Status:** Approved for planning
**Scope:** Mobile app only (Flutter). No web fallback.

## 1. Goals

Enable two deep-link flows on the mobile app:

1. **Device registration via QR** — the phone's native camera scans an HTTPS QR code and opens the app directly into device-registration with the token pre-filled.
2. **Survey via shared link** — an HTTPS URL (shared or from a QR) opens the app directly into the target survey, bypassing any list or browsing UI.

Out of scope: fallback web behavior when the app is not installed (owned by the frontend team).

## 2. Link formats

Canonical URLs mirror the frontend URL structure:

- Device registration: `https://<host>/register-device?token=<token>` (optionally locale-prefixed, e.g. `/ar/register-device`)
- Survey: `https://<host>/survey/<shortCode>` (optionally locale-prefixed)

`<host>` per environment:

| Env | Host |
|---|---|
| dev | `dev.survey-frontend.system2030.com` |
| staging | `staging.survey-frontend.system2030.com` |
| prod | `survey-frontend.system2030.com` |

## 3. Mechanism

- **Android App Links** + **iOS Universal Links** via the [`app_links`](https://pub.dev/packages/app_links) package.
- HTTPS only — no custom URL scheme.
- Domain verification via frontend-hosted `/.well-known/assetlinks.json` (Android) and `/.well-known/apple-app-site-association` (iOS) at each env host.

## 4. Build-time configuration — flavors

Per-env hosts are injected at build time. Nothing is hardcoded; nothing is runtime-read from `.env` for native manifests/entitlements.

### Android (`android/app/build.gradle`)

```gradle
flavorDimensions "env"
productFlavors {
  dev     { dimension "env"; manifestPlaceholders = [deepLinkHost: "dev.survey-frontend.system2030.com", appLabelSuffix: " Dev"] }
  staging { dimension "env"; manifestPlaceholders = [deepLinkHost: "staging.survey-frontend.system2030.com", appLabelSuffix: " Staging"] }
  prod    { dimension "env"; manifestPlaceholders = [deepLinkHost: "survey-frontend.system2030.com",       appLabelSuffix: ""] }
}
```

`AndroidManifest.xml` (on the launcher `MainActivity`):

```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="https" android:host="${deepLinkHost}" android:pathPrefix="/register-device"/>
  <data android:scheme="https" android:host="${deepLinkHost}" android:pathPrefix="/survey"/>
</intent-filter>
```

### iOS

- Three xcconfig files: `Dev.xcconfig`, `Staging.xcconfig`, `Prod.xcconfig` — each defining `DEEP_LINK_HOST`.
- Three build configurations (Debug-Dev / Release-Dev / Debug-Staging / …) + three schemes.
- `Runner.entitlements` uses `$(DEEP_LINK_HOST)` in `com.apple.developer.associated-domains`:
  ```
  applinks:$(DEEP_LINK_HOST)
  ```

### Flutter

```
flutter run   --flavor dev
flutter build apk --flavor prod
flutter build ios --flavor staging
```

The flavor also injects `DEEP_LINK_HOST` into Dart via `--dart-define` (or an equivalent generated constant) so the parser can validate inbound links against the active host. `APP_ENV` in `.env` continues to drive API base URLs only (existing behavior unchanged).

## 5. Module architecture

New feature: `lib/features/deep_linking/`. Responsibility: receive OS deep links, parse them, gate on app state (in-progress survey), dispatch navigation intents. Does NOT own device-registration or survey logic.

```
lib/features/deep_linking/
  config/
    deep_link_config.dart          # exposes active host, locale list, path constants
  models/
    deep_link.dart                 # sealed: RegisterDeviceLink(token) | SurveyLink(shortCode) | UnknownLink(uri)
  service/
    deep_link_service.dart         # wraps app_links; initial link + stream; debounce/dedup; lifecycle refresh
    deep_link_parser.dart          # Uri → DeepLink (pure)
  bloc/
    deep_link_bloc.dart
    deep_link_event.dart
    deep_link_state.dart
  presentation/
    deep_link_listener.dart        # widget at app root; reads bloc state, invokes GoRouter
    widgets/
      discard_survey_dialog.dart
```

Existing features extended (no duplicates):

- `features/responses/` gains `bloc/survey_by_short_code/` + `presentation/survey_deep_link_page.dart` (thin orchestration page that fetches then delegates to the existing `SurveyAnsweringPage`).
- `features/device_registration/` gains handling for `DeviceRegistrationArgs(token, fromDeepLink: true)` — pre-fills & locks token; surfaces `InvalidToken` / `ExpiredToken` / `AlreadyRegistered` states.

Shared:

- `lib/core/routes/route_args.dart` (or per-feature) — typed argument objects: `DeviceRegistrationArgs`, `SurveyDeepLinkArgs`. Passed via `GoRouter`'s `extra`; screens cast once at the boundary.

## 6. Parsing rules

`DeepLinkParser.parse(Uri uri) → DeepLink`:

1. **Normalize**: lowercase path, collapse duplicate slashes, strip trailing slash.
2. **Scheme**: must be `https`; else `UnknownLink`.
3. **Host**: must equal `DeepLinkConfig.expectedHost`; else `UnknownLink` (rejects cross-env links).
4. **Locale prefix**: strip leading two-letter segment (e.g., `/ar`, `/en`) before matching. App locale state is not affected by the link.
5. **Route match**:
   - `/register-device` with query `token=<non-empty after trim>` → `RegisterDeviceLink(token)`. Missing/empty token → `UnknownLink`.
   - `/survey/<shortCode>` with `<shortCode>` non-empty → `SurveyLink(shortCode)`.
   - Anything else → `UnknownLink`.
6. **Query param safety**: use `Uri.queryParameters` (decoded), trim, null/empty check.
7. **Logging**: `UnknownLink` is logged via the existing logger. The raw `token` query value is redacted before logging.

## 7. Service layer

`DeepLinkService`:

- Exposes `Future<Uri?> initialLink()` and `Stream<Uri> linkStream`.
- Wraps `app_links` `AppLinks().getInitialAppLink()` and `AppLinks().uriLinkStream`.
- **Debounce/dedup**: stores last URI + timestamp; drops an incoming URI if it matches the previous within a short window (e.g., 2 s).
- **Lifecycle refresh**: on `AppLifecycleState.resumed`, re-calls `getInitialAppLink()` and pipes through the dedup filter in case the OS delivered a link without streaming it.
- **Concurrency — last-link-wins**: stream is single-subscription. A new link supersedes any link being processed; the bloc listens to the stream and resets on every inbound.

## 8. Bloc & navigation

### `DeepLinkBloc`

- **Event `DeepLinkReceived(Uri uri)`**: parses, emits a navigation intent state, or drops with a log.
- **Event `ConfirmDiscardActiveSurvey(String shortCode)`** / `CancelDiscardActiveSurvey`: resolves the confirmation flow.
- **States**:
  - `Idle`
  - `NavigateToDeviceRegistration(token)`
  - `NavigateToSurvey(shortCode)`
  - `AwaitingDiscardConfirmation(pendingShortCode)`
- The bloc makes **no** `GoRouter` or `BuildContext` calls. It emits pure intents.

### Gating logic

On `DeepLinkReceived`:

- `RegisterDeviceLink(token)` → emit `NavigateToDeviceRegistration(token)`.
- `SurveyLink(shortCode)`:
  - If a survey is currently being answered (queried via the existing responses bloc / in-progress flag) → `AwaitingDiscardConfirmation(shortCode)`.
  - Else → `NavigateToSurvey(shortCode)`.
- If a new `DeepLinkReceived` arrives while state is `AwaitingDiscardConfirmation(A)` → drop A, process the new link fresh (last-link-wins).

### `DeepLinkListener` widget

- Mounted at app root, beneath `MaterialApp.router`.
- Watches `DeepLinkBloc` state.
- Reads `GoRouterState.of(context).matchedLocation` to make duplicate-route decisions (e.g., the intent targets the route the user is already on with the same args → drop).
- On `NavigateToDeviceRegistration(token)`:
  `context.push(Routes.deviceRegistrationPath, extra: DeviceRegistrationArgs(token: token, fromDeepLink: true))`.
- On `NavigateToSurvey(shortCode)`:
  `context.push(Routes.surveyDeepLinkPath, extra: SurveyDeepLinkArgs(shortCode: shortCode))` — mapped to `SurveyDeepLinkPage` (see §9).
- On `AwaitingDiscardConfirmation(code)`:
  - Shows `DiscardSurveyDialog`. On confirm → dispatch `ConfirmDiscardActiveSurvey(code)`. On cancel → dispatch `CancelDiscardActiveSurvey`.
  - If the app is backgrounded while the dialog is showing, the state persists. On resume, the listener re-checks state and re-presents the dialog if still awaiting.

Navigation is stack-based (`push`) so closing the deep-linked screen returns to whatever was on top before — honoring auth-independence: the user lands back on splash/login/home depending on their pre-link state.

## 9. Survey deep-link feature (`responses/`)

Extends, rather than duplicates, the responses feature.

- **Route**: add `Routes.surveyDeepLinkPath = '/survey-deep-link'` mapped to `SurveyDeepLinkPage`.
- **Page**: `SurveyDeepLinkPage` is a thin orchestrator. Receives `SurveyDeepLinkArgs(shortCode)`. On `initState` dispatches `FetchSurvey(shortCode)` to `SurveyByShortCodeBloc`. Based on state:
  - `Loading` → spinner.
  - `Loaded(survey)` → embeds the existing `SurveyAnsweringPage` widget tree with the fetched survey injected.
  - `Error(offline)` → "No connection" UI with manual retry + auto-retry on reconnect.
  - `Error(notFound|serverError)` → error UI with a "Back" affordance.

- **Bloc (`SurveyByShortCodeBloc`)**:
  - Events: `FetchSurvey(shortCode)`, `Retry`, `_ConnectivityRestored`.
  - States: `Idle | Loading(shortCode) | Loaded(survey) | Error(kind, shortCode)` where `kind ∈ { offline, notFound, alreadyRegistered, serverError }`.
  - **Idempotence**: ignores `FetchSurvey(code)` when already `Loading(code)` or `Loaded` with the same code. Any other code triggers a fresh fetch.
  - **Connectivity**: subscribes to `connectivity_plus`; when in `Error(offline, code)` and connection is restored, auto-dispatches `FetchSurvey(code)`.
  - **Backend**: uses the existing public-links repository against `GET /public-link/:short_code` (a public, unauthenticated endpoint that already exists on the backend).

- **Submission**: unchanged — the existing responses submit flow runs as today. On success the user is popped back; the deep-link `push` means they return to whatever was below (splash/home/login).

## 10. Device registration deep-link flow (`device_registration/`)

- **Args**: `DeviceRegistrationArgs({required String token, bool fromDeepLink = false})`.
- **When `fromDeepLink == true`**:
  - Token field pre-filled and read-only.
  - Small "Scanned from link" helper text.
  - Manual entry path (QR scanner / form) is unchanged elsewhere (`fromDeepLink` defaults to `false`).
- **Error handling**:
  - `InvalidToken` / `ExpiredToken` backend responses → clear message + "Scan again" (routes to `qr_scanner`) and "Back to home". No retry with the same token.
  - `AlreadyRegistered` → non-destructive info screen + "Back to home".
- **Offline**: mirror survey behavior — error state with manual retry + auto-retry on `connectivity_plus` reconnect. No local queuing (registration requires live backend challenge/attestation).
- **Post-success navigation**: emit a global `AppSessionChanged` event on the app-wide routing bloc. `GoRouter`'s redirect hook re-evaluates app state (authed → home, not → welcome/login). Avoids hard `go(splashPath)` and duplicate init.
- **Auth independence**: route is unguarded. The user can hit device registration whether or not they are authenticated.

## 11. App wiring

In `main.dart` (or the app-root widget) after `GoRouter` is constructed:

1. Instantiate `DeepLinkService`.
2. `DeepLinkService.initialLink()` → if non-null, dispatch `DeepLinkReceived(uri)` to `DeepLinkBloc`.
3. Subscribe to `DeepLinkService.linkStream` → dispatch `DeepLinkReceived(uri)`.
4. Mount `DeepLinkListener` beneath `MaterialApp.router`.
5. Hook `DeepLinkService` to `WidgetsBindingObserver` for `AppLifecycleState.resumed` refresh.

## 12. Routes

Add to `lib/core/routes/app_routes.dart`:

```dart
static const String surveyDeepLinkPath = '/survey-deep-link';
```

Register `SurveyDeepLinkPage` in `app_pages.dart`. `deviceRegistrationPath` already exists; extend its builder to read `DeviceRegistrationArgs` from `extra`.

## 13. Testing plan

**Unit**

- `DeepLinkParser`: valid register-device, valid survey, locale prefix (`/ar/...`, `/en/...`), cross-host reject, wrong scheme, missing token, empty shortCode, duplicate slashes, trailing slash, case variants, unknown paths.
- `DeepLinkService`: debounce/dedup with a fake stream (two identical URIs in < 2 s drops the second); lifecycle refresh picks up a queued initial link exactly once.
- `DeepLinkBloc`: plain navigate paths; mid-survey conflict → `AwaitingDiscardConfirmation` → confirm navigates, cancel clears; last-link-wins (A pending + B arrives → B processed, A dropped).
- `SurveyByShortCodeBloc`: 200 → `Loaded`; 404 → `Error(notFound)`; offline → `Error(offline)` → connectivity restored → auto-fetch → `Loaded`; duplicate `FetchSurvey(sameCode)` while `Loading` → no-op.

**Widget**

- `DeepLinkListener`: `NavigateToDeviceRegistration` → pushes correct route with `DeviceRegistrationArgs(token, fromDeepLink: true)`. `AwaitingDiscardConfirmation` → dialog shown. Background/foreground while dialog is up → dialog re-presents.
- `SurveyDeepLinkPage`: renders spinner / survey / error / offline states based on bloc state.

**Integration (manual QA per flavor)**

1. Scan an HTTPS QR with the phone's native camera → app opens (cold start) directly on target screen.
2. Kill app + cold-start via deep link.
3. Foreground deep link (app already running).
4. Deep link while mid-survey → confirmation dialog → both branches.
5. Airplane-mode survey link → error UI → reconnect → auto-loads.
6. Rapid sequential deep links A then B while running → B wins, no orphaned dialog.
7. Cross-env link (e.g., prod app receives staging URL) → ignored silently.
8. Invalid/expired token → error UI with "Scan again" path.
9. Background app during discard dialog → resume → dialog re-presented.

## 14. Dependencies

Add to `pubspec.yaml`:

```yaml
app_links: ^<latest>   # pin at implementation time
```

Existing deps reused: `go_router`, `flutter_bloc`, `connectivity_plus`, `flutter_dotenv`, `equatable`.

## 15. Open items for implementation phase

- Confirm exact backend response shape for `GET /public-link/:short_code` and any `InvalidToken` / `ExpiredToken` / `AlreadyRegistered` payloads used by `POST /device-registration`.
- Coordinate with frontend to publish `assetlinks.json` and `apple-app-site-association` at all three hosts before flavor rollout.
- Determine bundle IDs / application IDs per flavor and align with the hosted verification files.
