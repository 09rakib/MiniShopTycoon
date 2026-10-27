# User touch/control update — manual checkpoint

Install builds/MiniShopTycoon-touch-update.apk (v0.10.1/code 11) as an update.
Keep app data; schema 8 and all previous progress remain compatible.

1. Start game without touching. No joystick should be visible. HUD shows compact
   wallet/level and a slim carry/counter/cash line; the world stays prominent.
2. Touch empty left/right/upper/lower gameplay area. Joystick should appear under
   that finger at low opacity. Initial press alone must not make worker jump.
3. Drag to move, including diagonals; diagonal speed must stay normalized. Release
   anywhere: movement stops and joystick disappears. Touch another position:
   next joystick appears there. Small finger jitter should not move the worker.
4. Use another finger while moving. It must not recenter/release the first gesture.
   Tap Menu: controls stop and hide, no accidental movement. Back/close works as
   before; return to shop requires a fresh gameplay touch.
5. Walk near burger press: automatically pick up available food to maximum two.
   No Collect button or repeated taps. Remain there: no duplication with full hands.
6. Walk to serving counter: automatically deliver into correct shelf. Full counter
   retains carried food; partial space delivers only what fits, keeps the rest.
7. Unlocked fries works the same: automatic pickup at FRIES and service at DELIVER,
   one food type per trip. Stocker/upgrade/furniture behavior remains unchanged.
8. Let customers buy. Walk to CASH: exact pending amount enters wallet automatically,
   once. Leaving/returning to empty plate must not grant extra coins.
9. Open management while near stations, Home/resume, Back, multitouch cancellation.
   No movement/transfer during blocked menu or suspension; no stuck joystick.
10. Restart after auto pickup/service/cash. Items and balances persist, no duplication.
    If the safe spawn is inside a station, the restored food may auto-deliver there.

## Automated / rendered verification actually run

459 checks pass across all nine suites: 128 economy, 34 world, 32 production,
44 handling, 39 customers, 34 cash, 69 operations, 50 expansion, 29 touch.
Existing input/handling tests were adapted from removed fixed-button interactions
into floating and automatic interaction checks; underlying conservation tests stay.
test.cmd flags script/runtime errors as failures. Touch tests route actual events,
check finger ownership/UI blocking/opacity/HUD height, drive real worker movement
and real 150 ms pickup/service/cash timers, limits and persistent exact quantities.
Idle/floating/auto pickup/serve/compact layouts rendered and inspected at 480×900
and 360×640. On vivo V2405A, adb update succeeded, v0.10.1/code 11 launched,
compact HUD/hidden idle joystick and one injected floating touch gesture were
inspected. Physical feel/multitouch user review remains pending. See
test_report_touch.md for actual APK and phone verification.

## Phase I verification

509 headless checks pass: the above 459 plus 50 polish checks. Desktop with actual
audio playback also passes the 50 polish checks; all final logs clean. test.cmd
includes run_polish_tests.gd. See test_report_phaseI.md for exact artifact/results.
New desktop previews cover quantity effects, bag/thanks, patience and sound menu,
including 360×640. Listen on the phone for comfort, toggle sound/relaunch and test
Home/resume/rapid menu transitions while carrying. No measured FPS, low-end/heat
or release acceptance claim. Stop before Phase J until user continuation.

## Phase J verification

Phase J was subsequently authorized. All 585 checks pass across eleven suites:
509 earlier checks plus 76 lifecycle checks. Schema 1–8 disk roundtrips, invalid
nested state, backup/temp recovery, future-save guards, safe reset failure,
transaction rollback/retry, progression and twenty reload-while-carrying journeys
are covered. Actual controller notification injection verifies pause/focus guards.
See test_report_phaseJ.md for artifact/hash and limits. The user deferred physical
phone checks; no claim of Android kill/low-storage/performance verification.
Next phase is K, requiring user continuation.

## Phase K candidate verification

Phase K was authorized with phone measurements deferred and unsigned candidates
requested. All 595 checks pass: earlier 585 plus 10 resource-bound checks. They
exercise repeated style reuse, palette/geometry separation, bounded spawns/tickets,
overlay cleanup and unknown audio event handling. The expanded shop stays below
180 nodes in this fixture; that is a structural guard, not an FPS measurement.

Run `Godot --path . --script tests/benchmark_shop.gd -- --output=res://builds/benchmark.json`
with the local profile to capture desktop rendered idle/busy/menu samples. Checked-in
before/after JSON is Windows/GTX 1650 data with a 60 FPS cap, not Android evidence.
Candidate audits, bundletool/native alignment checks, hashes, toolchain warnings
and remaining device/signing gates are recorded in test_report_phaseK.md.

## Android toolchain follow-up

The existing 595 Godot checks pass after the v0.13.1 version refresh. Ten additional
PowerShell checks validate template preparation against isolated generated files:
explicit tool versions, distribution checksum, preserved settings/XML, byte-stable
rerun and failure-before-write for missing NDK/unknown formats. test.cmd now invokes
both runners (605 total checks). End-to-end bundle verification and remaining
notices are recorded in test_report_toolchain.md; no physical device claim.

## Current-only shop verification

v0.14.0 removes the retired grocery UI/icons/customer loop and its runtime APIs.
Tests solely for those deleted features were removed. Pure economy/save migration
checks remain, while world/performance navigation tests now exercise the current
workshops. The world suite also rejects the deleted scene/entrypoint/menu labels.
567 checks pass across twelve Godot suites and ten PowerShell setup checks. APK/AAB
content audit rejects retired files. See test_report_current_only.md for actual
artifact evidence and rendered current menus at 480×900 and 360×640.
