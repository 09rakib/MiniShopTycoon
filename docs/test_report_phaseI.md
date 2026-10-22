# Phase I verification — 22 October 2026

Scope: presentation, audio, persistent sound preference and menu transitions.
Game economy schema remains 8; no progress reset or offline income change.

## Automated checks

Godot 4.7.2, Compatibility renderer. Final headless run:

| Suite | Passed |
| --- | ---: |
| Economy | 128 |
| World | 34 |
| Production | 32 |
| Handling | 44 |
| Customers | 39 |
| Cash | 34 |
| Operations | 69 |
| Expansion | 50 |
| Touch | 29 |
| Polish | 50 |
| Total | 509 |

All passed, zero failures, script errors, engine errors or warnings in final logs.
The polish suite also passed all 50 checks in a desktop OpenGL window with actual
audio playback enabled. Headless runs validate routing and pool bounds without
starting playback: the headless Dummy mixer retained active WAV playback objects
at immediate test shutdown, so it uses a silent sink. Desktop and Android retain
real playback. No change to gameplay transaction behavior was needed.

New checks cover preference default/type validation/replacement/write failure,
eight short mono clips, cooldown, menu mute/persistence, successful transaction
events and rejected duplicates/empty operations, 2,000 pooled effects without node
growth or stock/money mutation, cue expiry, focus clear/resume, static/full-machine
processing and rapid menu fade/close races. Existing touch regression still tests
real viewport events and automatic pickup/service/cash timers.

Rendered and inspected pickup, sale/bag/thanks, patience and menu states at 480×900;
the menu also fits 360×640. Captures: polish-*-preview.png. Device captures remain
local under ignored builds. Rendering is verified; a human listening check for
comfortable tone/volume remains manual acceptance.

## Android artifact

- `builds/MiniShopTycoon-phaseI.apk`, debug v0.11.0, version code 12.
- Package `com.minishoptycoon.offlinegame`, min SDK 24, target 36.
- ARMv7 + ARM64, portrait orientation 1, allowBackup false, no app permissions.
- Size 57,773,277 bytes.
- SHA256 `38C61F0913E762C0EBB17A524B8AFA884A9EEE266A421B110D53ACF491C8481D`.
- apksigner verification passes v2/v3; aapt metadata/manifest inspected.

Phone update: vivo V2405A connected at the user-provided wireless endpoint.
First adb install -r was rejected by the phone installer; after user confirmation,
retry reached vivo Super Care's per-app authorization screen. Its protected
confirmation is pending on the phone. At this checkpoint dumpsys still reports
v0.10.1/code 11, so Phase I is not yet claimed installed. No data clearing/uninstall.

## Manual acceptance / limits

Listen on the phone with system volume on: pickup/service/cash should be brief and
quiet; mute must stop every cue and remain off after reopening. Walk away/back,
open/close sheets quickly, Home/resume during pickup, and verify no stale movement
or delayed sound. Customer patience is visual only and follows the existing wait
timeout; no extra sale or money is granted by presentation. Four effects and four
voices are reused; newer events can replace older feedback. Idle fixtures stop
processing, active machine redraw is limited to 10Hz and wait meters to 4Hz.

Phase J comprehensive save/lifecycle audit and Phase K measured Android performance
and release remain pending. No FPS, battery, thermal or release-readiness claim.
