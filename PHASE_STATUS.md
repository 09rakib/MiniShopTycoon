# Phase status — 22 October 2026

Current checkpoint: **User-requested touch/control update on completed Phase H.**

- H was published as be2891d (fries and fixed furniture). User then installed H
  on phone and requested floating joystick, compact HUD and automatic handling.
- Implemented those specific updates, not the whole later Phase I audio/polish.
- Joystick is invisible when idle. Touch on free gameplay screen starts it at
  that location; drag moves the worker, release/cancel hides and stops it.
  14% base/32% thumb opacity; new gestures can start anywhere. No fixed control
  area. Menu/management input is protected and cannot start worker movement.
- Captured finger owns a gesture; other fingers do not recenter/release it.
  Diagonals normalize, small jitter stays in dead zone. Focus/pause/menu clears
  touch and movement; resume requires a fresh touch. Mouse drag works on desktop.
- Compact top HUD has one horizontal wallet/level row and a slim carry/counter/
  pending-cash line. Content height under 80 logical px, Menu at least 44 high.
- No Collect/Deliver buttons or desktop action-key requirement. Nearby poll every
  150 ms automatically picks available burger/fries into hands, delivers fitting
  food at counter and collects eligible cash. Current position is rechecked.
- Existing two-item/one-product carry, separate shelves, full/partial leftover,
  cash accounting, upgrades/stocker/furniture and saves remain intact. Empty/full
  interactions do not spam transactions; menus/blocked controls/pause prevent them.
- Schema remains 8; no migration/reset needed for this patch. Automatic food/cash
  transfers save immediately using existing authoritative transaction methods.
- 128 economy + 34 world + 32 production + 44 handling + 39 customers + 34 cash
  + 69 operations + 50 expansion + 29 touch = **459 checks passed, zero failures**.
- Touch suite uses actual viewport events and real nearby timer for movement,
  UI exclusion, lifecycle, automatic pickup/serve/full shelves, fries/cash/save.
- New idle/floating/automatic pickup/serve/compact previews rendered and inspected
  at 480×900 and 360×640. APK v0.10.1/code 11 debug exported and verified.

## Handoff

Artifact: builds/MiniShopTycoon-touch-update.apk. See test_report_touch.md for
exact verification and phone status. v0.10.1/code 11 was installed with adb -r
and launched successfully on the connected vivo V2405A. Compact/idle HUD and one
injected floating touch gesture were inspected on its 1260×2800 display. No
uninstall/data clearing; device screenshots stay local and ignored.
Commit/push the user-requested patch and verify remote hash, as with phase work.
Wait for user testing; do not silently expand into the remaining I/J/K scope.

## Manual acceptance

Touch different empty screen positions, drag, release; joystick appears there,
remains faint, disappears on release. Menu must never start movement. Walk to
press/FRIES: food is picked automatically, up to two. Walk to DELIVER: food serves
automatically; full/partial shelves retain leftovers. Walk to CASH: exact proceeds
collect once. Test Home/resume, second finger, small-screen readability and old
progress after update. Worker/customer positions remain transient; food is saved.

## Known limits

A joystick base stays at the initial touch for that gesture; next touch relocates
it. Interactive menu controls are excluded. Full counter keeps held food. A newly
loaded worker who is already inside an eligible station can interact automatically.
Stocker handles burgers; fries and dining limits are unchanged from H. Production
batches five seconds, no offline production/income or measured Android FPS claim.
