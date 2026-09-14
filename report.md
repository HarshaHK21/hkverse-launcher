# HKVerse Launcher — Project Analysis Report

**Review date:** 12 September 2026  
**Scope:** Entire tracked project and current working tree. Application source was not changed.  
**Project type:** Flutter application, implemented for Android only.

## Executive summary

HKVerse Launcher is a small, focused custom Android home launcher. It uses Flutter for its UI and a Kotlin platform channel for the Android-only work of discovering and launching installed applications. The implemented feature set closely matches the original launcher brief: time/date, dark branded UI, alphabetically sorted app list, quick alphabet navigation, app icons, and app launching.

The codebase is readable and appropriately small, with a clear separation between UI, model, service, and Android bridge. The largest readiness gaps are release/signing configuration, limited automated validation, a generic README, and a few behavioral/performance/accessibility considerations described below.

## Repository inventory

| Area | Contents | Assessment |
| --- | --- | --- |
| Flutter UI | `lib/main.dart`, theme, home screen, widgets | Cleanly organized by responsibility. |
| Android integration | Manifest and `MainActivity.kt` | Native app enumeration and launching are implemented through a method channel. |
| Assets | Inter and Outfit variable fonts; Android launcher icons | Fonts are declared and used. |
| Tests | `test/widget_test.dart` | Two widget-level scenarios; no native/integration coverage. |
| Automation | `.github/workflows/build.yml` | Builds a release APK on every push and uploads it. |
| Documentation | `README.md` | Still the default Flutter template and does not describe this product. |
| Platforms | Android only | No iOS, web, Windows, macOS, or Linux platform folders. This is appropriate for a home launcher, but should be explicit. |

The declared app version is `1.0.0+1`. Dart SDK support is `^3.12.2`. The only direct runtime dependency is the Flutter SDK; development dependencies are `flutter_test` and `flutter_lints` 6.0.0.

## Architecture and execution flow

```text
Flutter main()
  -> HkverseLauncherApp / MaterialApp
     -> HomeScreen
        -> AppFetcher (MethodChannel: hkverse.launcher/apps)
           -> Android MainActivity / PackageManager
              -> launchable apps + rendered PNG icon bytes
        <- sorted AppInfo list
     -> app list, clock, alphabet index
        -> AppFetcher.openApp(package name)
           -> PackageManager.getLaunchIntentForPackage()
```

### Flutter layer

- `main.dart` initializes Flutter, enables immersive sticky system UI, applies transparent status/navigation bars, and starts `HomeScreen`.
- `theme.dart` centralizes the dark palette and uses Outfit for display text and Inter for body text.
- `AppInfo` is a minimal immutable model: display name, package name, and optional icon bytes.
- `AppFetcher` safely maps channel responses to `AppInfo`, discards malformed entries, sorts by case-insensitive name, and converts launch failures to `false`.
- `HomeScreen` fetches data at startup and again when the launcher resumes. It provides loading, error, and empty states; derives available letter sections; and calculates quick-scroll offsets using the fixed 64-pixel item height.
- `AppListItem` renders an icon and truncated app label, with a rounded fallback initial and a material ripple.
- `AlphabetIndex` supports tapping and vertical dragging over only the sections that exist in the installed-app list.
- `ClockWidget` updates once per second and cancels its timer correctly in `dispose`.

### Android layer

- The manifest registers the activity as both `HOME`/`DEFAULT` and `LAUNCHER`, so Android can offer it as a default home app while it also remains visible in the app drawer.
- `MainActivity` enumerates activities responding to `ACTION_MAIN` + `CATEGORY_LAUNCHER`, excludes the launcher itself, and de-duplicates packages.
- Each icon is rasterized into a 108×108 PNG byte array before being returned to Flutter.
- Tapping an app calls `getLaunchIntentForPackage`; failed lookup or launch returns `false` without crashing the Flutter UI.
- The app requests `QUERY_ALL_PACKAGES` and includes package-visibility queries. The broad permission is functionally aligned with a launcher but needs a policy justification if distributed through Google Play.

## Requirements alignment

The deleted historical requirements document in the working tree describes a minimalist Niagara-like Android launcher. Against that specification, the current implementation provides:

| Requirement | Status | Evidence / qualification |
| --- | --- | --- |
| Default Android launcher registration | Implemented | `HOME` and `DEFAULT` intent filter in the manifest. |
| Installed-app discovery and app launch | Implemented | Kotlin `PackageManager` integration via a platform channel. |
| Top-left clock and date | Implemented | `ClockWidget`. |
| Icon-and-name vertical app list | Implemented | `AppListItem` and `ListView.builder`. |
| Right-side quick alphabet navigation | Implemented | `AlphabetIndex`, with tap and drag. |
| Dark branded visual design | Implemented | Theme, fonts, radial background, and watermark. |
| Smooth scrolling / icon handling | Partially addressed | Fixed-extent virtualized list and resized icons help; there is no persistent icon cache. |
| Transparent system-wallpaper option | Not implemented | The UI deliberately paints an opaque branded background. |

## Quality findings and recommendations

### High priority before a public release

