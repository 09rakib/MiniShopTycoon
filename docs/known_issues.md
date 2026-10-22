# Known limits — transformation Phase H

- Burger and fries loops are playable with separate machine/counter inventories.
  Player carries at most two items of one product type per trip; deliver before
  switching foods. Counter capacity: 8 burgers + 4 purchased fries trays.
- Stocker handles burgers only. Fries is manually carried. Burger speed/capacity/
  price upgrades are preserved; fries has a single initial 3s/8/16 tier. Shared
  production interface supports future configuration without copied scripts.
- Customers alternate when both foods are stocked, otherwise buy available food.
  One purchase per visit across both products. Revenue/sold/pending totals now
  represent all food; cash collection/old grocery ledgers remain separate.
- Table and two chairs are one fixed 180-coin bundle with two seats. Solid valid
  placement is persistent, but dining/seating bonuses/dragging are later scope.
  Do not assume customers will sit or furniture itself generates money.
- Fixed employee aisle, customer lane and entrance must stay clear in future
  placement changes. Current placements include character-radius safety margins.
- Schema 8 retains all inventories, owned content and money. Worker/customer/
  stocker positions restart safely; food persists. No offline production/work/
  sales. Avoid downgrade/uninstall/data clearing; no cloud backup.
- Purchases persist before creating objects; failure rolls back flags/wallet.
  Food transfers preserve coherent memory and lifecycle flushes on storage
  failure. Production batches five seconds; abrupt termination can lose recent
  unsaved production. Durable play requires working local storage.
- New art remains lightweight procedural 2D. No Phase H phone install/touch,
  device migration/lifecycle, airplane-mode, FPS/memory/heat/low-end result claimed.
  Visual/audio polish is I, comprehensive lifecycle J, Android release checks K.
