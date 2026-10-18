# Phase status — 19 October 2026

Current checkpoint: **Transformation Phase F — physical cash collection complete.**

- User authorized F after published E (06ac018). Original grocery Phases 0–3
  and burger world/production/carrying/customers remain preserved.
- One aggregated cash pickup at the existing cash fixture. Original cash stacks
  capped at three, exact amount displayed; empty plate after collection.
- Walk within 46 world units to automatically collect on a 150 ms proximity poll.
  Worker spawn and delivery point are outside this radius. Uses actual worker
  position, rejects non-finite/distant positions and blocked/menu/paused input.
- Atomic all-or-nothing pending-cash → wallet transaction, with wallet ceiling
  protection. Repeated pickup cannot pay again. New sales permit new collections.
- Wallet/pending cash saved together before signals/reward. File failure rolls
  back both fields and shows error; nearby retries wait three seconds.
- Floating +amount reward uses one reusable label/tween. Wallet/cash HUD and world
  stack refresh together. Cash HUD moved inside its panel for clear mobile layout.
- Burger sales/revenue/gross profit remain historical, collection does not change
  them. Derived collected total = revenue minus pending cash. Zero ingredient
  cost still means burger gross profit equals revenue. Old grocery ledger/XP
  remains separate; collected money is genuinely spendable wallet currency.
- No new persistent field needed: schema 6 already stores wallet and pending
  cash. Existing schemas 1–6 remain supported without resetting progress.
- Automated: 128 economy + 34 world + 32 production + 44 handling + 39 customer
  + 34 cash checks = **311 passed, zero failures**. Final logs clean.
- Cash tests include 10,000 duplicate pickups, 10,000 sale/collection cycles,
  radius boundaries, non-finite input, aggregation, wallet ceiling, actual timer,
  menu/suspension blocking, saved observer state, repeat/new sales, actual file
  failure/rollback, retry cooldown and pause/restart persistence.
- Real cash waiting/collected previews inspected at 480×900 and 360×640.

## Checkpoint handoff

v0.8.0/code 8 APK: builds/MiniShopTycoon-phaseF.apk. See test_report_phaseF.md
for actual export/signature/manifest verification and SHA256. No phone install
attempted after the previous explicit device refusal; provide APK for update.
Commit/push complete checkpoint, verify remote hash, then stop before G for
feedback. User requires automatic commit/push after each completed phase.

## Manual acceptance pending

Deliver burgers, let customers buy, observe pending cash with unchanged wallet.
Walk to CASH circle: exact aggregate moves into wallet, cash stack clears, +amount
floats above chef. Stay there: no repeat payout. New sales can be collected.
Restart preserves wallet and zero collected cash. Test joystick/multitouch,
Home/resume, Android Back, airplane mode and update migration on the phone.

## Limits / next phases

G machine upgrades/employees; H further machines/furniture; I polish; J complete
lifecycle hardening; K measured Android/release. No offline production/sales.
Visitors/worker position restart safely, held stock persists. Production writes
batch five seconds; abrupt termination can lose latest unsaved production.
No on-device performance or physical touch acceptance claimed this checkpoint.
