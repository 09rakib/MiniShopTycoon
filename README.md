# Mini Shop Tycoon

An offline portrait Android grocery shop game built in Godot 4.7.2 / GDScript.
Current checkpoint: transformation **Phase B — playable world and movement**.
Launch straight into an original raised 2D burger shop. Move the chef with the
bottom-left joystick (or WASD/arrows on desktop). Camera follows within the room;
walls, machine and counter are solid. The world occupies the main screen.

This checkpoint tests movement/layout only. Burger production, carrying,
customer queue sales and cash collection belong to the next approved phases.
Existing grocery inventory, economy, levels and upgrades remain available through
Menu; no saved progress is reset. Source backup: `builds/backups/phase3-before-world.zip`.

Double-click **play.cmd** to play on this PC. Double-click **editor.cmd** to open
the Godot project, then press F6/F5 to run (F5 runs the main scene).
Double-click **test.cmd** for the automated checks.

Android: transfer `builds/MiniShopTycoon-phaseB.apk` to an Android 7.0+ phone
and install it using Files. Update the existing app without uninstalling to
retain progress. Save schema remains 3 for this movement checkpoint. See the guides below.

The portable engine lives under `tools/godot`; launchers keep its profile and
desktop game saves inside `tools/profile`. No administrator installation needed.
If using a separately installed editor instead, import `project.godot`.

See [setup](docs/setup.md), [manual tests](docs/testing.md),
[architecture](docs/architecture.md), and [phase status](PHASE_STATUS.md).

All gameplay runs locally. No accounts, services, ads, analytics, or networking.
Art is original vector drawing code plus an original SVG icon. Godot includes
its own default font. Engine licensing: https://godotengine.org/license/.
