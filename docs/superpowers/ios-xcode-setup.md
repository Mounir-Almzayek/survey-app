# iOS Xcode Setup for Deep Linking

The Flutter-side iOS files are in place (xcconfigs, entitlements). These manual Xcode steps are required to finish wiring build configurations, schemes, and the Associated Domains capability.

## Prerequisites

- Mac with Xcode (tested with Xcode 15+)
- Apple Developer account with the app's bundle identifier(s) provisioned
- Frontend team confirms `https://<host>/.well-known/apple-app-site-association` is hosted at each env domain with the correct `<TEAM_ID>.<bundle_id>` in `applinks.details.appIDs` and `/register-device/*`, `/survey/*` (plus locale-prefixed variants) in `applinks.details.paths`. Without this, Universal Links will NOT resolve to the app.

## 1. Open the workspace

```
open ios/Runner.xcworkspace
```

## 2. Create per-flavor build configurations

In the Runner project inspector → Info tab → Configurations section:

1. Duplicate `Debug` three times → name the copies `Debug-Dev`, `Debug-Staging`, `Debug-Prod`. Delete the original `Debug` or leave it — your choice.
2. Do the same for `Release` → `Release-Dev`, `Release-Staging`, `Release-Prod`.
3. For each new configuration, open the disclosure triangle and set:
   - **Runner** project-level config file → the matching `ios/Flutter/Dev.xcconfig`, `Staging.xcconfig`, or `Prod.xcconfig` (these extend `Generated.xcconfig` already).
   - **Runner** target-level config file → keep the existing one (e.g., `Flutter/Debug.xcconfig` or leave inherited).

## 3. Create three schemes

Product menu → Scheme → Manage Schemes → `+`:

- **Runner-Dev** → Build action uses `Debug-Dev` for Run/Test/Analyze; `Release-Dev` for Profile/Archive.
- **Runner-Staging** → likewise with `-Staging`.
- **Runner-Prod** → likewise with `-Prod`.

Tick **Shared** for all three so they are committed to the repo under `ios/Runner.xcodeproj/xcshareddata/xcschemes/`.

## 4. Enable Associated Domains capability

Select the **Runner** target → **Signing & Capabilities** tab → `+ Capability` → **Associated Domains**.

Verify the domain row reads:
```
applinks:$(DEEP_LINK_HOST)
```

If it doesn't auto-populate from the entitlements file, add it manually. The `$(DEEP_LINK_HOST)` variable expands at build time based on which configuration you're building (Dev/Staging/Prod).

## 5. Set PRODUCT_BUNDLE_IDENTIFIER per configuration (optional)

If you want flavor-specific bundle IDs (recommended, matching Android's `.dev` / `.staging` suffixes):

Target → Build Settings → Product Bundle Identifier → set per configuration:
- `Debug-Dev` / `Release-Dev` → `com.rs4it.kingAbdulazizCenterSurveyApp.dev`
- `Debug-Staging` / `Release-Staging` → `com.rs4it.kingAbdulazizCenterSurveyApp.staging`
- `Debug-Prod` / `Release-Prod` → `com.rs4it.kingAbdulazizCenterSurveyApp`

Register each bundle ID in the Apple Developer portal and regenerate provisioning profiles.

## 6. Build per flavor

```
flutter build ios --flavor dev     --dart-define=DEEP_LINK_HOST=dev.survey-frontend.system2030.com     --debug --no-codesign
flutter build ios --flavor staging --dart-define=DEEP_LINK_HOST=staging.survey-frontend.system2030.com --debug --no-codesign
flutter build ios --flavor prod    --dart-define=DEEP_LINK_HOST=survey-frontend.system2030.com        --debug --no-codesign
```

## 7. Verify Universal Links resolve

On a device (simulator doesn't fully test Universal Links):
- Install the app.
- From Notes or Messages, create a link like `https://dev.survey-frontend.system2030.com/register-device?token=TEST123` and long-press → "Open in KAC Survey" should appear. Tapping should open the app directly.
- For `/survey/<code>`, likewise.

If the link opens Safari instead of the app, AASA is not yet hosted or is incorrect.
