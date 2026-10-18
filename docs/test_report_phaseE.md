# Phase E verification — 19 October 2026

Engine: Godot 4.7.2 stable on Windows. Desktop render: Compatibility OpenGL,
NVIDIA GTX 1650. These are desktop checks, not Android performance measurements.

## Results actually run

- Economy 128/128; world/movement 34/34; production 32/32; handling 44/44.
- Customers 39/39, final logs clean; total **277 passed, zero failures**.
- 10,000 repeat sale attempts cannot charge twice. 10,000 complete single-burger
  production/pickup/delivery/sale cycles preserve food and accrue exactly 200,000
  pending coins with unchanged 500 wallet and no retained retired tickets.
- Last-item contention, empty/machine-only/held-only stock, unregistered/retired
  visits, active cap, ledger overflow, schema 5 migration, schema 6 JSON roundtrip,
  malformed records, real physics queue spacing/wait/checkout/exit, pause,
  patience timeout, blocked cleanup, counter collision, reset and immediate disk
  save of exact cash/counter results passed.
- During development, direct static controller typing in SceneTree script exposed
  autoload compilation ordering; test now gets the runtime Node. Another test
  inspected a freed object in a typed array; it now checks instance validity.
  A synthetic watchdog test originally reset its elapsed time while standing at
  the goal; it now tests an unreachable target. Final tests have no runtime errors.
- Real rendering captured and visually inspected queue/sale at 480×900 and
  360×640; state labels moved alongside heads to avoid queue label overlap.

## APK

- builds/MiniShopTycoon-phaseE.apk: **57,708,489 bytes**.
- SHA256: 3B3EEB85E11C181A0E613A2C61627C9D4264CE3615C881DF199A16D131BC004A
- Debug export succeeded, apksigner v2/v3 verification passed.
- aapt: com.minishoptycoon.offlinegame, v0.7.0/code 7, min SDK 24, target/compile
  SDK 36, ARMv7/ARM64 and no requested permissions. Portrait retained.
- Android SDK 36.0.0 tools; Android Studio bundled JBR 21.

## Not run / limits

No phone install attempted after earlier device installation refusal. No claimed
physical input, airplane-mode, on-device migration, lifecycle, FPS/memory, low-end
or release-store acceptance. Manual update/test instructions are in testing.md.
Cash collection remains Phase F; pending proceeds are intentionally unspendable.
Source, original assets, tests and docs are committed/pushed; APK/cache/local
saves/keys remain ignored. Stop before Phase F for user feedback.
