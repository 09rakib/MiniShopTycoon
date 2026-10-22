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

Current scope: Phase I, authorized by the user's next-phase request after the
touch update (b9fc270 and phone verification 26a6dd5). Complete visual/audio polish,
test/build/update the connected phone, document, commit/push and stop before J.
