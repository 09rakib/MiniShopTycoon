# Known limits — transformation Phase E

- Sales accumulate pending cash, separately from wallet. Physical cash collection
  is Phase F, so these proceeds cannot yet be spent. No forced collection/reset.
- Burger transactions have their own sold/revenue ledger. Old grocery customers,
  XP, cost/profit and wallet logic are preserved. Automatic burger production has
  no ingredient expense yet, so burger gross profit equals burger revenue; this
  is not spendable cash. Employees/upgrade expenses come in later phases.
- Live visitors/tickets/routes restart on relaunch. Completed stock/cash records
  persist, so restarting does not repeat purchases. No offline sales/production.
- Maximum four customers includes customers leaving. New arrivals may wait for a
  slot. Fixed routes use the right lane; customers collide with walls/fixtures,
  but do not physically block the worker. Changed/blocked routes expire safely.
- Customer art/state labels are simple original procedural shapes. Audio, richer
  reactions, furniture, employees and machine purchases remain later phases.
- Worker position respawns safely; held items persist. Save schema 6 retains old
  records. Avoid downgrades, uninstall/data clearing; no cloud backup.
- Sales/transfers write immediately. Production batches five seconds and flushes
  on lifecycle events. Abrupt termination can lose the latest unsaved production.
- A failed disk write reports an error and retains in-memory progress for retry;
  no crash-durability claim is made for a device whose storage cannot be written.
- No automatic install retry after prior device refusal. Phone touch/multitouch,
  airplane mode, lifecycle, memory/FPS/heat and low-end performance remain pending.
