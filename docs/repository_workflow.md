# Repository workflow — user instruction, 19 October 2026

Repository: https://github.com/09rakib/MiniShopTycoon.git

The user requested uploading all current source before beginning the next phase,
then committing and pushing immediately after each subsequent phase is finished.
Keep this instruction across sessions. A phase checkpoint must include source,
assets, tests, documentation, actual verification results and updated phase status.

Do not commit Godot binaries/cache/export templates, APKs, local player saves,
keystores, signing credentials, downloaded tooling or personal phone screenshots.
These are local artifacts excluded by .gitignore. Retain working artifacts locally.
Never force-push or overwrite unrelated remote work; inspect remote state first.
If authentication/network blocks a push, preserve the local commit and report
the exact blocker. Do not claim an upload succeeded without remote verification.

Current scope: Phase K candidate after J (876406a), authorized 23 October. The user
explicitly deferred phone performance tests and selected unsigned candidates plus
signing instructions. Publish source/tests/docs and verify the remote hash; APK/AAB,
Gradle generated files and validators stay local/ignored. Do not generate a release
key or publish to a store. Device acceptance and owner signing remain outstanding.

27 October continuation after 005d57c: finish the toolchain compatibility follow-up
as v0.13.1/code 15, including prepared-template tests and rebuilt unsigned artifacts.
Commit/push this checkpoint as usual; phone/signing deferrals remain in effect.

Current task after 9d9b56d: user explicitly requested deleting the old-version menu
option and the old version itself. Remove retired UI/runtime/assets, keep save
compatibility, test/build v0.14.0 and commit/push. No store upload or signing change.
