# Phase status — 27 October 2026

Current checkpoint: **Phase K toolchain follow-up — v0.13.1/code 15**.
User continued after candidate checkpoint 005d57c. Phone measurements and signing
remain deferred; no new key, account access or store publication is authorized.

- Added reproducible preparation of Godot 4.7.2 generated Android templates:
  AGP 8.11.1, Gradle 8.13 with official SHA256, NDK 28.2.13676358, build-tools 36.0.0.
- Real base manifest metadata resolves missing exporter-overlay replacements.
  Original API compatibility/native stripping warnings resolved. Future Gradle 10
  Groovy assignment deprecations and experimental path-check notice remain.
- Local non-persistent/plain-console Gradle execution avoids retained build process
  cleanup waits. Global Gradle settings and unrelated build processes stay intact.
- Clean template extraction/preparation/export tested end-to-end. Separate debug
  APK, unsigned release APK and unsigned AAB rebuilt and verified at 0.13.1/code 15.
- 595 Godot checks plus 10 PowerShell setup checks pass (605 total). Setup checks
  cover pinning, preservation, idempotence and fail-before-write for missing tools
  and unknown templates; both PowerShell runner contexts were tested.
- APK signature/zipalign, AAB bundletool/16KB config, ARM64 ELF alignment, manifest
  permissions/category/version and artifact content checks pass. See
  docs/test_report_toolchain.md and docs/artifacts_phaseK.json for exact evidence.

Commit/push the complete follow-up and verify remote hash. Device FPS/PSS/thermal,
low-end and 16KB runtime tests, owner signing, privacy/contact/store forms and store
acceptance remain release gates. Last verified phone install is v0.11.0/code 12.
No Android performance or production-readiness claim. Gameplay/economy/schema 8,
floating joystick, compact HUD and automatic handling remain intact.
