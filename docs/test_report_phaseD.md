# Phase D — carrying and counter delivery — 19 October 2026

## Implemented

Continued from committed Phase C (`eb2c606`) after the user requested continuation.
Added the real machine → carried → counter flow, proximity controls, two-item
carry limit, eight-item counter, original carried/counter visuals and immediate
transfer saves. No Phase E/F sales or money pickup has been implemented.

## Actual automated checks

- Existing economy suite: 128 passed. World/input: 34 passed. Production: 32 passed.
- New handling suite: **44 passed**, zero failures. **238 total checks**.
- Machine stock moves by the exact bounded quantity; full hands/empty machine/
  unknown action/invalid position/far interactions leave inventory intact.
- Four two-item trips fill the counter. Full-counter delivery preserves the
  carried count; partial delivery fills one space and retains one burger.
- 10,000 attempted invalid transfers preserve the total burger count.
- Observers on machine stock_changed see a complete two-sided transfer.
- Invalid/fractional/overflow/mistyped carrying/counter counts reject without
  mutation; malformed handling state cannot partially apply coins or machine.
- Schema 4 → 5 migration preserves wallet, grocery stock, upgrades and machine
  burgers; current schema saves machine/carried/counter as one record.
- Actual contextual button signals update HUD, carried art and the counter;
  stale prompts cannot pick up from afar. Menus hide/block interactions.
- Pickup/delivery/partial leftovers/pause save correctly. Reset clears all new
  state and art. Physical pickup from a full machine restarts its production timer.
- Pickup/delivery never creates wallet coins, revenue, customers or XP.

## Rendering and files

Rendered and inspected pickup, held-stack, delivery, stocked counter and partial
full-counter states at 480×900 plus a 360×640 compact capture. Disabled actions
use readable colors; contextual machine count stays visible even if the worker
overlaps the machine's world label. No horizontal clipping observed.

Core additions: data/burger_handling.json and scripts/burger_handling.gd.
Updated Game/economy schema, world HUD/fixtures/worker, ground markers, export
version/launcher, tests, documentation and source checkpoint status.

One test-only signal observer originally captured its own RefCounted source;
explicitly disconnected it after its assertion. Final handling run has no
script/runtime errors or leaked-resource warnings.

## Android / publication

- Final export succeeded: `builds/MiniShopTycoon-phaseD.apk`, v0.6.0/code 6,
  **57,695,614 bytes**. Package com.minishoptycoon.offlinegame.
- Verified APK v2/v3 signature, min SDK 24, target 36, ARMv7/ARM64, portrait,
  backup disabled and no requested Android permissions.
- SHA-256: `8EC9935AE4649906912EEF42DA65C38B501201DD6C8440073C0F91F4441B29CD`.
- Source checkpoint is committed/pushed after verification; remote hash is checked
  and reported in the final handoff. Generated APKs and local saves stay excluded.
No phone installation is attempted automatically: the previous update was
explicitly aborted by Android with User rejected permissions. A fresh user
installation/request is needed for further on-device checking.

## Limits and tests not run

Physical device touch/second-finger action, save migration and close/reopen with
carried burgers, airplane mode, force stop and sustained FPS/memory/battery checks.
No device-performance or phone-installation result is claimed for this phase.
Customers/counter draining and cash collection are Phases E/F; a full counter
therefore stays full in D. Machine-production batching retains the prior maximum
five-second unflushed-production window on unnotified process death; completed
pickup/delivery flush immediately. No offline production is added.

Manual test steps: docs/testing.md. Stop here before Phase E.
