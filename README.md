# Mini Shop Tycoon

An offline portrait Android grocery shop game built in Godot 4.7.2 / GDScript.
Current checkpoint: transformation **Phase C — automatic burger production**.
Launch straight into an original raised 2D burger shop. Move the chef with the
bottom-left joystick (or WASD/arrows on desktop). Camera follows within the room;
walls, machine and counter are solid. The world occupies the main screen.

The burger press produces one burger every two seconds, stores at most ten and
shows its real contents and FULL state. It stops when full and resumes when
stock is removed through the shared inventory primitive. Player pickup/carrying
is Phase D; customers, sales and cash collection are later checkpoints.
Existing grocery inventory, economy, levels and upgrades remain available through
Menu; no saved progress is reset. Source backup: `builds/backups/phase3-before-world.zip`.

Double-click **play.cmd** to play on this PC. Double-click **editor.cmd** to open
the Godot project, then press F6/F5 to run (F5 runs the main scene).
Double-click **test.cmd** for the automated checks.

Android: transfer `builds/MiniShopTycoon-phaseC.apk` to an Android 7.0+ phone
and install it using Files. Update the existing app without uninstalling to
retain progress. Schema 4 preserves prior grocery progress and adds saved machine
stock. Source and tests: https://github.com/09rakib/MiniShopTycoon.

The portable engine lives under `tools/godot`; launchers keep its profile and
desktop game saves inside `tools/profile`. No administrator installation needed.
If using a separately installed editor instead, import `project.godot`.

See [setup](docs/setup.md), [manual tests](docs/testing.md),
[architecture](docs/architecture.md), and [phase status](PHASE_STATUS.md).

All gameplay runs locally. No accounts, services, ads, analytics, or networking.
Art is original vector drawing code plus an original SVG icon. Godot includes
its own default font. Engine licensing: https://godotengine.org/license/.