1. **Release APKs are debug-signed.** `android/app/build.gradle.kts` explicitly uses the debug signing configuration for the release build. A production keystore, secure CI secrets, and a real release signing configuration are required for trusted distribution and updates.
2. **Validate Android package-visibility policy.** `QUERY_ALL_PACKAGES` is a sensitive permission. A launcher has a plausible core need for it, but store release should include the required declaration and justification, or replace it with the narrowest viable visibility mechanism.
3. **Fix the test import before relying on CI.** `test/widget_test.dart` calls `Uint8List.fromList(...)` but does not import `dart:typed_data`. Static inspection indicates this is an undefined identifier and should prevent the test from compiling until that import is added.

### Medium priority

1. **Improve failure feedback when app launch fails.** `_launchApp` intentionally ignores the returned `Future<bool>`. The user receives no message when an app cannot be opened or disappears after the list was loaded.
2. **Avoid repeated icon conversion on every resume.** Resuming the launcher fetches every app and turns every native drawable into a PNG again. For devices with many apps, that can create latency, memory pressure, and battery use. Cache results/icons and invalidate on package changes, or return more efficient icon data.
3. **Handle duplicate labels and Unicode grouping intentionally.** Apps are deduplicated by package rather than launcher activity, which is sensible for most devices but hides separate launcher activities in one package. The alphabet grouping only recognizes ASCII A–Z; all accented, non-Latin, numeric, and emoji labels fall into `#`.
4. **Make accessibility explicit.** Icon fallbacks and alphabet controls have no semantic labels, and the 30-pixel index rail is smaller than common touch-target guidance. Screen-reader labels and a more generous hit area would improve usability.
5. **Review lifecycle refresh behavior.** `didChangeAppLifecycleState(resumed)` triggers a full fetch each time the user returns from another application. This maintains freshness but may be unnecessarily expensive without caching or package-change observation.
6. **Document the intended supported Android versions.** `minSdk`, `compileSdk`, and `targetSdk` inherit from Flutter rather than being explicitly documented here. State the support policy and test it on representative Android releases and launcher/default-home flows.

### Low priority / maintenance

1. Replace the starter README with installation, Android prerequisites, default-launcher instructions, build/release commands, and screenshots.
2. Remove template TODO comments once app ID and release signing are finalized.
3. The reported app-list header, “Choose Your Productivity Features,” does not describe an app launcher especially precisely; consider product-language review.
4. Add user-facing localization/time-format handling if audiences require locale-aware dates, non-English text, or a 24-hour clock preference.

## Testing and CI

### Existing coverage

- A widget test checks that mock installed apps render in alphabetical order and that the loading indicator disappears.
- A second widget test checks the generic app-load error state.
- The tests mock the platform channel; they do not exercise Android `PackageManager`, launcher role selection, installed icon decoding, app launch, scrolling, alphabet drag, or lifecycle refresh.

### Existing workflow

- GitHub Actions runs on `push` only.
- It pins third-party actions to commit hashes, which is a good supply-chain practice.
- It installs Java 17, Flutter `3.x`, performs `flutter pub get`, builds a release APK, and uploads the APK artifact.

### CI gaps

- The workflow does not run `flutter analyze` or `flutter test`.
- It does not run for pull requests, so prospective changes are not validated before merge.
- Flutter is specified as a `3.x` range rather than an exact version, so builds can change over time.
- There is no integration/device/emulator test, signed-release verification, dependency audit, or artifact retention/release-publishing policy visible in the repository.

### Local validation result

I attempted the standard Flutter toolchain checks in this environment. The installed `flutter.bat` command was discoverable, but `flutter --version`, `flutter analyze`, and `flutter test` did not produce usable command output before the execution environment returned. Consequently, no clean analyzer/test result is claimed in this report. The missing `dart:typed_data` import was found by source inspection.

## Security and privacy observations

- There are no network runtime dependencies and no application-side Internet permission in the main manifest. Debug and profile manifests include Internet permission for Flutter development tooling only.
- The app processes package names, labels, and icon images locally; no telemetry, backend, credentials, or analytics implementation is present in the tracked code.
- Native code broadly catches exceptions and returns safe fallback values. This avoids crashes but also loses diagnostics that would help troubleshoot device-specific failures; production logging should be privacy-conscious.
- The CI action references are commit-pinned. The Gradle wrapper downloads from the official Gradle distribution endpoint.

## Working-tree and documentation state

- The repository has one pre-existing uncommitted deletion: `Launcher_Developer_Requirements.md` (58 lines). It was not restored or otherwise changed during this review.
- The document was available in Git history and was used only to assess requirements alignment above.
- This review added only this `report.md`; no application, test, configuration, workflow, asset, or Android source file was modified.

## Suggested delivery order

1. Restore or relocate the requirements document if its removal was accidental; otherwise update the README with the current product specification.
2. Correct the test compilation issue and add analyzer/test steps for both push and pull-request workflows.
3. Establish production signing and verify the Android launcher/default-home experience on physical devices.
4. Decide and document the `QUERY_ALL_PACKAGES` distribution-policy approach.
5. Add integration tests and then optimize/correct caching, launch-failure feedback, accessibility, and internationalization based on real-device results.
