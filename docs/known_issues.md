# Known limits — transformation Phase F

- Core loop is playable: automatic production → manual carry/delivery → customer
  purchase → pending cash → physical proximity collection → spendable wallet.
- Burger machine upgrades and employees are Phase G; existing grocery inventory,
  upgrades and goals still accept the same wallet through Menu.
- Collection radius is 46 units around the cash fixture approach marker, polled
  every 150 ms. Menu, blocked controls and background/focus loss prevent pickup.
  A full wallet retains all pending cash. Storage failure rolls back both fields,
  shows an error and retries no sooner than three seconds while near the plate.
- One cash fixture draws at most three stacks. One reusable reward label replaces
  its previous animation when another pickup occurs. Visual effect, no sound yet.
- Burger sold/revenue/profit/collected totals remain separate from grocery XP and
  ledgers. Free automatic production has zero ingredient cost, so burger gross
  profit equals revenue; collection changes wallet/pending, not historical sales.
- Customer tickets/routes restart on relaunch; committed purchases are not replayed.
  Worker respawns safely, held stock persists. No offline production or earnings.
- No new schema required for F: schema 6 retains wallet and pending cash together,
  with earlier migrations preserved. Avoid downgrade/uninstall/data clearing.
- Sales/transfers/collections save immediately. Production batches five seconds
  and lifecycle flushes; abrupt termination may lose recent unsaved production.
- No automatic phone install retry after earlier refusal. Physical touch,
  multitouch, device lifecycle/migration, airplane mode, FPS/memory/heat and low-end
  performance remain pending. No measured device performance result is claimed.
