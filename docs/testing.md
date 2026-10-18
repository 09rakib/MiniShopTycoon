# Phase C manual checkpoint — automatic burger production

Install builds/MiniShopTycoon-phaseC.apk over the existing app without uninstalling
or clearing data. This update is v0.5.0/code 5. Previous grocery coins, inventory,
levels and upgrades are retained; schema 4 adds machine stock.

1. Walk to the burger press at the upper-left of the shop.
2. On a fresh machine, count should start at 0/10. Without tapping any action,
   it increases by one every two seconds. Moving away must not stop production.
3. See the actual burger stacks and COOKING label, then 10/10 and FULL after
   roughly 20 seconds from empty. Leave it full for another 30 seconds: it must
   remain exactly ten, without extra items or increasing wallet/XP/sales.
4. Open Menu and close it. The machine may continue producing; the worker stays
   stopped until a fresh joystick drag. Production pauses while backgrounded.
5. Wait at least five seconds after a new burger appears, fully close/reopen,
   and confirm its stock persists. Home/resume also flushes current production.
6. Check previous grocery data in Menu. Do not reset progress unless you want
   to erase that business and the new machine stock.
7. Continue movement checks: all directions, diagonal speed, release outside
   joystick, walls/equipment collision, camera bounds and Android Back.

There is no player pickup/carry button yet; that is Phase D. Therefore a full
machine stays full during this checkpoint. Removing stock and automatic restart
are verified through the authoritative inventory primitive in automated tests.
New customers, sales, cash pickup, machine-upgrade purchasing and employees are
not implemented early. The original grocery view remains available separately.

Production auto-saves in five-second batches, plus lifecycle/transaction flushes.
An abrupt process kill with no pause/quit callback can lose up to five seconds of
new burgers. There is no offline production/catch-up; each resume starts a new
full production interval. Do not downgrade after save-schema migration.

Desktop: play.cmd, joystick drag or WASD/arrows. Automated checks: test.cmd runs
128 economy + 34 world/input + 32 production checks (194 total). The production
suite uses real timers and also tests 10,000 full-machine attempts, cap/resume,
invalid data, migration and saving. Captures: tests/capture_production.gd.

Report phone model, exact steps, expected/actual behavior and any clipping or
input issue. No sustained FPS/battery/memory or airplane-mode result is claimed.
Approve this checkpoint before Phase D begins. Source is published to:
https://github.com/09rakib/MiniShopTycoon
