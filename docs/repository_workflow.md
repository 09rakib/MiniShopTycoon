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

Current scope: Phase J, authorized by the user's next-phase request on 23 October
after Phase I (5e57af0, phone verification 93dda97). Complete save/lifecycle tests,
fixes, APK and docs; commit/push, verify remote hash and stop before K. The user
explicitly deferred this version's phone testing: finish APK and GitHub first.
