# Phase H verification — 22 October 2026

Engine: Godot 4.7.2 stable on Windows. Rendered with Compatibility OpenGL on
NVIDIA GTX 1650. Desktop checks are not Android performance measurements.

## Implementation / changed files

- machines.json adds fries_press using existing ProductionState and configurable
  tiers. ProductionController accepts an injected state; both use the same cycle
  logic, with shared primary autosave and separate one-shot production timers.
- expansion.json / ShopExpansion own unlock/furniture/spending and fries state.
- BurgerHandling supports another source/counter limit. Economy routes real
  player positions through shared transfer rules; one food type/two items per trip.
- BurgerSales / customer controller sell one available food item with the correct
  source price, alternate when both stocked, and prevent cross-product replay.
- Economy/Game add wallet-only purchases, immediate save/rollback, schema 8 and
  pre-H migration. All food sales share the pending-cash/collection transaction.
- World/fixture/worker/floor add deterministic solid owned objects, original fries
  machine/cups/carry art, counter food labels, table/two chairs and ground marker.
- ShopExpansionPanel / playable_shop add ownership/cost/seating UI and contextual
  fries pickup. Existing burger workshop/stocker remains accessible and intact.
- Test launcher/export/version, phase/architecture/manual/known-issues docs updated.

## Actual automated results

Economy 128/128; world 34/34; production 32/32; handling 44/44; customers 39/39;
cash 34/34; operations 69/69; expansion **50/50**. **430 checks passed, zero
failures.** Final logs contain no script/runtime errors or resource-leak warnings.

New cases include locked production/seating, initial fries configuration,
wallet-only purchase (pending cash excluded), exact cost/expense, duplicate and
unknown purchase, eight-item machine bound, remote pickup rejection, shared player
hands, separate shelf transfer/full/partial retention, product price/rotation,
visit replay/last-item contention, schema 8 state/7 migration, malformed records
without partial wallet apply, impossible locked/mixed inventory and overflow.

10,000 full-fries-counter attempts conserve food. 10,000 complete single-serving
fries production/pickup/delivery/sale cycles yield exactly 160,000 pending coins,
10,000 sales, zero remaining food and unchanged 100 wallet after unlock cost.

Real scene tests verify no free/unowned fixture or timer, failed machine/furniture
save rollback, actual purchase buttons, exact one-time owned object creation,
immediate durable expense/ownership, actual three-second production, contextual
pickup/carry art, delivery/HUD labels, real customer buying fries and exact
16-coin physical cash collection. Fixed placements pass radius-margin checks for
employee aisle, customer lane and entrance. Real movement collides with furniture.
Relaunch/refresh recreates exactly one set; reset removes it and stops production.

## Visual verification

Five real rendered previews: expansion menu at 480×900/360×640, carried fries,
expanded shop at 480×900/360×640. All inspected. Table/chairs stay in their bay,
fries cup visuals are distinct, HUD includes B/F counter stock. Fries fixed tier
no longer displays an ambiguous MAX production label. Context labels show both
shelves when fries unlocked. Corrected capture to refresh location after moving.

## APK actually verified

- builds/MiniShopTycoon-phaseH.apk: **57,738,416 bytes**.
- SHA256: D1993879BC4E9E6E2AD7E5A8AF8717A96799FF9B568C0166723E4062BB7B9061
- Debug export succeeded; apksigner verifies v2/v3 signatures.
- aapt: com.minishoptycoon.offlinegame, v0.10.0/code 10, minimum SDK 24,
  target/compile SDK 36, ARMv7/ARM64, portrait and backup disabled.
- No requested permissions in aapt permissions output.
- Android SDK build-tools 36.0.0, Android Studio JBR 21.

## Not run / material limits

No Phase H phone install or physical touch, device migration/lifecycle,
airplane-mode, FPS/memory/heat/low-end/release acceptance run. Update the existing
app without uninstall/data clearing, following testing.md. Phase F had been
installed/launched earlier; that is not claimed as H verification.

Fries has one tier and manual player transport. Stocker handles burgers. Furniture
adds two owned seats without dining or a revenue bonus yet. No offline production
or earnings. Sources/assets/tests/docs are published; APK/cache/saves/keys remain
local and ignored. Stop before I until user continuation/feedback.
