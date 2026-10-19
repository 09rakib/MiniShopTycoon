# Phase G verification — 19 October 2026

Engine: Godot 4.7.2 stable on Windows. Render: Compatibility OpenGL on NVIDIA GTX
1650. Automated timings are desktop verification, not Android FPS measurements.

## Changed implementation

- machines.json / ProductionState: independent speed/capacity/price tiers and costs.
- operations.json / ShopOperations: single hired stocker, held food and spending.
- ShopEconomy / Game: wallet-funded validation, caps, durable purchase/rollback,
  shared employee inventory transfer and migration to schema 7.
- BurgerHandling: same bounded transfer function accepts player or employee carry.
- ProductionController: actual fresh cycle on speed purchase, full-capacity resume.
- BurgerSales: current upgraded price read only on successful checkout.
- StockerController / WorkerCharacter: visible uniform/stack, real physics route,
  bounded decision timer, partial/full-counter waiting, pause and safe restart.
- BurgerOperationsPanel / playable_shop: workshop current/next/cost/hire UI and Back.
- Machine +UP/MAX indication, test launcher, export config/version and docs.

## Tests actually run

Economy 128/128; world 34/34; production 32/32; handling 44/44; customers 39/39;
cash 34/34; operations **69/69**. **380 passed, zero failures**. Final logs have
no script/runtime errors, resource leaks or warnings. No failed new test remains.

New cases include independent first and maximum tiers, exact costs, unchanged
stock on speed/capacity upgrades, future price without historical repricing,
insufficient wallet/pending-cash exclusion, duplicate hire/unknown purchase,
expense ceiling, schema 7 roundtrip, prior coupled-level migration, malformed
level/employee data without partial wallet load and required new-schema fields.

Shared inventory tests cover unhired/far employee rejection, player/staffer
competing for last three burgers, full/partial delivery leftovers and 10,000
rejected full-counter attempts without item duplication/loss.

Real scene tests cover full machine resumed by capacity purchase, actual 1.7-second
production, failed save rollback for upgrade/hire, real UI purchase/hire, durable
wallet/tier/employee state, actual pickup and visible travel, employee in-transit
save, pause, partial/full counter, upgraded sale, remaining held food delivered
once space frees, relaunch/restored held stock and reset.

A further 10.5-second engine-timed loop uses real production → moving stocker →
queued customer purchase → player's proximity cash pickup, verifying exact wallet
plus pending proceeds. No injected food/sale in that full-loop check.

Rendered and inspected workshop at 480×900 and 360×640, plus hired workshop and
blue-capped stocker carrying two. Default panel shows actual 180/120/140 upgrade
costs and 300 hire, with clear current/next values and Back/Menu controls.

## APK actually verified

- builds/MiniShopTycoon-phaseG.apk: **57,725,712 bytes**.
- SHA256: B2A9C435266BC1E97222D65FB271578D797D51FBACB8F528A300BE3A531CB764
- Debug export succeeded. apksigner v2/v3 signatures verified.
- aapt: com.minishoptycoon.offlinegame, v0.9.0/code 9, min SDK 24,
  target/compile SDK 36, ARMv7/ARM64, no requested permissions. Portrait retained.
- SDK build tools 36.0.0 and Android Studio JBR 21.

## Not run / limitations

Phase F was installed and launched successfully on vivo V2405A in the previous
turn. For G, ADB USB and wireless discovery returned no phone; no install attempted.
Therefore G on-device migration/touch, airplane mode, lifecycle and measured
FPS/memory/heat/low-end/release acceptance remain pending. APK is available for
update over the existing app without uninstalling or clearing progress.

One stocker only, no wages/dismissal/cashier. No offline work/earnings. Fixed aisle
must remain unobstructed by future furniture. See known_issues.md and testing.md.
Source/assets/tests/docs are published; APK/cache/local saves/tooling/keys remain
ignored. Stop before H for feedback, then continue automatic phase checkpoint pushes.
