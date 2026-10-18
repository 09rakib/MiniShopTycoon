# Phase C — automatic production — 19 October 2026

## Scope

User requested a GitHub upload of all current code before the next phase, plus
automatic push on each future completed checkpoint. Initial source was pushed
as `1938b5b`; remote main hash verified before starting C. Only Phase C gameplay
is added: automatic, bounded, persistent production and configuration/visuals.

## Tests performed

- Previous economy suite: **128 passed**. World/input suite: **34 passed**.
- Production suite: **32 passed**, zero failures; including real two-second
  timers, no early production, cap at ten, stopped full timer, automatic restart
  after removal, paused/no-catch-up behavior, save flush and reset.
- 10,000 attempted production ticks at full capacity never generated extra stock.
- Invalid/overflow removals, malformed stock/levels/active flags, duplicate
  definition IDs and zero intervals are rejected in tests.
- Schema-3 grocery save migrates without losing cash, stock or upgrades. Schema
  4 machine JSON and disk saves round trip; malformed machine data causes no
  partial wallet or stock mutation. Production never credits coins, sales or XP.
- **194 total checks passed.** Rendered 6/10 and 10/10 machine states inspected.

## Design and files

`data/machines.json`, `scripts/production_state.gd` and
`scripts/world/production_controller.gd` implement common machine logic, tiers,
one-shot production timer and batched saving. Shop fixture draws up to ten
stocked burgers. Economy/Game persist/validate state and emit separate production
signals. Movement and old grocery features are preserved.

No pickup button or customer sales are added in C. Stock-removal/resume behavior
is exercised through the authoritative inventory primitive in automated tests;
the player-facing pickup/carrying loop belongs to Phase D.

## Android and Git

- Final APK export succeeded; v0.5.0/code 5, **57,687,179 bytes**.
- APK v2/v3 signature verifies; package com.minishoptycoon.offlinegame,
  min SDK 24, target 36, ARMv7/ARM64 and no requested permissions.
- SHA-256: `A575FDBA3F09D6EA2794AAFD084E92EECEC7AD88D73A5B3DF4EC6B2CE165207C`.
- Phone update attempted via `adb install -r`, but Android returned
  `INSTALL_FAILED_ABORTED: User rejected permissions`. The installed phone
  version remains 0.4.0/code 4. No uninstall, reset, security bypass or repeated
  install attempt was performed. Phase C on-phone runtime is therefore untested.
- Phase C source checkpoint is committed/pushed after this verification; final
  remote commit is reported in the handoff and visible in the repository log.

## Not run / limits

No Phase C phone installation/runtime, sustained FPS, low-end/battery/memory,
physical multitouch or airplane-mode
result is claimed. An abrupt process kill without pause/quit callbacks may lose
up to five seconds of new production. No offline production/catch-up. Full
machines remain full until Phase D makes stock removal available to the player.
General migration/process-death hardening remains Phase J.
