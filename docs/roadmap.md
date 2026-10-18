# Development roadmap — gameplay transformation

The original numbered Phases 0–3 remain completed and preserved. The user has
changed the gameplay direction; the following A–K roadmap now controls new work.

- A — Audit existing systems, choose additive architecture, back up Phase 3.
  Completed; see transformation_audit.md.
- B — Walkable shop, worker, joystick, collision, camera and compact HUD.
  Implemented and tested; current manual checkpoint. STOP for user feedback.
- C — Automatic burger production: 2 seconds, capped machine stock, full/resume.
- D — Carry up to two burgers; proximity pickup, visual stack and counter delivery.
- E — Bounded customers, queues, one counter-stock sale per customer, cash accrued.
- F — Proximity cash pickup; atomic uncollected-cash → wallet transfer and save.
- G — Real production/capacity/price upgrades and one reliable employee type.
- H — Additional machine framework and valid fixed furniture placements.
- I — Visual/audio/animation polish and mobile menu refinement.
- J — Complete save/migration/progression and lifecycle verification.
- K — Real-device performance, final Android export/release and current policy QA.

Build a single authoritative burger transaction pipeline in C–F. Prior automatic
sales remain confined to the preserved grocery view until explicitly replaced.
Keep wallet, sales/profit, machine/carried/counter stock and uncollected cash
separate. No ads, accounts, servers, networking or mandatory external services.

Advance only when the user approves the current checkpoint or explicitly asks
to continue. Later phases are not implicitly authorized by finishing Phase B.
