# Changelog

## 0.13.0 — Phase K candidate checkpoint — 23 October 2026

- Cached chef and fixture drawing styles instead of allocating resources every redraw.
- Added reproducible desktop idle/busy/menu benchmark and ten bounded-resource tests;
  all 595 checks pass. Desktop observations are not Android performance measurements.
- Added distinct debug, unsigned release APK and unsigned Gradle AAB presets,
  build wrapper and artifact/ARM64 ELF/content audit.
- Corrected Android Game category; pinned AAB SDK 24/36 and verified APK template levels.
- Prepared signing, privacy/store text drafts and current primary policy references.
- User explicitly deferred phone measurements and chose unsigned candidates; device,
  signing and store acceptance remain pending. No publication or new signing key.

## 0.12.0 — Transformation Phase J — 23 October 2026

- Audited schema 1–8 migrations, recovery files, reset, progression and lifecycle.
- Block writes when a recovery candidate needs a newer game; clear stale blocked
  state/messages after a successful reload.
- Prepare reset replacement first, archive copies, then commit primary and reset
  live state. Failed preparation/archive leaves original progress intact.
- Roll back failed player/staffer food transfers, customer stock/cash/ticket sales
  and grocery buy/sell/upgrade mutations; recovered storage can retry safely.
- Added 76 checks including 20 disk-backed journeys with reload while carrying;
  all 585 checks pass, clean logs. Schema remains 8, no offline income.
- Verified debug APK v0.12.0/code 13. User deferred physical phone checks; no
  Phase K performance/release claim. See docs/test_report_phaseJ.md.

## 0.11.0 — Transformation Phase I — 22 October 2026

- Added pooled quantity/ring feedback, chef/stocker handling poses, machine steam
  and light, customer patience meter and paid-customer bag/thanks.
- Added eight original short offline sounds, four bounded voices, repeat throttling
  and persistent Menu sound toggle. Focus loss clears transient sound/animation.
- Added short menu/sheet entrance fades with immediate input blocking/close.
- Preserved floating joystick, compact HUD, automatic transfers and schema 8 saves.
- 509 headless checks plus 50 desktop polish checks pass with clean logs.
- Debug APK v0.11.0/code 12; see docs/test_report_phaseI.md. Stop before Phase J.

## 0.10.1 — User-requested touch/control update — 22 October 2026

- Replaced fixed visible joystick with low-opacity floating touch control: hidden
  when idle, starts at touch location, releases/cancels safely, protects menu UI.
- Reorganized top wallet/level/carry/counter/cash into a compact two-line HUD.
- Removed Collect/Deliver buttons and action-key requirement; proximity now auto
  picks burger/fries, serves counter food and collects cash without tapping.
- Retained capacity/distance/conservation/save rules, schema 8 and existing progress.
- Added 29 real input/timer checks and adapted interaction regressions; 459 pass.
- Exported v0.10.1/code 11 touch-update APK; see test_report_touch.md for device status.

## 0.10.0 — Transformation Phase H — 22 October 2026

- Added unlockable fries press using shared production/handling/controller code.
- Added separate fries carry/counter stock, visible cups, contextual pickup and
  customer purchases at correct product prices; alternate stocked products.
- Added wallet-funded table/two-chair bundle, valid solid placement and two seats.
- Added expansion menu, duplicate/fund guards, durable purchase and failure rollback.
- Added schema 8 with old progress migration and persistent owned objects/fries.
- Added 50 expansion checks including 10,000 complete fries-to-sale cycles; all
  430 checks pass. Rendered normal/compact layouts, prepared code 10 Android APK.
- Dining and fries staff/upgrades remain later scope; no phone install claimed.

## 0.9.0 — Transformation Phase G — 19 October 2026

- Added independent speed, capacity and selling-price upgrades with five tiers.
- Added wallet-funded purchase validation, immediate save and failure rollback.
- Added compact Burger Workshop with current/next stats, costs and single hire.
- Added one visible stocker walking a fixed aisle, carrying two, sharing bounded
  player transfer rules, and retaining full-counter leftovers/in-transit food.
- Added schema 7 and prior coupled-level migration; preserves previous progress.
- Updated character layers so staff/customers cannot block the player.
- Added 69 operations checks including a full real-time shop loop; all 380 checks
  pass. New v0.9.0/code 9 APK verified; phone unavailable for this update.

## 0.8.0 — Transformation Phase F — 19 October 2026

- Added automatic proximity cash collection at the existing cash station.
- Added atomic pending-cash/wallet transfer, ceiling protection, durable save
  before reward, file-failure rollback and bounded retry cooldown.
- Added capped original cash stacks, exact amount/empty state, ground marker,
  reusable floating +amount effect and cash indicator inside the HUD panel.
- Preserved save schema 6, old progress and separate burger/grocery ledgers.
- Added 34 cash checks; all 311 checks pass. Rendered normal/compact cash states
  and prepared v0.8.0/code 8 APK. No phone install attempted.

## 0.7.0 — Transformation Phase E — 19 October 2026

