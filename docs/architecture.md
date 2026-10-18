# Architecture

## Current entry: transformation Phase B

`scenes/playable_shop.tscn` is now the entry; the previous `scenes/main.tscn`
remains unchanged apart from an embedded-mode Back-event guard. The new
`scripts/world/` modules are additive:

- `playable_shop.gd`: compact wallet/level HUD, input gating and management sheet.
  Existing grocery panels open as embedded content and return without reloading
  or repositioning the worker. The old customer simulation runs only when the
  player explicitly opens the previous grocery shop; closing it disables it.
- `shop_world.gd` + `data/world_layout.json`: deterministic fixtures and collision
  bodies; four walls, machine, counter, empty cash tray and a plant. Expansion
  bay/queue markings are decorative floor areas and do not block movement.
- `worker_character.gd`: one circular CharacterBody2D, normalized input, facing,
  idle/walk poses, immediate stop. Keyboard is desktop-only; joystick is primary.
- `virtual_joystick.gd` (`ShopJoystick`): one captured touch, clamped analog input,
  unrelated-touch rejection, cancellation/release and pause resets. Mouse drag
  also supports desktop testing. Touch-to-mouse emulation is disabled.
- `shop_camera.gd`: smooth controlled following with viewport-aware bounds and
  zoom adjustment to avoid seeing beyond the decorated room.
- `shop_floor.gd` / `shop_fixture.gd`: original raised 2D art and static footprints;
  depth sorting places the worker in front of or behind equipment as appropriate.

No new saved gameplay field or currency source exists in Phase B. Movement does
not write saves; relaunch starts the worker at a valid spawn while all schema-3
progress stays intact. No production, burger transfer, new sales, cash collection,
machine upgrades, employees or furniture purchase is implemented early.
Those systems are scoped in the new A–K roadmap and the Phase A audit.
See `transformation_audit.md` for reuse decisions and future transaction flow.

## Preserved grocery systems

- `data/catalog.json`: configurable starting balance, batch size, customer
  cadence/duration/limit, and ten product definitions. Each product has a stable
  ID, cost, selling price, capacity, category, color, shelf and unlock-level
  requirements. Fresh saves unlock by level; migrated saves retain prior access.
- `ProductCatalog`: validates product IDs, integer prices/capacities, profitable
  margins, timing and visible shelf mappings. `ProductIcons` caches ten original
  SVG textures shared by shop and inventory.
- `ShopEconomy`: pure synchronous transactions and snapshot validation.
  Invalid transactions return before changing state. Integer coins and stock.
- `ShopProgression`: configurable XP thresholds, six levels, milestones and next
  objective. XP/level derive from saved completed customer count.
- `ShelfUpgrades`: three configurable shelf groups, increasing step costs, shop
  level requirements and capacity bonuses. Economy applies the valid transaction.
- `UpgradesScreen`: growth cards and goal progress. Upgrade spending is separate
  from inventory purchases and sales; accepted upgrades save immediately.
- `Game` autoload: owns economy and persistence, emits signals after mutations,
  handles application pause/resume/focus loss/close. No network dependencies.
- `LocalSave`: versioned JSON, temporary write and flush, validated backup,
  replacement rename, recovery from backup/temp, preservation of invalid or
  unsupported saves. Automatic writes stop if all candidates are invalid.
- `ShopCustomers`: four reusable records; timer updates at 20 Hz only in shop.
  A customer selects a stocked product, walks to shelf/checkout, attempts one
  sale, then leaves. No reservation is needed: a depleted shelf rejects the
  sale. The sold guard is set before calling the transaction.
- `ShopView`: original Godot vector art and normalized customer movement.
- `main.gd`: container-based menu/shop UI and confirmed restart. Scene remains
  loaded during menu/shop changes; customers pause in the menu.
- `InventoryScreen`: a separate scene with a bounded scroll area, ten product
  cards, +1/+5 purchase controls, stock/capacity, cost/sale price/margin and a
  persistent feedback area. Customers pause while shopping in the stockroom.
  Android Back returns to the shop; all orders use the same economy transactions.
- `tests`: independent economy/persistence tests plus actual button signals and
  accelerated customer lifecycle simulation. Test storage is isolated.

`user://progress.json` is the primary save; `progress.backup.json` is the last
validated primary and `progress.tmp.json` is a recovery candidate. A confirmed
reset retains each previous candidate under a fixed `.before-reset` name, so
the archive count stays bounded. Recovery archives are not loaded automatically.
There is no offline income yet. Stock, cash, sales, sold costs and customer count
survive app restart. Active customer movement is intentionally not saved: no
inventory has been reserved, so dismissing an in-flight customer cannot lose stock.

Important transactions save synchronously. At the prototype's sale rate this
is small and infrequent; phone measurements will inform later batching. There
is no crash-proof durability guarantee across hardware/filesystem failures.
Unknown newer schemas are preserved rather than silently downgraded.

Phase 2 saves use schema 2 and additionally persist lifetime stock spending.
Schema 1 saves retain their three original stock fields, coins and sales; new
products default to zero. Their purchase spending is reconstructed as
`500 + revenue - coins`, valid for Phase 1's fixed 500 start with no other coin
sources/sinks. Missing original stock fields still fail validation. A normal
subsequent write now migrates to schema 3 and preserves the original as backup.
Schema 3 adds shelf upgrades, upgrade spending and retained prior product access.
Stock validates against loaded upgraded capacity before applying the record.
Do not downgrade the app after migrating to a newer schema.
General future migration handling remains part of Phase 4.
Full progression/upgrade configuration: `docs/progression.md`.

Gross profit = sales revenue − wholesale cost of units sold. Lifetime stock
spending includes unsold stock; it is shown separately. Unsold inventory value
uses the catalog's fixed wholesale prices. Upgrades are separate cash expenses;
there are no changing prices or staff costs yet. Quantity checks precede arithmetic;
currency/ledger ceilings ensure completed transactions remain saveable.

Desktop default: `%APPDATA%/Godot/app_userdata/Mini Shop Tycoon/`.
Bundled launchers redirect APPDATA into `tools/profile`, so their saves live at
`tools/profile/Godot/app_userdata/Mini Shop Tycoon/`.
Android uses private app storage via Godot's `user://`. Clearing app data or
uninstalling can erase progress. No cloud backup is provided or promised.
