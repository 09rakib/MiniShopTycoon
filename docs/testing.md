# Phase E manual checkpoint — customers and sales

Update with builds/MiniShopTycoon-phaseE.apk (v0.7.0/code 7). Do not uninstall or
clear app data. Existing grocery/machine/carried/counter progress migrates to
schema 6; new sales/cash default to zero. Avoid downgrading after migration.

1. Move to COLLECT; take up to two burgers, carry to DELIVER, stock the counter.
2. Customers arrive every five seconds, at most four active including departures.
   They walk in the right lane and form a spaced queue. The head approaches the
   right side of the counter when food exists, buys one, then leaves via the
   outer lane. Keep delivering to see continuous turnover.
3. Each purchase deducts one counter burger, increments Sales by one and Cash
   waiting by 20. Wallet must remain unchanged: collection is Phase F.
4. Leave the counter empty. Customers wait, earn nothing, and leave after their
   35-second queue patience. No burgers are taken from the press or worker.
5. Deliver a single burger with several customers waiting. Exactly one buys it;
   the rest must wait. Repeated Collect/Deliver taps must not duplicate food.
6. Close and reopen after a sale. Pending cash, sold count, machine/counter/held
   quantities and old wallet/upgrades persist. Visitors start fresh, no sale is
   replayed and no offline income is granted.
7. Open/close Menu and grocery panels. Player remains blocked in overlays; burger
   business continues while menus are open, pauses on app focus loss/background.
8. Test two-finger joystick/action use, Home/resume, Android Back and airplane
   mode. Watch for blocked customers, overlapping queue or unintended wallet gains.

## Actual automated/visual checks

277 checks pass: 128 economy, 34 world, 32 production, 44 handling, 39 customers.
Run test.cmd for all suites (it also rejects script/runtime errors in logs).
Customer tests cover duplicate/empty/unknown transactions, last-item contention,
active bounds, 10,000 full inventory-to-cash cycles, save migration/validation,
real physics queue/checkout/departure, timeout/blocked cleanup, pause and collision.
Customer queue/sale images inspected at 480×900 and 360×640.
See test_report_phaseE.md for APK verification and limits.

No phone installation, touch acceptance, airplane-mode or measured performance
result is claimed for this checkpoint. Prior phone install was explicitly aborted;
provide this APK for manual update and wait for feedback before Phase F.
