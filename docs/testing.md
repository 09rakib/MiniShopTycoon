# Phase H manual checkpoint — fries machine and furniture

Install builds/MiniShopTycoon-phaseH.apk (v0.10.0/code 10) as an update. Do not
uninstall/clear data or downgrade after schema 8 migration. Existing coins,
grocery upgrades, burger tiers/stock, held food, staff and pending cash remain.

1. Collect wallet cash, then open Menu → New machines & furniture. Pending cash
   is not spendable. Unlock fries costs 400; table + two chairs costs 180. Owned
   buttons disable. Repeated taps must not double-charge or duplicate fixtures.
2. Unlocked fries press appears in the left expansion bay. It produces one fries
   serving every three seconds, stops at eight, resumes after collection. Before
   unlock it must not produce anything or obstruct the bay.
3. Walk to FRIES, tap Collect fries 2 when at least two exist. The machine loses
   exactly two and visible cups appear in the chef's hands. Pickup is local only.
4. Player carries at most two items and one product type per trip. Carrying a
   burger blocks fries pickup and vice versa, retaining held food. Deliver first.
5. Walk to DELIVER. Fries move to four dedicated trays; burger counter still has
   its separate eight slots. HUD/world show B and F counts. Full or partial fries
   shelf retains leftovers in the chef's hands, never deletes/retypes food.
6. Customers buy food at the counter, never the machines. They alternate when
   both foods are stocked; otherwise buy what exists. One visit buys once total.
   Base burgers pay 20 (or upgraded price), fries 16. Cash waits until collected.
7. Walk to CASH: combined proceeds enter wallet exactly once. Burger upgrades and
   stocker remain intact; stocker still carries burgers only, player handles fries.
8. Buy the table set. One original table/two chairs appears in the lower-left bay,
   seating capacity becomes 2. It is solid but leaves worker/customer/entrance
   paths open. This checkpoint has no dining or seating revenue bonus yet.
9. Restart while carrying fries and with both counter products stocked. Owned
   machine/furniture, food, cash/wallet and old progress persist. Saved objects
   must appear exactly once on relaunch, never duplicate on menu refresh.
10. Test small-screen joystick/actions, Home/resume, Back/menu and airplane mode.
    Both machines pause in background; no offline production or income.

## Actual verification

430 checks pass: 128 economy, 34 world, 32 production, 44 handling, 39 customers,
34 cash, 69 operations, 50 expansion. test.cmd runs all eight suites and flags
script/runtime errors. New cases cover purchase funds/repeats/rollback, locked
production, shared two-item handling, full/partial shelf retention, alternating
payments and last-item claim, schema 7 migration/8 validation, actual production,
UI pickup/delivery, customer fries purchase/cash collection, placement margins,
solid furniture, relaunch/reset and 10,000 complete fries-to-sale cycles.
Five real render previews inspected at 480×900 and 360×640.

No Phase H phone installation, physical touch/airplane-mode/device migration or
measured performance run is claimed. APK signature/manifest are verified; see
test_report_phaseH.md. Stop for feedback before Phase I.
