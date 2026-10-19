# Phase G manual checkpoint — upgrades and a working stocker

Update builds/MiniShopTycoon-phaseG.apk (v0.9.0/code 9) over the installed game.
Do not uninstall/clear data or downgrade after schema 7 migration. Prior coins,
grocery upgrades/inventory, machine/counter/held stock, revenue and cash migrate.

1. Open Menu → Burger machine & stocker. The compact workshop shows wallet,
   current/next stats and exact costs. Back to shop resumes the same world.
   Android Back first closes workshop, then menu. World business keeps running
   while menus are open; player movement/cash pickup is blocked in menus.
2. Speed 1 → 2 costs 180 coins, changes 2.0s → 1.7s and leaves capacity at 10.
   A fresh cycle starts at the new speed; buying does not create free burgers.
3. Capacity 1 → 2 costs 120 coins, changes 10 → 12 without losing existing food.
   A full machine resumes because the new capacity has room. Speed stays the same.
4. Price 1 → 2 costs 140 coins, changes 20 → 25. Subsequent successful customer
   purchases pay 25; existing pending cash/revenue does not change retroactively.
5. Only wallet coins can buy upgrades. Pending cash cannot be spent; walk to CASH
   and collect it first. Unaffordable/maxed buttons disable; repeated hiring must
   never create multiple stockers or charge after the first successful purchase.
6. Hire stocker for 300 coins. A blue-capped worker appears at the press, picks up
   at most two and visibly walks through the middle aisle to DELIVER. The counter
   changes only at delivery, not immediately when pickup occurs.
7. Help the stocker by collecting/delivering yourself. Shared stock must not go
   negative or duplicate. Full counter: employee waits and keeps the carried food.
   Partial space: only fitting burgers move; remainder stays held until a sale.
8. Continue selling and collecting cash. Employee stocks the counter but never
   creates products/money or collects cash for you. No staff wages in this version.
9. Close/reopen while stocker carries food. Hired status, exact held items, machine
   tiers, business expenses, wallet and cash persist. Employee respawns safely and
   resumes delivery. Do not reset progress just to test upgrades.
10. Test joystick/menu/two-finger controls, Home/resume, Back and airplane mode.
    Confirm staff/production/customer activity pauses in background, with no
    offline catch-up. Character positions are transient; inventories are durable.

## Actual automated and visual verification

380 checks pass: 128 economy, 34 world, 32 production, 44 handling, 39 customers,
34 cash, 69 operations. test.cmd runs all seven suites and rejects runtime errors.
The new suite tests all upgrade tiers/caps/costs, fund checks, price timing, schema
migration and malformed records, single hire/save failure rollback, player/staff
stock contention, 10,000 rejected full-counter transfers, actual machine timer,
real worker travel/partial delivery, saved in-transit items, pause/reset and a
10.5-second full production → stocker → customer → cash collection loop.
Workshop/default/hired and employee carry images rendered and inspected at
480×900 and 360×640. See test_report_phaseG.md for exact build verification.

Phase F was installed/launched in the previous turn. G phone installation was not
run: ADB USB and wireless discovery found no phone at this checkpoint. No G device
migration/touch/airplane/performance acceptance claimed. Stop before Phase H.
