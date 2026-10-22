# Architecture

## Current entry: transformation Phases B/C/D

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

Phase B introduced no new saved gameplay field/currency source. Phase C adds
`ProductionState`, owned by ShopEconomy, and `ProductionController`, a one-shot
timer in the playable world. The model is authoritative; stock changes emit
signals to restart/stop the timer and update visuals. Full/inactive machines
have no production wakeups. Timer callbacks create at most one bounded item.
Machine configuration includes future upgrade tiers; upgrade buying is Phase G.

Schema 4 stores machine ID, stock, level and active state alongside the previous
economy. Schemas 1–3 initialize production empty/active at level 1. Validation
finishes before applying any field, including machine stock, so invalid new
fields cannot partially overwrite a valid wallet. Old backup behavior remains.
Production dirties state; a five-second timer batches writes, and normal
transactions/pause/focus-loss/quit flush immediately. An abrupt kill without
lifecycle callbacks can lose up to five seconds of newly produced items; Phase J
will harden process-death behavior. Partial production time is not persisted:
resuming/relaunch starts a fresh interval, with no offline catch-up.

Movement does not write saves; relaunch starts the worker at a valid spawn.
Phase D adds `BurgerHandling`, owned by ShopEconomy, with separate carried and
counter stock. Configured limits are two/eight; interaction points come from the
same world-layout JSON used by fixtures/markers. Transfer methods recheck distance,
calculate the bounded amount and reject empty/full/far interactions without any
mutation. Pickup credits carried stock before the machine emits stock_changed,
so observers see both sides completed. Partial delivery retains the remainder.
Game immediately persists every successful transfer in one complete save, then
updates visible carried/counter stacks and HUD. Button actions re-read the real
worker position instead of trusting a potentially stale proximity prompt. Menu,
focus-loss and background state block actions as well as movement.

Schema 5 stores both carried and counter quantities. Schemas 1–4 initialize them
to zero while preserving previously valid fields, including existing machine
stock from schema 4. All fields validate before state changes. Relaunch moves
the worker to its safe spawn but keeps burgers in hand. Full-counter items are
not discarded on shutdown. Invalid counts cannot partially apply a wallet.
There are no burger sales, cash collection, machine-upgrade purchases, employees
or furniture purchases before their intended phases.
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


## Phase E — bounded customers and atomic counter sales

BurgerSales is owned by ShopEconomy. It registers unique monotonic runtime visit
IDs with at most four live tickets, consumes each once, and retires on departure.
Sold tickets remain marked until exit, preventing repeat checkout. Retired IDs
are never reassigned within that instance; reset/restore invalidates all tickets.
No completed-ticket history grows over time. Only current visitors are retained.

BurgerCustomers owns arrival Timer and small queue FSM. BurgerCustomer bodies
use fixed right-side approach/checkout/outer exit routes, collide against world
layer 1 and never block the worker. State progression: ENTERING/QUEUING →
WAITING_FOR_STOCK → BUYING → LEAVING. Only queue head enters BUYING. Empty stock
waits, stock patience expires without a sale; blocked movement expires safely.
Timers/body updates freeze on app background/focus loss, no offline catch-up.
Menus block worker input while business continues, consistent with production.
All timings/cap/route coordinates are in data/customers.json.

Game.sell_burger delegates one synchronous transaction: validate live unused
visit, counter stock, configured machine price and ledger ceilings; mark ticket,
deduct exactly one counter burger and increase pending cash/revenue/sold count.
No signals/awaits occur within mutation. Game persists the completed inventory
and ledger together before publishing handling/sale signals. Production/carry
stock, grocery ledger/XP and wallet are untouched. Zero ingredient expense means
burger gross profit equals burger revenue for now; staff/ingredient expenses are
not silently included. Cash accumulation is E; physical collection is F.

Schema 6 adds burger_sales {uncollected_cash, sold, revenue}. Entire save validates
before applying any field, including totals and pending <= revenue. Schemas 1–5
initialize these to zero and preserve prior progress. Runtime customers/tickets
are deliberately not serialized: only durable sale/inventory results survive.
Restart does not replay purchases. Phase F will transfer cash into wallet.


## Phase F — authoritative proximity cash collection

CashPickup reads data/cash_pickup.json and the existing cash fixture hint point
from world_layout.json. Its finite-vector distance check is authoritative for
ShopEconomy.collect_cash. Radius 46 keeps worker spawn and delivery station out
of range. The scene's nearby timer polls at 150 ms, while menu/legacy overlay,
blocked controls, suspension or paused tree prevent auto pickup. Actual worker
position is supplied anew for each transaction; no cached UI prompt grants cash.

ShopEconomy transfers all pending cash synchronously into wallet if positive,
nearby and fully within MAX_TOTAL. No partial ceiling payout: failure preserves
both balances. Sold count, revenue, gross profit, food inventories and grocery
XP/ledgers do not change. BurgerSales.gross_profit derives revenue because current
automatic burgers have zero ingredient cost; collected_cash derives revenue minus
pending cash. Neither is confused with current wallet after spending.

