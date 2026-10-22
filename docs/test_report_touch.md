# Requested touch/control update — 22 October 2026

Scope: floating hidden joystick, smaller organized HUD, automatic food pickup,
service and existing cash collection. No additional full Phase I expansion.
Engine: Godot 4.7.2 on Windows; Compatibility OpenGL/GTX 1650 for desktop images.

## Changed implementation

- virtual_joystick.gd: full-viewport passive control, unhandled initial touch after
  GUI, explicit Menu exclusion, gesture origin from touch, captured drag/release,
  one-finger ownership, zero initial movement, dead-zone/normalized speed,
  cancellation/focus/menu release. Idle draws nothing. Base/thumb alpha 14%/32%.
- playable_shop.gd: compact horizontal wallet/level row and slim status line,
  content height under 80 logical pixels and 44px Menu target. Removed fixed
  joystick zone, Collect/Deliver buttons and keyboard action requirement.
- Nearby Timer now auto-transfers available food at actual worker position every
  150 ms, then collects cash and updates context. Blocked/menu/paused/suspended
  state prevents transactions. Existing capacity/food-type/distance rules and
  persistence remain authoritative; no new save schema or progress reset.
- Existing handling/world/expansion UI tests and capture scripts updated to the
  requested interaction contract. Added dedicated actual input/timer regression
  suite and new render captures, plus test launcher/version/export/docs updates.

## Actual final verification

Economy 128/128, world 34/34, production 32/32, handling 44/44, customers 39/39,
cash 34/34, operations 69/69, expansion 50/50, touch **29/29**.
**459 checks passed, zero final failures.** Final logs have no script/runtime
errors, leaks or warnings. Existing stock/money conservation cases remain intact.

Actual viewport touch starts joystick on right-hand screen area, actual drag
moves worker, release outside hides/stops. Next gesture relocates origin; second
finger cannot recenter/release; jitter/diagonal bounds/cancel work. Real Menu touch
never starts movement. Menu/focus loss clears controls and resume needs fresh touch.
Synthetic GUI input tests settle the event queue after release before subsequent
menu state assertions, matching actual engine dispatch timing.

Actual proximity timer picks two burgers without tap, cannot repeat with full
hands, persists both inventory sides, auto-delivers at counter and preserves
partial/full leftovers. Menu/suspended/distant worker cannot transfer. Fries
also auto-picks and delivers to separate shelf; cash transfers exact proceeds
once and survives reload. All older upgrade/employee/fries/furniture/save tests pass.

Five rendered captures inspected: idle hidden joystick, faint floating joystick,
auto pickup, auto service and compact portrait. 480×900 and 360×640. New HUD is
under 80 logical pixels in tests; no fixed action controls occupy bottom world.

## APK actually verified

- builds/MiniShopTycoon-touch-update.apk: **57,738,416 bytes**.
- SHA256: 8F5A0122842576C9F5353E90C7B70F5395506370EC01E2967F21ECE5B4FE48DE
- v0.10.1/code 11, package com.minishoptycoon.offlinegame.
- Debug export succeeded; apksigner v2/v3 signatures verified.
- aapt: min SDK 24, target/compile SDK 36, ARMv7/ARM64. Portrait and no internet
  permission retained from same preset. No schema 8 migration needed for patch.
- SDK build tools 36.0.0, Android Studio JBR 21.

## Phone / limits

Initial wireless discovery found vivo V2405A, but connection disappeared before
install, so adb install -r returned device not found. Restarted ADB and checked USB
interfaces/discovery; no active debugging device was listed. User re-enabled
connection; current wireless IP/port requested because discovery remained empty.
Installation/launch is pending a working connection; prior Phase H was installed.
No claim of this patch running on phone until actual successful update and launch.

Scripted input verifies logic but does not replace physical user feel/multitouch
review. No measured FPS/memory/heat, low-end or airplane-mode test claimed here.
Joystick can clip visually near edges but keeps its exact origin. Stocker/fries/
furniture limits remain H scope. Production-only saves batch five seconds, no
offline income. Publish complete source/tests/docs and stop for user feedback.
