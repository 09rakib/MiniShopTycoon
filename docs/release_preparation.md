# Release candidate handoff — refreshed 27 October 2026

This is an **unsigned candidate**, as requested by the user. No new signing key
was created, no account was accessed and nothing was uploaded to a store. Debug
APK stays update-compatible with the existing debug installation. A release signed
with another key cannot update that installation; preserve test progress first.

## Builds

- `build-android.cmd`: signed debug APK, for the existing phone installation.
- `powershell -File build-release.ps1 -Format apk`: unsigned optimized release APK.
- `powershell -File build-release.ps1 -Format aab`: unsigned Gradle App Bundle.

Matching Godot 4.7.2 templates, JDK and Android SDK are required. The AAB command
extracts the matching local Android build template if absent, then runs
prepare-android-build.ps1 before export. Generated android/,
Gradle output, APK/AAB files, keystores and credentials are ignored by Git. The
wrapper rejects missing/stale artifacts and engine errors, then runs the native
library/ZIP content audit. No private signing data belongs in export_presets.cfg.
When the local Google bundletool 1.18.3 validator is present, the wrapper also
validates AAB structure. Download its all-in-one JAR from the official
[bundletool releases](https://github.com/google/bundletool/releases/tag/1.18.3)
to tools/bundletool-all-1.18.3.jar; it is deliberately not committed.

The supplied template defaults to AGP 8.6.1/Gradle 8.11.1. Preparation now pins
AGP 8.11.1/Gradle 8.13 (official SHA256 checked), NDK 28.2.13676358 and SDK
build-tools 36.0.0. Install that NDK before using the wrapper. It uses project-local
non-persistent/plain-console execution; global Gradle settings are not changed.
Base manifest renderer/editor metadata lets export overlays replace real values.
The old API compatibility, missing metadata and native stripping warnings are
resolved. Template Groovy DSL deprecations for future Gradle 10 and the existing
experimental path-check notice remain; no warning suppression is used.
See test_report_toolchain.md for v0.13.1/code 15 evidence. AGP 8.11 supports API 36
and requires Gradle 8.13.
[Official AGP 8.11 compatibility](https://developer.android.com/build/releases/agp-8-11-0-release-notes).

## Sign locally when the owner is ready

Keep the upload key and password in private secure storage with an independent
backup. Do not send passwords in chat, commit them, or put them in command history.
Use interactive password prompts. Replace these example paths/alias with the
owner's actual values; these commands are instructions, not actions already run.

For the AAB, use the JDK jarsigner (not apksigner):

```powershell
& "$env:JAVA_HOME/bin/jarsigner.exe" -keystore 'C:/private/upload.jks' `
  -signedjar 'builds/MiniShopTycoon-phaseK-signed.aab' `
  'builds/MiniShopTycoon-phaseK-unsigned.aab' 'upload-alias'
& "$env:JAVA_HOME/bin/jarsigner.exe" -verify -verbose -certs `
  'builds/MiniShopTycoon-phaseK-signed.aab'
```

For the APK, the exported candidate is already aligned. Sign a new output with
SDK build-tools apksigner and verify it; never change its contents after signing.

```powershell
& "$env:ANDROID_HOME/build-tools/36.0.0/apksigner.bat" sign `
  --ks 'C:/private/upload.jks' --ks-key-alias 'upload-alias' `
  --out 'builds/MiniShopTycoon-phaseK-signed.apk' `
  'builds/MiniShopTycoon-phaseK-unsigned.apk'
& "$env:ANDROID_HOME/build-tools/36.0.0/apksigner.bat" verify --verbose `
  'builds/MiniShopTycoon-phaseK-signed.apk'
```

Verify the package/version/certificate independently. Configure Play App Signing
and run internal testing with the owner-approved upload key before any production
release. Package name uniqueness, developer identity/account verification, privacy
URL/contact, content rating, audience and store listing need owner completion.

## Store guidance checked 23 October; toolchain guidance rechecked 27 October

- New mobile apps/updates must target API 36 from 31 August 2026. Candidate targets
  36. [Google Play target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878).
- 64-bit native code requires 16KB support. Current Android guidance states update
  enforcement from 1 February 2027; eligibility/extensions must be checked in the
  actual console. Static ARM64 ELF alignment plus APK zipalign checks pass, but a
  real 16KB runtime test is still required. [Android page-size guide](https://developer.android.com/guide/practices/page-sizes).
- AAB export uses Gradle, with non-debug signing needed for upload. [Godot Android export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).
- Data safety disclosure and privacy policy must match actual app behavior; local
  offline code review is not a submitted/approved form. [Google Play User Data](https://support.google.com/googleplay/android-developer/answer/10144311).

## Device performance procedure — deferred by the user

Use the same artifact/version and keep a disposable test save separate from real
progress. Record phone model, Android version, screen size/refresh, renderer,
power/thermal state and whether debug or release. Measure idle shop, full expanded
shop with four customers/stocker, movement/handling and menu/grocery overlays after
warmup; use an Android system trace/profiler for the Godot SurfaceView. Ordinary
View gfxinfo frame totals alone do not establish Godot render FPS. Record frame
time percentiles, PSS via `adb shell dumpsys meminfo com.minishoptycoon.offlinegame`,
node/voice bounds and memory trend over at least ten minutes. Repeat Home/resume,
cold launch and offline gameplay. Test a representative low-end device and 16KB
environment before declaring release ready. No such device results are claimed.
