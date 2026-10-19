# Phase status — 19 October 2026

Current checkpoint: **Transformation Phase G — machine upgrades and stocker complete.**

- User authorized G after Phase F (594ff82). Original grocery Phases 0–3 and all
  burger production/carry/counter/customers/cash features remain preserved.
- Independent speed/capacity/price levels, five tiers each; current/next values
  and wallet costs shown in Menu → Burger machine & stocker. Machine +UP/MAX
  indicator. Speed starts a fresh real timer cycle; capacity preserves all stock;
  new price applies at the next successful checkout, never retroactively.
- One stocker hired for 300 wallet coins, distinct blue cap/uniform. Walks at
  135 units/sec along a configured clear aisle, carries at most two burgers,
  shares the player's actual proximity/bounded inventory transaction code.
- Full counter retains employee's carried items. Partial delivery retains the
  remainder and waits for space. No stock teleport, instant restocking or wages.
- Menus block player input while business continues. App pause/focus loss freezes
  production/customers/stocker. Characters ignore each other but collide with
  solid world fixtures, preserving player/customer/stocker paths.
- Single validated economy purchase method uses spendable wallet only; maximum
  tiers, insufficient funds, unknown purchases and expense ceiling reject safely.
  Purchases persist before effect signals/spawn; write failure restores wallet,
  tiers and hire state. Staff transfers persist immediately and mark dirty for
  retry if save fails.
- Schema 7 adds operations {hired, carried, spending} and independent capacity/
  price levels. Old schemas 1–6 migrate; prior machine level retains matching
  speed/capacity, price defaults to base, no employee. Old wallet/inventory/
  upgrades/cash remain intact. Employee's carried food survives relaunch.
- 128 economy + 34 world + 32 production + 44 handling + 39 customers + 34 cash
  + 69 operations = **380 checks passed, zero failures**; final logs clean.
- New checks cover upgrades/max/insufficient funds, no spending pending cash,
  single hire, save rollback/migration, shared staff/player contention, 10,000
  full-counter attempts, real timer, visible travel/partial delivery, saved staff
  carry and full timed production → stocker → sale → proximity cash loop.
- Workshop/default/hired and stocker-carry render captures inspected at 480×900
  and 360×640. APK v0.9.0/code 9 debug exported and signature/manifest verified.

## Checkpoint handoff

Artifact: builds/MiniShopTycoon-phaseG.apk; see test_report_phaseG.md for size,
hash and verification. Phase F was successfully installed/launched on the phone
in the prior turn. Phone now absent from ADB USB/wireless discovery, so G was not
installed or tested on-device. Update the existing app without uninstall/data reset.
Commit/push all tested source/assets/docs and verify remote hash. Stop before H
for feedback; user requires a GitHub push at the end of each completed phase.

## Manual acceptance pending

Menu → Burger machine & stocker. Try the 180-coin speed, 120-coin capacity,
140-coin price upgrades or hire the 300-coin stocker. Each must spend wallet once,
show new actual values and persist. Stocker physically carries at most two and
waits with leftovers at a full counter. Collect customer cash yourself as before.
Restart while employee carries food: hired worker and exact carried amount remain.
Test small-screen touch, Back/menu, Home/resume and airplane mode on phone.

## Limits / next phases

One useful stocker only; cashier/general assistant, additional food machines,
furniture and content expansion remain later scope. No staff wages or dismissal
this checkpoint. Staff uses fixed valid aisle; future placement must preserve it.
No offline work/income. Worker/customer/staff positions restart safely; inventories
persist. Production-only writes batch five seconds; sudden kill can lose latest
unsaved production. No measured Android FPS/memory/heat or low-end claims.
H additional machines/furniture; I polish; J full lifecycle; K release/performance.
