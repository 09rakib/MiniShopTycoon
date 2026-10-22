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
