# Android toolchain follow-up — 27 October 2026

Scope: finish the Phase K build-tool compatibility work. User's earlier choices
remain: unsigned release candidates, no phone testing or new signing key.
v0.13.1/code 15 keeps package identity and economy schema 8; gameplay is unchanged.

## Reproducible setup

prepare-android-build.ps1 adjusts only generated Android template files. It pins
AGP 8.11.1, Gradle 8.13, NDK 28.2.13676358 and build-tools 36.0.0. The Gradle wrapper
uses official SHA256 `20f1b1176237254a6fc204d8434196fa11a4cfb387567519c61556e8710aed78`.
The installed NDK's strip executable must exist before preparation proceeds.
Matching Godot 4.7.2 source templates are extracted when absent, with build version
and ignore markers written before export. Generated sources/caches remain ignored.

Base manifest metadata now declares the actual GL compatibility renderer and
editor version, giving the generated overlay valid declarations to replace.
No warning suppression is used; custom metadata and unrelated settings survive.
AGP's [official compatibility table](https://developer.android.com/build/releases/agp-8-11-0-release-notes)
lists API 36 support and Gradle 8.13. The checksum was read directly from the
[official Gradle distribution endpoint](https://services.gradle.org/distributions/gradle-8.13-bin.zip.sha256).

## Tests

595 existing Godot checks pass across all twelve suites, zero failures and clean
regression logs. Ten new PowerShell setup checks pass (605 checks total): tool
versions, checksum replacement, base metadata, unrelated-data preservation,
byte-identical repeated preparation and fail-before-write for missing NDK,
unknown wrapper format or incomplete template settings. Test files and fake SDK
fixtures are isolated under ignored tools/; actual export uses the real installed NDK.

The build wrapper rejects stale/missing artifacts and engine errors and audits ZIP
CRC, excluded/private content and ARM64 ELF alignment; bundletool validates AABs.
Runtime phone measurements, 16KB device tests, low-end/thermal tests, owner signing
and store acceptance remain pending. Last verified phone version is still 0.11.0.

## End-to-end acceptance

An existing generated template was prepared and exported, then safely moved aside
inside ignored android/ to exercise the clean extraction path. Fresh template
extraction, preparation, unsigned AAB export, artifact audit and bundletool validation
all passed. Only the checked generated backup was removed afterward. Release APK
and debug APK were rebuilt from the same v0.13.1 source. No player data was touched.

The first export outlived compilation while its persistent Gradle daemon remained;
project-local non-persistent/plain-console settings avoid retained build processes.
No global Gradle configuration was changed. Setup tests also passed under the
Windows PowerShell runner used by test.cmd (normal permission context).

The upgraded build no longer emits the original unsupported-API, missing metadata
replacement or unable-to-strip notices. Template Groovy DSL assignment deprecations
for future Gradle 10 and the existing experimental overridePathCheck notice remain;
the pinned build is Gradle 8.13, and warnings have not been suppressed.

Final AAB: bundletool 1.18.3 validates, config uses PAGE_ALIGNMENT_16K, both ARM64
libraries pass ELF load alignment checks. Unsigned APK passes zipalign -c -P 16 4;
debug APK signature verifies v2/v3. Both release manifests have package
com.minishoptycoon.offlinegame, version 0.13.1/code 15, min/target SDK 24/36, Game
category, backup disabled, no permissions and no debuggable flag. ZIP CRC/content
audits pass for all three outputs. No private saves, tools, tests, docs or keys leak.

Exact final hashes and sizes: artifacts_phaseK.json, also listed below. These
replace local filenames from the historical 23 October checkpoint.

| Artifact | Bytes | SHA256 |
| --- | ---: | --- |
| MiniShopTycoon-phaseK.apk | 57,777,373 | `5769236407069435A9D60C7DC9F5980A4C44128A7855BD183685AEFBE8AE1B7D` |
| MiniShopTycoon-phaseK-unsigned.apk | 52,551,179 | `99ED4097A8AA4A8DAC86C8F8119BCA67CE8A3C8A43AA1DF8EB5F9A9B63926108` |
| MiniShopTycoon-phaseK-unsigned.aab | 52,530,994 | `F098E9370D85D8917492BADDB0A68C7D4732D38CB10431C6E40118AE7FDDE028` |
