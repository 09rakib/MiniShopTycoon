# Phase 3 test report — 18 October 2026

## Scope

User requested continuation from Phase 2. Implemented Phase 3 only: shelf
upgrades, six shop levels, XP, product unlocks, milestones, next objective and
level-up feedback. Existing saves retain their previously available products.

## Passed

- Godot 4.7.2 headless editor import and script compilation.
- **128 checks, zero failures**; no script/runtime errors in the final test log.
- Original 88 economy/inventory/save/customer checks retained. Prior Phase 2
  tests explicitly grant prior access when exercising all-product transactions;
  separate fresh-save tests enforce the new locks.
- Upgrade prices, group-specific capacity, insufficient funds, level gates,
  step limit, maximum stock, unknown IDs and restocking-reserve safeguard.
- Every level threshold and product unlock boundary; final XP display.
- Schema 3 JSON and disk round trips with 50 units on an upgraded shelf; invalid
  upgrade levels/retained IDs rejected without mutating live state.
- Phase 1 migration regression plus Phase 2 retained access, and persistence of
  retained access in subsequent schema 3 saves.
- Actual upgrade button signals, immediate disk save, inventory lock/capacity
  states, growth-screen navigation, popup pause/dismiss/resume and full reset.
- A deterministic 170-sale fresh-shop playthrough, including a purchased upgrade,
  reaches level 6 with all six milestones complete and reconciled cash ledger.
- Real Godot rendered captures inspected at 480×900 and 360×640: growth cards,
  locked inventory, goal list, shop, purchased upgrade and level-up dialog.
  Long screens use vertical scrolling.

## Issues found and fixed

- Default dark popup background conflicted with the app's green text. Added a
  light popup panel/title border and dark text for disabled buttons.
- Godot resets built-in dialog button sizes; used AcceptDialog theme minimum
  width/height constants to provide 52-pixel-high touch targets. Reference:
  https://docs.godotengine.org/en/stable/classes/class_acceptdialog.html
- Prevented an upgrade from leaving a shop with no stock or restocking money.

## Android

- Final export completed successfully with exit code 0 after the UI fixes.
- `builds/MiniShopTycoon-phase3.apk`: **57,652,484 bytes** (~55 MiB).
- Package `com.minishoptycoon.offlinegame`, version 0.3.0 / code 3.
- Minimum SDK 24, target/compile SDK 36, ARMv7/ARM64, portrait, backup disabled.
- No requested permissions, including no INTERNET permission.
- APK v2/v3 signature verifies. Signing certificate SHA-256 matches Phase 2,
  supporting a same-app update; installation on a real phone remains unverified.
- SHA-256: `EC18D68B9389BE5F272E428847B41FA28F3FD758D576639A53C99B1D3E8171BE`.

## Not run

Real Android update/install, actual save migration on the user's phone, touch
controls, airplane-mode play, process death and physical device performance.
No measured FPS, battery, memory or release-readiness claim. Full save/lifecycle
hardening remains Phase 4. Offline income/reward claims remain Phase 5.

Manual steps: `docs/testing.md`. Phase 4 must wait for user continuation.
