# Known limits — transformation Phase D

- Players can collect up to two burgers and deliver them to an eight-item counter.
  Customers/counter draining are Phase E; a full counter remains full in D.
- Full-counter deliveries retain carried burgers. There is no discard button or
  artificial inventory drain; do not reset unless you want to clear all progress.
- Cash/wallet collection is Phase F. Producing, collecting and delivering burgers
  never grants coins, sales, customers or XP. Grocery gameplay remains separate.
- Carried/counter counts persist in schema 5. The worker still respawns at a safe
  position on relaunch. Avoid downgrading after migration or uninstalling/clearing
  app data; there is no cloud backup.
- Completed item transfers save immediately. Production uses five-second batches
  and lifecycle flushes; abrupt termination with no callback can lose recent
  unsaved production. No offline/catch-up production is granted.
- Original raised 2D visuals remain lightweight. Room art follows the checked-in
  dimensions; station interaction markers now use shared world-layout points.
- Previous Android installation was aborted by the phone; this phase is not
  automatically installed. Physical touch/cancellation/multitouch, migration,
  lifecycle, airplane mode and performance need user testing.
- No measured FPS, low-end, memory, heat or battery result is claimed.
