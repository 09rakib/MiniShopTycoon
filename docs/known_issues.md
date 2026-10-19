# Known limits — transformation Phase G

- One stocker is implemented as the initial useful employee type. No cashier,
  general assistant, wages or dismissal yet. Stocker capacity shares player limit
  of two and counter limit of eight; cannot pick up while counter is already full.
- Fixed employee path uses the clear aisle between press and counter. Future
  furniture/machine placement must preserve it. Character bodies ignore one
  another while respecting solid fixtures; employees do not block the player.
- Speed/capacity/price each have five independent tiers. Price is read at checkout,
  including food produced before the upgrade; historical pending cash is unchanged.
  Speed purchase restarts the partial production interval; no instant bonus food.
- Business spending (machine upgrades/hire) is recorded separately from grocery
  shelf expenses and ingredient cost. Burger gross profit remains sales revenue
  because automatic burgers have zero ingredient cost; spending reduces wallet.
- Stocker does not collect cash. Proximity cash collection remains the player's
  job. Background/focus loss pauses all active shop workers/customers/machines.
  Menus block player input while the shop continues running.
- Schema 7 retains employee-held food and purchased levels, not worker positions.
  Relaunch places employee safely at the press and resumes carrying toward counter.
  Avoid downgrades/uninstall/data clearing; no cloud/offline work or earnings.
- Purchases save before spawning/applying effects and roll back on write failure.
  Inventory transfers keep coherent in-memory results if storage fails; staff marks
  dirty for five-second retry plus lifecycle flush. Durable play needs working
  storage. Abrupt kill can still lose recent production without a save callback.
- Phase F was installed/launched earlier. G APK verified but phone absent from ADB,
  so physical G touch, lifecycle/migration, airplane mode and performance remain
  pending. No measured Android FPS/memory/heat/low-end result is claimed.
