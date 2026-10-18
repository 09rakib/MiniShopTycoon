# Phase F manual checkpoint — collect cash into wallet

Update with builds/MiniShopTycoon-phaseF.apk (v0.8.0/code 8). Do not uninstall or
clear app data. Existing schema 6 already supports cash/wallet; prior progress,
carried/counter stock, accumulated cash and grocery upgrades are retained.

1. Collect up to two burgers at the press, carry to DELIVER and stock the counter.
2. Let customers buy. Each sale removes one counter burger and adds 20 to Cash
   waiting. Wallet stays unchanged while the chef is away from CASH.
3. Let several sales accumulate. One cash plate shows the combined amount and a
   small stack of notes. There should never be hundreds of separate cash objects.
4. Walk to the CASH ground circle beside the plate. No tap is required: within
   46 world units, collection occurs at the next 150 ms proximity poll. Pending
   cash becomes zero, wallet increases by the exact previous amount, +amount
   floats above the chef and the plate shows EMPTY.
5. Remain standing there or walk in/out repeatedly. No additional coins/reward
   until another customer makes a successful purchase. A new sale can then be
   collected automatically while you remain near the plate.
6. Try from the machine, delivery circle and across the shop: cash cannot be
   collected remotely. Carrying burgers does not prevent a valid cash pickup.
7. Open Menu/grocery panel while near cash; collection is blocked until returning
   to gameplay. App focus loss/background pauses collection and business.
8. Close/reopen after collection. Wallet retains the new amount and collected
   cash does not reappear. Historical sales/revenue do not increase on collection.
9. Use collected coins in the existing grocery inventory/upgrades menu to verify
   they are spendable. Burger machine upgrades/employees come in Phase G.
10. Test two-finger movement/action, Home/resume, Back, airplane mode and APK update
    preserving old progress. Do not clear data to test this update.

## Actual automated/visual checks

311 checks pass: 128 economy, 34 world, 32 production, 44 handling, 39 customers,
34 cash. test.cmd runs all six suites and rejects script/runtime errors in logs.
Cash checks cover exact aggregation, distance/NaN/infinity, empty/repeat pickup,
10,000 sale/collection cycles, wallet ceiling, actual proximity timer, blocked
controls, immediate durable observers, old schema 6 continuity, real file-open
failure, rollback, cooldown/retry and pause/restart. Cash waiting/collected layouts
rendered and inspected at 480×900 and 360×640.

No phone installation, physical touch, airplane-mode or measured performance test
was run this checkpoint. Prior installation was explicitly aborted on the phone.
See test_report_phaseF.md. Stop for feedback before Phase G.