Game.collect_cash writes the combined snapshot before signals/reward; it rolls
back both in-memory fields before publishing failure if storage.write fails.
Success clears production_dirty, emits changed then cash_collected(amount).
No new persistent field/schema is needed: schema 6 already stores both sides.
Save callbacks see a fully committed transaction and rewards only follow a
successful write. Failed attempts use a three-second nearby retry cooldown.

Cash fixture draws actual pending amount and at most three note stacks; zero
shows EMPTY. ShopWorld updates fixture on inventory/wallet events and uses one
reusable Label/Tween for floating +amount; replacement kills the old tween.
No unbounded money/reward nodes, no per-frame scans or extra permission required.


## Phase G — independent upgrades and a stocker

ProductionState.level now means speed tier. capacity_level and price_level are
independent persisted tiers; capacity(), interval(), selling_price() return the
actual active values from machines.json. Existing levels array retains its speed
and capacity examples. Separate capacity costs and price tiers configure purchases.
A speed purchase restarts the engine cycle at its new interval, without producing
an item. Capacity preserves stock/resumes full machines. Price is sampled at each
successful checkout, even for previously produced burgers; old cash is never
repriced. All tiers cap at five, costs grow progressively.

ShopEconomy.purchase_operation validates action, maximum level, wallet funds and
business expense ceiling before changing anything. ShopOperations stores one
hired flag, staff carried items and aggregate business spending separate from
legacy shelf upgrades. Game saves the combined purchase before broadcasting effects
or creating an employee; failure restores old wallet/tiers/hire/spending first.
No pending cash can finance purchases. Cash collection remains separate.

BurgerHandling.transfer and available_amount accept an optional ShopOperations
carrier. Player and stocker use the SAME capacity/proximity/source/destination
rules; the destination carry credit precedes machine stock-change signals. One
shared counter avoids competing independent inventories. Staff pickup/delivery
saves all inventories immediately and marks dirty for retry after storage failure.

StockerController owns one WorkerCharacter with blue uniform/cap and a bounded
fixed waypoint route from operations.json. Decisions use a 350 ms Timer; physics
only steers the actor along its route. Pickup/delivery happens at arrival and
rechecks actual world proximity. Full counter retains held food, partial delivery
retains remainder, empty press waits, no stock teleports. Worker speed is 135,
carry capacity uses the same two-item configuration as the player. Menus leave
business running; focus loss/pause blocks movement and stops decision timers.
World fixtures are layer 1; workers layer 2 and all characters test only layer 1,
so staff/customers cannot trap the player. Future furniture must preserve this aisle.

BurgerOperationsPanel is a compact modal workshop under Menu. It shows actual
wallet/current/next stats/costs, disables unaffordable/maxed/duplicate-hire actions,
and updates existing controls on events. Back closes workshop before menu.

Schema 7 adds operations {hired, carried, spending} and requires machine
capacity_level/price_level. All fields validate before applying any saved value.
Schemas 1–6 keep previous wallet, groceries, upgrades, machine/held/counter stock
and cash; legacy machine level supplies both speed/capacity, price starts at 1.
Old saves initialize no employee or business spending. Employee-held food persists;
position/task path restarts safely at the press and resumes delivery. No offline
employee work, wages, cashier or dismissal are introduced in this checkpoint.


## Phase H — a second machine and deterministic furniture

ShopExpansion owns a ProductionState("fries_press") and a BurgerHandling
("fries_machine", 4). Both use the same existing classes as burgers. A second
ProductionController receives its state before entering the scene; its one-shot
cycle is inactive while locked. Primary controller's shared autosave timer writes
all machine/inventory state. Burger speed upgrades reset only the burger cycle.
No duplicated machine production script or unbounded spawning.

expansion.json configures 400 unlock, 180 table/two-chair bundle, two seats and
fixed world rectangles/approach points. ShopEconomy validates wallet/expense caps
and ownership before purchases. Game writes before changed/world creation, and
restores wallet/expansion on write failure. Owned fixtures are reconciled by ID,
not appended each refresh; reset removes them. World collision uses the fixed
footprints; tests check player-radius margins around staff aisle, customer lane
and entrance. Furniture provides persistent seat capacity, not fake dining income.

Existing transfer code supports another machine source. Economy's authoritative
food_action/food_amount/transfer_food routes player interaction by current world
position. Each player trip carries at most two of one type; other-type pickup
rejects without overwriting food. Shared staff transfer still handles burgers.
Separate burger/fries counter shelves store 8/4 respectively. Full/partial
shelves retain leftovers. Machine→carry→counter are paired synchronous mutations.

BurgerSales remains the compatible class/save name, now a shared food-sale ledger.
It chooses an available shelf, alternates when both stocked, consumes one item,
credits that source's current selling_price and marks the visit consumed once.
No cross-product duplicate sale. next_fries rotation persists (old records default
false). Total sold/revenue/pending and cash collection cover both foods; original
grocery accounting remains separate. Both automatic foods currently have zero
ingredient cost; expansion expense is separate from gross profit.

