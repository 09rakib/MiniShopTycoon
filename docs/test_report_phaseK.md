# Phase K candidate verification — 23 October 2026

Historical v0.13.0/code 14 snapshot. Current v0.13.1 artifacts reuse the local
filenames; see test_report_toolchain.md and artifacts_phaseK.json for latest hashes.

User authorized continuation after J, then explicitly deferred phone measurements
and requested unsigned release candidates plus signing instructions. This is the
candidate checkpoint; Android performance/signing/store acceptance remain pending.

## Changes and regression

Chef and machine drawing styles are cached by color/radius, avoiding repeated
StyleBoxFlat allocation during redraw. Different palette/radius combinations retain
separate resources and original geometry. Tests perform 10,000 repeated lookups for
each cache, exercise bounded customer/ticket/audio pools and reopen/close grocery
overlays to verify nodes are released. No simulation/economy/save changes in K.

**595 checks pass with zero failures** across twelve headless suites (previous 585
plus 10 performance-bound checks). Final regression logs have no engine/script
errors or warnings. Resource bounds are not Android FPS measurements. Exporter
inspection diagnostics are separate from the clean test runs.

Android category was previously exporter index 0 (Accessibility). Inspection of
the actual installed exporter enum identified Game as index 2; final manifests
use Android category 0/Game and isGame true. AAB SDK min/target are explicitly
24/36. Non-Gradle APKs use verified matching template levels; SDK overrides there
are invalid, and end-to-end wrapper testing caught/corrected that configuration.

## Desktop benchmark

Godot 4.7.2 Compatibility/OpenGL, Windows, NVIDIA GTX 1650, 480×900, 60 FPS cap.
Per scenario: 60 warmup frames then 180 frame-interval samples. Expanded shop has
fries/furniture/stocker and up to four customers. Busy runs simulation, menu keeps
the world running behind its overlay, idle pauses controllers/presentation.
Raw before/after JSON is checked in beside this report. Saves are isolated.

| Scenario | Before median / p95 ms | After median / p95 ms | After peak draws / nodes |
| --- | --- | --- | --- |
| Busy | 16.668 / 17.530 | 16.667 / 16.974 | 285 / 117 |
| Menu | 16.653 / 17.159 | 16.661 / 17.440 | 291 / 117 |
| Idle | 16.666 / 16.846 | 16.666 / 17.034 | 239 / 115 |

The samples are capped desktop observations with normal scheduling/I/O noise, not
evidence of a statistically significant speedup. Peak engine static memory is
about 39.4 MB after caching; it is not Android PSS or total process/GPU memory.
Raw process-time monitor samples include outliers and are not used to infer FPS.
No phone, low-end, thermal, battery, ten-minute memory trend or 16KB runtime result.

## Build and static acceptance

Three presets: debug APK, unsigned release-template APK and unsigned Gradle AAB.
build-release.ps1 was exercised end-to-end for both formats, removing a stale
target first and rejecting engine errors/missing artifacts. The AAB wrapper also
runs the local official bundletool validator when available. Generated Android
template/caches and downloaded validator are ignored; reproducible setup is in
release_preparation.md. No signing key was generated and nothing was submitted.

Artifact audit checks ZIP CRC, no tests/docs/tools/private save/key leakage,
required AAB structure and native ELF load-segment alignment. ARM64 engine/C++
libraries have 16KB alignment; ARMv7 has 4KB alignment (the 16KB Play rule concerns
64-bit native code). APK zipalign -c -P 16 4 passes. Bundle config specifies
PAGE_ALIGNMENT_16K and bundletool 1.18.3 validate returns 0. Release candidate
manifest is not debuggable, has no uses-permission entries and disables backup.

The Godot-supplied AGP 8.6.1/Gradle 8.11.1 template emits compileSdk 36 compatibility,
manifest replacement and native stripping warnings; first template-install export
also reported editor scan/cleanup warnings. Later normal export completes. These
are documented build-tool limitations, not hidden behind the clean regression
claim. Toolchain integration review/upgrade and real device validation remain
before store acceptance. See release_preparation.md for primary references.

## Handoff and limits

Use the debug APK to update the existing debug phone installation without clearing
data. Unsigned APK/AAB require the owner's key before distribution; a differently
signed release cannot update that debug app. Last verified phone install is still
Phase I v0.11.0/code 12. The user deferred K installation/performance testing.
Privacy/listing drafts need developer contact, public URLs, owner review and store
form completion. No Play account, policy approval or production readiness claim.

Final artifact hashes/sizes are recorded below after validation.

| Artifact | Bytes | SHA256 |
| --- | ---: | --- |
| MiniShopTycoon-phaseK.apk | 57,777,373 | `4F3BBD005AD944B06BCFB911E0875C23EE7B94AA0CDF4E059524958C6EE5442D` |
| MiniShopTycoon-phaseK-unsigned.apk | 52,551,179 | `6E2F258A496873C4B4DC671A8A4D316E5444BEDA5C7061556BBC60208C6DA1D0` |
| MiniShopTycoon-phaseK-unsigned.aab | 52,533,502 | `D01FE8EACB03EF65DA75A68F750C618C1DFA78624F21B6DDEFD67444CFAB2BD1` |
