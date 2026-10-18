# Transformation Phase B report — 18 October 2026

## Implemented

Phase A audit/backups and Phase B movement only. New entry scene, original 2.5D
world, worker, four-direction/analog joystick, collisions, camera, compact HUD
and preserved management features. No C–K gameplay systems were implemented.

Changed groups: new `scenes/playable_shop.tscn`, `scripts/world/*`, world layout
JSON, project entry/version, export preset/launcher, embedded legacy Back guard,
world tests/captures and documentation. Prior source snapshot exists at
`builds/backups/phase3-before-world.zip`; old APKs remain.

## Desktop checks — passed

- Godot 4.7.2 editor import and new entry scene startup.
- Existing **128** economy/inventory/upgrade/save regression checks pass.
- New **34** world checks pass: one-finger capture, unrelated touch/release,
  diagonal normalization, cancellation, pause/focus reset, immediate stop,
  actual physics collision with machine/counter/all four walls, clear corridor,
  three camera boundary cases, follow smoothing, modal input blocking, legacy
  inventory integration, unchanged coins/stock and schema-3 load compatibility.
- **162 total checks, zero failures** in final successful runs. Added real
  viewport-dispatched centered press, upward drag and release checks. GUI input
  receives local touch coordinates; global drag events are transformed separately.
  The routed press test waits for actual event dispatch before asserting state.
- Rendered world/machine/menu captures inspected at 480×900, 360×640 and
  480×1040. World takes the primary screen; primary controls stay separated.

## Issues found and resolved

- Renamed the joystick script type to ShopJoystick after a runtime constructor
  resolved a VirtualJoystick object without the intended script methods.
- Corrected the lower-left instruction anchors and adjusted initial zoom/layout
  to keep the machine and serving counter readable in the opening frame.
- Camera smoothing test initially ran against the headless default landscape
  viewport; set the intended portrait size before testing camera behavior.

## Android verification

- Built `builds/MiniShopTycoon-phaseB.apk`, v0.4.0/code 4, 57,682,656 bytes.
- APK v2/v3 signatures verify; minimum SDK 24, target 36, ARMv7/ARM64; no requested
  Android permissions. SHA-256:
  `1372BE4DA9B54298F69C47F59556E9911DE0035878C38AB94C7921BAEECE0E21`.
- Installed as an update via ADB on vivo V2405A; reported Success. Cold launch
  reported Status: ok. Actual phone screen showed the world, worker and joystick,
  with the pre-existing 129 coins and level 2 still visible.
- Two ADB joystick gestures changed worker position/camera framing. Captured
  before/after screens in `builds/phone-phaseB-*.png` (not committed to Git).
  These gestures are a smoke check; physical touch comfort/direction/cancellation
  and sustained play remain subject to the user's manual feedback.

## Not yet verified / limitations

- Physical touch cancellation/multitouch, sustained play, low-end-device frame
  times, memory/battery, airplane mode and process-death QA need user tests.
- Production/carrying/queue sales/cash collection are deliberately absent in B.
- Worker position resets to its safe spawn on relaunch. Wallet/inventory/levels
  and previously purchased upgrades remain persisted using the existing schema.
- No measured FPS or complete burger-loop claim is made.

Next manual checkpoint: `docs/testing.md`. Stop here before Phase C.
