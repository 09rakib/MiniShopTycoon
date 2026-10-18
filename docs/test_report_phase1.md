# Phase 0 / Phase 1 test report — 18 October 2026

Engine: verified `4.7.2.stable.official.ed1daf0bf`.
Desktop renderer: OpenGL 3.3 Compatibility, NVIDIA GeForce GTX 1650.

## Passed

- Editor headless import and GDScript compilation. Initial test runs exposed
  a method-name collision with a newer CanvasItem API; renamed the drawing
  helper and reran import/tests successfully.
- **33 automated checks, 0 failures** (`tests/run_tests.gd`). Includes purchase,
  sale, quantities, capacity, funds, invalid IDs, sold cost versus revenue,
  invalid/fractional save fields, schema rejection, disk round trip, corrupted
  primary recovery, all-invalid preservation, confirmed/repeated reset,
  actual UI button signals, customer one-sale guard, bounded pool, menu pause,
  restart cancellation and simulated application pause/resume persistence.
- Rendered real Godot UI captures at 480×900 and 360×640; inspected shop layout
  for card text, button clipping and shop artwork. Menu also captured.
- Full rendered scene launch during the capture test; no GDScript/runtime errors.

## Fixed during testing

- Renamed ellipse drawing helper to avoid overriding Godot 4.7 native method.
- Isolated tool profiles to writable workspace directories.
- Replaced noisy static JSON parsing with checked parser errors for corruption.
- Kept reset recovery archives bounded instead of producing timestamped files.
- Prevented successful purchase/sale messages from hiding save failures.

## Failed / unresolved environment checks

- Windows certificate check could not build the engine signer's trust chain;
  expected signer subject was present; trust validation is not claimed.
- Initial sandboxed import could not write the normal user Godot profile;
  project-local profiles resolved this. SDK discovery/export requires separate
  validation; inspect the final Android result below.

## Not run / awaiting user

- Real Android installation, airplane-mode gameplay, touch controls, physical
  device pause/resume, force stop and full restart persistence.
- Measured phone FPS/frame times, memory/battery/heat and long play sessions.
- Phase 2+ upgrade/progression/offline-earnings/achievement tests: not applicable
  until those features are implemented.
- Release signing/AAB/Play compliance checks: deferred, not release ready.

## Android export

**Passed:** Godot `--export-debug "Android Phase 1"` completed with exit code 0.
Built `builds/MiniShopTycoon-phase1.apk`, 57,603,873 bytes (~55 MiB).
Used installed SDK build-tools 36.0.0 and Android Studio's OpenJDK 21.0.10.
Matching 4.7.2 Android templates were extracted from the official template pack.

The sandbox initially hid installed SDK directories from Godot. A reviewed
tool execution with SDK access resolved this; no SDK reinstall or system setting
change was needed. Export then identified a missing ETC2/ASTC import flag;
enabled it in `project.godot` and successfully exported. No gameplay changes
were required. Final automated regression: 33 checks, zero failures.

Read-only `aapt` / `apksigner` checks:
- Package `com.minishoptycoon.offlinegame`, version 0.1.0 / code 1.
- Minimum SDK 24 (Android 7.0), target/compile SDK 36.
- ARM64 and ARMv7 native libraries; portrait orientation enum 1.
- No requested Android permissions; in particular no INTERNET permission.
- Android backup disabled.
- APK verifies with v2 and v3 signatures. This is a debug key, not release signing.
- APK archive contains product JSON, main scene and compiled gameplay scripts;
  test scripts, docs and tooling are excluded.

SHA-256:
`B4377C4D02A8EBD65439BB8A9ED813A658E249343BF6851A43664EEBDC5ECA03`

APK generation/signature checks do **not** prove installation or runtime behavior
on a real phone. Those tests remain pending. No current Play policy compliance
or publication readiness is claimed.

Manual steps and exact expected coin amounts: `docs/testing.md`.
