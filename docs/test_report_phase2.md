# Phase 2 test report — 18 October 2026

## Scope and environment

User authorized continuation after Phase 1. Implemented Phase 2 only; Phase 3
is pending. Same Godot 4.7.2 and Compatibility renderer as Phase 1.

## Passed

- **88 automated checks, zero failures**, including all original 33 regressions.
- Ten-product catalog validation, separate buy/sale accounting for each product,
  loading every original SVG icon, single/batch orders, exact capacity, zero,
  negative and INT64_MAX quantity rejection, currency ceiling without stock loss.
- Negative/zero/fractional configured prices, duplicate IDs, invalid shelf paths
  and customer timing rejected by catalog validation.
- Actual Phase 1 JSON shape tested through migration and disk load/write/reload:
  original cash/stock/sales retained, new products zero, purchase spending derived
  correctly, schema 2 written. Missing original data/current-schema stock and
  negative ledger rejected without applying invalid state.
- Real inventory button signals, all ten cards, visible insufficient-funds
  feedback, full-capacity disabled actions, paused inventory customers, Android
  Back handler and a new-product customer transaction.
- New-product customer shelf coordinates remain inside the visible shop.
- Rendered menu/shop/inventory in real Godot; inspected shop plus inventory top,
  bottom, and compact captures at 480×900 and 360×640. No clipped card labels or
  horizontal overflow observed. Shop footer can require a small vertical scroll.

## Errors found and fixed during development

- JSON numbers deserialize as floats. A strict array-membership schema check
  rejected disk records; replaced it with validated integer-range checking.
  Existing disk recovery/pause persistence regression tests caught this.
- Directly referencing a UI class from the SceneTree test entrypoint compiled
  it before the Game autoload existed. Deferred UI loading until startup; reran
  the full suite with no compile/runtime errors. `test.cmd` now also detects
  engine log errors so a script error cannot be hidden by a zero process status.

## Android build verification — passed

- Export completed with exit code 0 using the existing SDK and matching templates.
- `builds/MiniShopTycoon-phase2.apk`, **57,635,242 bytes** (~55 MiB).
- Package `com.minishoptycoon.offlinegame`, version **0.2.0**, version code **2**.
- Minimum SDK 24 (Android 7.0), compile/target SDK 36, ARMv7 and ARM64.
- Portrait orientation, Android backup disabled, **no requested permissions**.
- APK v2/v3 signature verifies; Phase 1/2 signing certificate SHA-256 matches.
  Supports normal same-app updates; actual phone installation remains untested.
- SHA-256: `AE8F7C84A5B464D43057B2BF12260922306CBD38C799F33E68AAAADD15A829B0`.

## Not run / limitations

- Android installation/update and actual on-phone save migration, touch scrolling,
  airplane-mode, lifecycle, process death and FPS/memory/battery measurements.
- No measured 60 FPS or publication-readiness claim. Release AAB/signing and
  current Play policy verification remain Phases 8–9.
- General migration/default policies beyond schema 1→2 remain Phase 4.
- Audio, levels, upgrades, employees, offline earnings and goals remain future work.

Manual expected values and phone steps: `docs/testing.md`.
