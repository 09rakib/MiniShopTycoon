# Phase status — 23 October 2026

Current checkpoint: **Phase K candidate prepared — v0.13.0/code 14**.
User authorized K after J (876406a), explicitly deferred phone measurements and
requested unsigned release candidates with signing instructions.

- Cached drawing styles for chef/fixtures; fixed palette/geometry preserved.
- 595 automated checks pass across twelve suites with clean regression logs.
- Desktop busy/menu/idle benchmark captured on Windows/GTX 1650 with a 60 FPS cap;
  raw before/after JSON retained. It is not Android performance evidence.
- Separate debug APK, unsigned release APK and unsigned Gradle AAB produced.
  Both release build wrappers exercised end-to-end with stale-artifact/error guards.
- Android Game category corrected from actual exporter enum; SDK levels 24/36
  verified. No app permissions, backup disabled, release not debuggable.
- ARM64 ELF 16KB alignment, APK zipalign and bundletool structural validation pass;
  bundle config uses PAGE_ALIGNMENT_16K. Exact hashes: docs/artifacts_phaseK.json.
- Signing instructions, privacy/listing drafts and current primary policy links
  prepared. No signing key generated, account accessed or store upload performed.
- Native Gradle template emits compatibility/manifest/stripping warnings; documented
  in docs/release_preparation.md and docs/test_report_phaseK.md.

Publish this candidate source/assets/tests/docs checkpoint and verify remote hash.
Full release gates still pending: real Android FPS/PSS/thermal/low-end/16KB tests,
owner upload key and signed internal testing, toolchain review, developer/privacy
URL/store forms and acceptance. Last verified phone install remains Phase I
v0.11.0/code 12. Do not claim measured Android performance or store readiness.

APKs/AABs, generated Android sources, Gradle caches, validator and private captures
stay local/ignored. Floating joystick, compact HUD, automatic handling, saved
progress/schema 8, audio settings and prior gameplay remain intact.