- Added bounded physical customers, right-side queue, checkout, patience and exit.
- Added one-time authoritative counter purchases; failed purchases create no money.
- Added separate persistent pending cash, burger sold count and revenue; wallet
  remains unchanged until Phase F. Schema 6 preserves schemas 1–5.
- Added 39 customer checks including 10,000 complete production-to-sale cycles;
  all 277 checks pass. Rendered normal/compact layouts and verified debug APK.
- No phone installation or physical cash collection in this checkpoint.

## 0.6.0 — Transformation Phase D — 19 October 2026

- Added proximity-checked machine pickup, two-burger carrying and counter delivery.
- Added atomic bounded transfers; partial/full counters retain carried leftovers.
- Added original carried/counter burger stacks, ground markers, carry/counter HUD,
  contextual Collect/Deliver controls, feedback and desktop E interaction.
- Actual worker position is rechecked at action time; menu/background block actions.
- Added save schema 5 for carried/counter stock with compatible prior migrations
  and immediate persistence after successful transfers.
- Added 44 handling checks, including 10,000 repeated invalid transfers and actual
  UI/save/production integration. Previous 194 checks retained.
- Prepared separate v0.6.0/code 6 Android checkpoint; no customers or cash yet.

## 0.5.0 — Transformation Phase C — 19 October 2026

- Uploaded the complete prior source checkpoint to the user's GitHub repository
  before starting Phase C. Future checkpoints are committed/pushed after testing.
- Added automatic 2-second burger production with a capacity of ten.
- Added actual burger-stack visuals, live stock count and COOKING/FULL status.
- Production stops its timer while full/inactive and resumes on bounded removal.
- Added reusable machine state/configuration and future upgrade tiers; pickup,
  selling and machine-upgrade purchases are not implemented early.
- Added save schema 4 migration and five-second batched production saving with
  lifecycle flush. Existing wallet, inventory, levels and upgrades are preserved.
- Added 32 production checks including real timers, cap/resume, corruption and
  save migration; retained all prior 162 checks.

## 0.4.0 — Transformation Phase B — 18 October 2026

- Audited the existing Phase 3 project and backed up its source before changes.
- Added a large original raised 2D burger-shop world and a controllable chef.
- Added mobile joystick, normalized diagonal movement, facing and walking poses.
- Added solid equipment/walls, navigable corridors and a bounded smooth camera.
- Added compact HUD and paused management overlay; old grocery game, inventory,
  upgrades and saves remain available. Schema 3 is retained without conversion.
- Added 34 world/input/collision/camera/integration checks; original 128 pass.
- Installed/launched Phase B on vivo V2405A and inspected the actual world screen.
- Added 480×900, 360×640 and 480×1040 rendered world captures.
- Burger production, carrying, new customer sales and cash remain later phases.

## 0.3.0 — Phase 3 checkpoint — 18 October 2026

- Added six configurable XP levels with product unlocks and level-up feedback.
- Added Pantry/Chilled/Daily picks upgrades with three steps each, increasing
  costs, level requirements and +10 capacity per product per step.
- Added growth screen, visible next objective and six completion milestones.
- Added upgrade spending separately from inventory costs and gross profit.
- Added schema 3 migration preserving prior stock, cash and product access.
- Added empty-shop restocking reserve to avoid upgrade-induced bankruptcy.
- Improved dialog readability and 52-pixel-high built-in dialog buttons.
- Expanded coverage to 128 passing checks, including a complete 170-sale run.
- Built and verified version 0.3.0/code 3 debug APK with unchanged app identity,
  matching signing certificate and no requested permissions. Phone QA pending.

## 0.2.0 — Phase 2 checkpoint — 18 October 2026

- Expanded the catalog to Bread, Milk, Apples, Eggs, Bananas, Rice, Soft drinks,
  Snacks, Soap and Bottled water; added ten original SVG product icons.
- Added Stockroom inventory screen with costs, prices, margins, capacity and
  single-unit/batch orders. Kept the original shop quick-buy controls.
- Added lifetime stock-spending and unsold stock value separately from revenue
  and gross profit, persisted in save schema 2.
- Added schema 1 migration preserving original stock and cash without reset.
- Added catalog validation, overflow-safe quantity checks and saveable limits.
- Mapped all customer routes/products to three visible shelf groups.
- Expanded automated coverage from 33 to 88 checks and captured inventory layouts.
- Increased Android version code to 2 while retaining package and debug key.

## 0.1.0 — Phase 1 checkpoint — 18 October 2026

- Created a Godot 4 portrait project with offline-only gameplay.
- Added main menu, cozy vector shop and three configurable products.
- Added wholesale stock orders, shelf capacity and insufficient-funds feedback.
- Added capped reusable customers, walking, one automatic checkout and departure.
- Added coin, revenue, gross-profit and customer counters.
- Added confirmed restart, Android Back navigation and pause/resume hooks.
- Added versioned local persistence with backup, recovery and corruption protection.
- Added portable editor/play/test launchers and an Android debug export preset.
- Added 33 automated checks and rendered UI captures at two window sizes.
- Documented setup, architecture, roadmap, limitations and user testing checkpoint.
- Built and verified a signed Android debug APK (Android 7+, ARMv7/ARM64,
  portrait, no requested permissions); phone installation remains untested.
