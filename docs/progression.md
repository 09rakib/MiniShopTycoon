# Phase 3 progression and economy

Each successful customer sale earns 10 XP. XP and shop level derive from saved
lifetime customer count, so there is no separate XP balance that can drift.

| Level | Total XP | Total customers | Newly available products |
|---|---:|---:|---|
| 1 | 0 | 0 | Bread, Milk, Apples |
| 2 | 100 | 10 | Eggs, Bananas, Bottled water |
| 3 | 300 | 30 | Rice, Soft drinks |
| 4 | 650 | 65 | Snacks |
| 5 | 1100 | 110 | Soap |
| 6 | 1700 | 170 | Market master milestone |

Phase 2 saves retain access to all ten products. Phase 1 saves retain their
three original products. No previously available product is taken away, even
when its stock is zero. Fresh shops follow the table. Reset clears retained
access and starts the new progression from level 1.

## Shelf upgrades

Each shelf group has three upgrade steps, adding 10 capacity **per product**
per step: 20 → 30 → 40 → 50 with the current catalog. An upgrade applies to
all products assigned to that group, including products unlocked later.

| Group | Products | Step costs | Shop level needed |
|---|---|---|---|
| Pantry | Bread, Rice, Snacks | 120 / 240 / 480 | 1 / 2 / 3 |
| Chilled | Milk, Eggs, Soft drinks, Water | 150 / 300 / 600 | 1 / 2 / 3 |
| Daily picks | Apples, Bananas, Soap | 180 / 360 / 720 | 1 / 2 / 3 |

Purchases validate requirements, step limit, funds and spending ceiling before
changing coins or capacity. If no stock remains, retain enough coins to buy one
unit of the cheapest unlocked product; this prevents upgrades stranding the shop.
Upgrade spending is separate from stock spending and from gross profit.

Progression milestones: buy first stock, serve 10 customers, upgrade a shelf,
reach level 3, unlock ten products, reach level 6. Each has visible progress and
completion. Their states derive from saved monotonic metrics. They have no
claim buttons or coin rewards yet; achievements/reward claiming is Phase 5.

## Save compatibility

Schema 3 stores `shelf_upgrades`, `upgrade_spending` and `retained_unlocks`
alongside existing coins, inventory, costs, revenue, customers and timestamp.
For loading, validate all upgrade levels and retained IDs first, then validate
stock against the corresponding upgraded capacity before applying anything.
Old schemas initialize upgrades/spending to zero. Unknown schemas and invalid
records are preserved under the existing recovery policy. Do not downgrade the
app after a schema upgrade. Full migration hardening remains Phase 4.

Configuration: `data/catalog.json`, `data/progression.json`, `data/upgrades.json`.
The progression/upgrade modules validate their developer data at startup in
debug builds. No device clock, network, ads or external dependency is involved.
