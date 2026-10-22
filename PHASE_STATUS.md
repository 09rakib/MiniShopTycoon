# Phase status — 22 October 2026

Current checkpoint: **Transformation Phase H — fries machine and furniture complete.**

- User approved H after published G (dff71d8). Existing grocery Phases 0–3 and
  burger world/production/carry/customers/cash/upgrades/stocker remain intact.
- Added unlockable fries press: 400 wallet coins, 3-second production, storage 8,
  selling price 16 and four dedicated fries trays at the existing serving counter.
- ProductionState and ProductionController are reused by both machines, not
  copied scripts. Locked machine has no world fixture, stock or active timer.
- Player collects at FRIES and delivers at DELIVER. Maximum two items, one product
  type per trip; existing carried food is retained when another type is rejected.
  Burger and fries inventories stay separate. Partial/full shelves preserve held
  food. Shared transfer code enforces source stock, capacity and proximity.
- Customers buy available counter food; alternate when both shelves have stock.
  One live visit buys exactly once across all products. Payment uses the selected
  product price and enters the same pending cash ledger, collected as before.
- 180-coin table + two chairs bundle adds seating capacity 2 in a fixed valid bay.
  Purchased geometry is solid and deterministic. Dining behavior is later scope;
  no unimplemented seating bonus or extra cash is granted. Stocker handles burgers.
- Menu → New machines & furniture shows costs, owned states and seating. Purchase
  funds use wallet only, reject repeats, persist before object creation and roll
  back on storage failure. Original visuals show fries machine/cups/carried cups,
  counter product counts, furniture and collection marker.
- Schema 8 adds expansion {unlocked, furniture, spending, production, handling}.
  Schemas 1–7 retain previous progress, initialize expansions locked/unowned.
  Validate all fields before applying any; reject locked stock, bad capacities,
  invalid flags and saved mixed product carrying. Sale rotation also persists.
- 128 economy + 34 world + 32 production + 44 handling + 39 customer + 34 cash
  + 69 operations + 50 expansion = **430 checks passed, zero failures**.
- Tests include 10,000 rejected full-fries-counter attempts, 10,000 complete fries
  production/carry/delivery/sale cycles, payment/rotation/last-stock contention,
  migration, failure rollback, actual timers/buttons/customer/cash, placement
  margins, furniture collision, relaunch and non-duplicating world recreation.
- Rendered/inspected expansion panel, carried fries and expanded shop at 480×900
  and 360×640. See test_report_phaseH.md for actual APK verification and hash.

## Checkpoint handoff

APK: builds/MiniShopTycoon-phaseH.apk, v0.10.0/code 10. Update the existing app
without uninstalling/clearing data. G and H were not installed on the phone in
this work; F was installed/launched earlier. Device touch/migration/performance
acceptance remains pending. Commit/push this completed phase, verify remote hash,
then stop before I for feedback. Keep the user-required automatic phase pushes.

## Manual acceptance pending

Collect cash → Menu → New machines & furniture → unlock fries/table set.
At FRIES collect two, walk to DELIVER, observe correct fries shelf. Let customers
buy both foods at their prices, then collect exact combined cash. Full fries
shelf keeps leftovers; another product pickup cannot overwrite held food.
Restart retains purchased objects, inventories, wallet and old upgrades/staffer.
Verify customer, player and stocker routes, phone controls, Back/Home and airplane
mode. Table creates two seats; customers do not dine in this checkpoint.

## Limits / next phases

Fries has one configured tier; burger upgrades remain available. Stocker transports
burgers only. Furniture is a fixed bundle, no drag/dining yet. Character positions
restart safely; food persists. No offline production/work/sales. Production-only
saves batch five seconds; sudden kill can lose newest unsaved production.
I visuals/audio/UI polish; J comprehensive save/lifecycle verification; K measured
Android performance/release. Do not begin I without user continuation/approval.
