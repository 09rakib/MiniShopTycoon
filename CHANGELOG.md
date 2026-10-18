# Changelog

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
