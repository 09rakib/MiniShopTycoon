# Phase F verification — 19 October 2026

Engine: Godot 4.7.2 stable on Windows. Desktop visual checks use Compatibility
OpenGL on NVIDIA GTX 1650; these are not mobile performance measurements.

## Implemented / changed files

- data/cash_pickup.json, scripts/cash_pickup.gd: configured finite proximity check
  against the existing world cash marker, bounded poll/retry timing.
- scripts/economy_manager.gd and game_manager.gd: exact cash → wallet transfer,
  safe ceiling checks, immediate combined save, rollback on failure, reward event.
- scripts/burger_sales.gd: separate derived gross-profit/collected totals, keeping
  historical revenue/sold count unchanged when cash is collected or spent.
- scripts/world/playable_shop.gd: nearby automatic pickup, menu/pause blocking,
  failure retry cooldown and clear compact cash HUD inside its panel.
- shop_fixture.gd, shop_floor.gd, shop_world.gd: original capped note stacks,
  empty plate, amount, pickup marker and one reusable floating reward/tween.
- tests/run_cash_tests.gd, capture_cash.gd, test.cmd: new test/capture integration.
- Version/export launchers and phase/architecture/testing docs updated to F.

## Actual results

- Economy 128/128, world 34/34, production 32/32, handling 44/44, customers 39/39,
  cash 34/34. **311 checks passed, zero failures.** Final logs have no script errors,
  runtime errors or resource-leak warnings.
- 10,000 repeat empty pickup attempts cannot pay twice. 10,000 sale/collection
  cycles accrue exactly 200,000 collected coins plus the starting 500 wallet,
  with zero pending cash and unchanged correct sales/revenue totals.
- Aggregation, radius boundary, distant/NaN/infinite positions, empty pickup,
  spawn/delivery exclusion, full wallet/all-or-nothing ceiling and schema 6 JSON
  continuity passed.
- Actual 150 ms scene timer collects while nearby, blocks menu/suspension/controls,
  refreshes cash plate/wallet HUD, and produces one animated +amount reward.
- Reward observer reloads disk and sees both balances already saved. Collected
  cash does not reappear on restart. New sales while standing near cash pay only
  the newly earned amount.
- Actual unavailable subdirectory causes file-open save failure: wallet/pending
  rollback passed. Blocked storage failure also restores both sides, shows error,
  starts cooldown and preserves cash for exactly-once retry after recovery.
- App pause/resume flush preserves wallet/pending/revenue totals.
- Real rendered cash waiting/collected inspected at 480×900 and 360×640. Cash HUD
  initially overlaid machine art; it was moved inside the top panel and rechecked.
- No remaining automated failure. No new save schema needed; schema 6 already
  serializes both wallet and pending cash and earlier migrations remain intact.

## Android artifact actually verified

- builds/MiniShopTycoon-phaseF.apk: **57,712,816 bytes**.
- SHA256: 47EF66BB147C6255E2A61E002FF632B1933C6F0226339A3CA6092A53D7F9CAD4
- Debug export succeeded. apksigner v2/v3 verification passed.
- aapt: com.minishoptycoon.offlinegame, v0.8.0/code 8, min SDK 24,
  target/compile SDK 36, ARMv7/ARM64, portrait, backup disabled.
- aapt permissions output contains no requested permissions.
- Android SDK build tools 36.0.0, Android Studio bundled JBR 21.

## Not run / known limits

No phone install retry after prior explicit device refusal. Physical touch,
multitouch, on-device update migration, lifecycle/airplane mode, FPS/memory/heat,
low-end and release/store acceptance remain untested this checkpoint. Update
instructions are in testing.md. Floating collection effect is visual; no new
sound asset required. Burger machine upgrades/employees remain Phase G.

Source, original visuals, tests and docs are published at the phase checkpoint.
APKs, local saves/cache/tooling/signing credentials remain ignored. Stop before G
for user feedback; do not implement the next phase without continuation approval.