Schema 8 adds expansion flags, spending, production and handling. All nested
records validate before any working state applies; reject stock on locked machine,
active/unlock disagreement, wrong limits and saved mixed player carrying. Schemas
1–7 preserve all previous fields and initialize locked/unowned/empty expansions.
Own machine/furniture reconciles once on relaunch. Worker positions are transient,
held food is durable. No offline work/income, seating behavior or fries upgrades
introduced beyond the initial configurable tier in this checkpoint.


## User-requested touch update (after H)

ShopJoystick is now a full-viewport Control with mouse_filter IGNORE. It starts a
new gesture only in _unhandled_input after GUI processing and explicitly excludes
Menu's actual transformed rectangle. Captured drag/release/cancel is handled in
_input, so leaving the original point does not lose control. The first touch
becomes the local center through the canvas transform; initial direction is zero.
Only one finger owns the gesture. Direction clamps/dead-zone rules are retained.
_draw emits nothing while idle; base/thumb alpha 0.14/0.32. Disabled/menu/pause/
focus loss calls release and resume requires a new touch. Desktop mouse drag works.

HUD is a compact horizontal wallet/level row plus slim carry/counter/pending cash
row, with a 44px Menu target. There is no fixed joystick instruction/control zone
or Collect/Deliver button. Context text and short feedback retain world focus.

The existing 150 ms nearby Timer calls _auto_transfer_food, _try_collect_cash and
updates location text. Both operations reject blocked/menu/suspended/paused state,
re-read worker position and only transact positive available quantities. Economy
food routing/limits/persistence remain authoritative, including fries, partial
shelves and one food type per trip. Empty/full polls do not mutate/save. Automatic
cash behavior and safe persistence are preserved. Schema 8 needs no new field.
That control patch was followed by the user's explicit Phase I continuation.

## Phase I presentation

Game.presentation(kind, point, amount) carries presentation-only events after
successful saves for transfers, sales, cash and purchases. Production emits after
a real produced item. Subscribers cannot grant stock/money: authoritative state
stays in the existing transaction classes. Four WorldCue instances are reused,
expire within 0.8s and stop processing. Worker poses use one replaceable tween;
machine animation redraw is 10Hz and full/inactive machines stop processing.
Customers show their existing patience timeout and a paid-only bag/thanks.

ShopAudio maps eight original local WAVs onto four AudioStreamPlayers, suppresses
same-sound repeats within 80ms, ignores production and uses quieter staff cues.
Headless simulations use a silent sink; Android/desktop use actual playback.
Focus loss stops voices, cues, cash reward and worker/staffer poses. Muting stops
active sounds and persists separately through ShopSettings preferences.cfg using
a temporary file/rename. Failed writes retain the prior value; malformed settings
fall back to sound on. Economy reset leaves the preference intact.

Menu and sheets fade in over 160ms; visibility and movement exclusion take effect
immediately. Closing kills pending entrance tweens and hides immediately, retaining
the floating joystick and automatic interaction guards. Sound controls are in the
menu so the two-line gameplay HUD stays compact.

## Phase J persistence and failures

LocalSave checks supported schemas before considering fallback; a newer-schema
candidate blocks writes. Fresh load attempts clear stale blocked/messages. Reset
prepares progress.reset.json, copies original primary/backup/temp to before-reset
archives, commits the fresh primary, removes obsolete recovery candidates, then
resets live state. Until the commit, original progress remains authoritative;
prepared reset files are never normal recovery candidates.

Game rolls back failed player/staff food writes using a small stock/carry/counter
checkpoint and emits refresh after restoring all ledgers. Failed customer sales
restore both shelves, aggregate sales and the live unpaid ticket map. Grocery
buy/sell/upgrades restore only affected fields. Existing production/controller
instances remain stable. Cash and operation/expansion purchases retain their
earlier rollback rules. Success feedback/presentation follows durable success.

## Phase K resource and export bounds

WorkerCharacter and ShopFixture reuse StyleBoxFlat resources keyed by palette color
and radius instead of allocating on every draw. The fixed artwork palette bounds
the cache; drawing colors/geometry are unchanged. Production/cue redraw throttles,
four-customer/four-effect/four-voice bounds and existing simulation remain intact.
The standalone benchmark creates an isolated expanded-shop save and compares busy,
menu and paused idle rendering on desktop; it is excluded from shipped artifacts.

Export presets separate update-compatible debug APK, unsigned release-template APK
and unsigned Gradle AAB. AAB SDK min/target are pinned to 24/36; non-Gradle APKs
inherit the verified template levels (overrides require Gradle). Game category uses
exporter enum index 2 (Android manifest category 0), not index 0 (Accessibility).
Generated android/ content, tooling, credentials and APK/AAB outputs are ignored.
audit_android.py checks ZIP CRC, excluded/private content, ARM64 ELF load alignment
and AAB structure. bundletool validates the bundle; signing/device checks remain
separate release gates, not runtime gameplay behavior.
