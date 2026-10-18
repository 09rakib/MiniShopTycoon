# Transformation Phase A — audit and decision — 18 October 2026

## Existing implementation

Godot 4.7.2 / typed GDScript, Compatibility 2D renderer, portrait 480×900 logical
viewport. `scenes/main.tscn` + `scripts/main.gd` implement the existing dashboard.
`ShopEconomy` is the single transaction authority. `Game` owns state and emits
signals; `LocalSave` writes/recoveries versioned schema 3 locally. Catalog,
progression and upgrade definitions are JSON. Inventory and upgrade screens are
separate reusable scenes. Customer records are pooled, but their prior automatic
sales add wallet coins directly; that behavior is unsuitable for the new burger
loop and will stay confined to the preserved grocery view until Phases E/F.

Phase 3 has 128 automated checks. Its APK was installed/launched on vivo V2405A;
touch gameplay, save migration and performance acceptance were not reported.
No reference images accompanied this new text attachment. Artwork therefore
follows the written concept; it does not reproduce an unseen reference.

## Reuse and preservation

- Preserve all existing scenes, catalog, transaction, upgrade and save code.
- Keep wallet, grocery inventory, levels, retained unlocks and upgrades intact.
- Preserve the Phase 3 APK and create source backup
  `builds/backups/phase3-before-world.zip` before changing the entry scene.
- New entry scene is additive. Old gameplay remains available via management's
  **Grocery shop** button; stockroom/upgrades remain functional inside it.
- Main world never invokes the old automatic customer simulation. No new burger
  sale or cash behavior is implied in Phase B. No save-schema conversion is
  needed for movement-only play; position starts at a valid spawn on relaunch.

## Proposed world architecture

Use original raised 2D shapes for a lightweight 2.5D elevated shop. This retains
the existing renderer, avoids 3D import/shadow costs and adds no dependencies.
`ShopWorld` builds a deterministic room from JSON, with a static floor, static
fixtures/walls and a single `CharacterBody2D`. `WorkerCharacter` handles movement,
facing, procedural walk/idle poses and collisions. `VirtualJoystick` owns one
touch, clamps its vector, ignores unrelated fingers and resets on pause/focus loss.
`ShopCamera` follows smoothly and clamps its view to decorated room bounds.
`PlayableShop` presents compact wallet/level/XP HUD and a paused management sheet.
No world reload is required when menus open/close. Android system bars remain on.

The machine and serving counter are solid positioned fixtures in Phase B, with
nearby location hints. They do not produce/transfer/sell any item yet. Dedicated
Phase C–F authority will later track machine → carried → counter → uncollected
cash → wallet, with atomic transfer methods rather than independently edited
balances. Machine upgrades/employees/furniture will be added only after that loop.

## Risks and checks

- Joystick must release on touch cancellation, menu entry, focus loss and pause.
- Normalize combined keyboard direction, clamp analog joystick magnitude.
- Match artwork footprints to collision shapes; test walking around and into
  each obstacle and along walls; avoid routes that depend on tiny gaps.
- Clamp camera using actual viewport/zoom; short/tall devices need visual QA.
- Use a small fixed body count, no dynamic shadows, physics props or asset SDKs.
- Keep source backup out of imported/exported assets. Export as version code 4
  under the same package and key for a normal update. Phone FPS is not assumed.

Phase A is complete with this audit. Implement Phase B, validate it, then stop.
The new A–K roadmap supersedes the old numbered roadmap for further expansion.
