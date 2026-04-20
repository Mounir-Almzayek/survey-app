# Deep Linking — Manual QA Checklist

**Plan:** `docs/superpowers/plans/2026-04-20-deep-linking.md`
**Spec:** `docs/superpowers/specs/2026-04-20-deep-linking-design.md`
**Date baseline:** 2026-04-20

## Prerequisites (external — not in this repo)

- [ ] Frontend team has published `/.well-known/assetlinks.json` at each env domain with correct application IDs (`com.rs4it.king_abdulaziz_center_survey_app` + `.dev` / `.staging` suffixes) and SHA256 signing fingerprints.
- [ ] Frontend team has published `/.well-known/apple-app-site-association` at each env domain with correct `<TEAM_ID>.<bundle_id>` in `applinks.details.appIDs` and paths `/register-device/*`, `/survey/*`, `/ar/register-device/*`, `/ar/survey/*`, `/en/register-device/*`, `/en/survey/*`.
- [ ] Firebase console has Android apps registered for every flavor's `applicationId` (base, `.dev`, `.staging`) and the merged `google-services.json` is committed — otherwise the dev/staging builds fail with "No matching client found for package name…".
- [ ] iOS Xcode manual setup from `docs/superpowers/ios-xcode-setup.md` is complete.

## Android — per flavor

Run with:
```
flutter run --flavor <dev|staging|prod> \
  --dart-define=DEEP_LINK_HOST=<matching host>
```

- [ ] Scan a QR encoding `https://<host>/register-device?token=ABC123` with the phone's native camera → app opens (cold start) on device-registration with the token pre-filled.
- [ ] Kill app → tap `https://<host>/survey/<shortCode>` link from a chat app → survey metadata fetches then displays.
- [ ] App running in foreground → inject a deep link:
      ```
      adb shell am start -W -a android.intent.action.VIEW \
        -d "https://dev.survey-frontend.system2030.com/survey/abc" \
        com.rs4it.king_abdulaziz_center_survey_app.dev
      ```
      → survey page pushes on top of the current screen.
- [ ] Deep link while mid-survey → confirmation dialog shows → "Discard" opens new survey; "Cancel" keeps current.
- [ ] Airplane mode → tap survey deep link → "No internet connection" + Retry button. Toggle off airplane mode → auto-loads.
- [ ] Rapid A → B deep links while running (`adb` twice in quick succession) → B wins, no orphaned dialog.
- [ ] Cross-env link rejected: production app receives a `dev.survey-frontend.system2030.com/...` link → silently ignored (no navigation, no error UI).
- [ ] Invalid or expired token deep link → device-registration page surfaces the backend error state (specific error-state UX is a noted follow-up — see "Known gaps").
- [ ] Background the app while the discard dialog is showing → resume → dialog is still visible (or re-presented on the same `AwaitingDiscardConfirmation` state).
- [ ] After successful device registration the app returns to the normal routing flow (splash / home / login as appropriate).

## iOS — per flavor

Simulator does not fully test Universal Links; use a real device.

- [ ] From Notes or Messages, long-press a link `https://<host>/register-device?token=TEST123` → "Open in KAC Survey" appears → taps the app open on device-registration.
- [ ] Likewise for `https://<host>/survey/<shortCode>`.
- [ ] If the link opens Safari instead of the app → AASA is not hosted correctly or the Associated Domains capability isn't enabled for the active scheme.

## Smoke tests (automated, already passing)

- `flutter test test/features/deep_linking/` — parser, service, bloc, listener.
- `flutter test test/features/assignment/survey_by_short_code_bloc_test.dart` — fetch/offline/retry bloc.

## Known gaps (tracked; not blocking deep-link mechanism)

These were surfaced during implementation and intentionally deferred:

1. **Public-link answering UX stub.** `SurveyDeepLinkPage` renders survey title/description/greeting on load, but the "Start Survey" button is a placeholder SnackBar. Reason: the backend flow for `POST /public-link/:short_code/start` returns only `{ response_id, first_section, conditional_logics }`, not a full `Survey` object. The existing `SurveyAnsweringPage` consumes a preloaded `Survey`, so it can't be reused. A new `PublicLinkAnsweringPage` that drives server-side section-by-section navigation is a follow-up feature (~300–500 lines, not in scope for this plan).
2. **Device-registration error-state UX for deep-link path.** `fromDeepLink` flag is wired through the page/screen, but the distinction between `InvalidToken` / `ExpiredToken` / `AlreadyRegistered` at the screen level and the "Scan again" routing follow-up is not yet differentiated — the screen falls back to the existing validation UX, which shows a generic error message. A follow-up task should map the `ValidateTokenBloc` error states to explicit UI branches with a "Scan again" button.
3. **Firebase `google-services.json` for flavors.** Adding flavor-specific `applicationId` suffixes (`.dev`, `.staging`) requires the Firebase console to register each additional Android app and a regenerated `google-services.json`. Until done, dev/staging builds fail at `processGoogleServices`.
4. **`appLabelSuffix` manifest placeholder** is injected by Gradle but `AndroidManifest.xml`'s `android:label` is still a static string `"KAC Survey"`. To make the label change per flavor, update it to `android:label="KAC Survey${appLabelSuffix}"`.
5. **iOS Xcode UI wiring** is documented in `docs/superpowers/ios-xcode-setup.md` but must be performed on a Mac (configurations, schemes, Associated Domains capability).

## Results

_Fill in as QA is performed:_

| Flavor | Item | Result | Notes |
|---|---|---|---|
| | | | |
