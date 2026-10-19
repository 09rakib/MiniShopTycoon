# Mini Shop Tycoon

An offline portrait Android grocery shop game built in Godot 4.7.2 / GDScript.
Current checkpoint: transformation **Phase G — machine upgrades and a working stocker**.
Launch straight into an original raised 2D burger shop. Move the chef with the
bottom-left joystick (or WASD/arrows on desktop). Camera follows within the room;
walls, machine and counter are solid. The world occupies the main screen.

The initial burger press produces one burger every two seconds and stores ten.
Walk to COLLECT and tap the contextual button to carry up to two burgers. Walk
to DELIVER and place them on the eight-item counter. Full counters preserve any
leftover burger in your hands. Desktop E also interacts. Counts, visible stacks
and machine production update together. Up to four customers queue on the right,
buy one available counter burger each and leave. Each sale starts at 20 coins added to Cash waiting;
wallet coins increase only when the chef walks to the CASH circle. One aggregate
pickup transfers the exact amount, clears the cash plate and shows +amount.
Collection saves immediately and cannot pay twice.

Menu → Burger machine & stocker opens independent speed/capacity/price upgrades
and a 300-coin stocker hire. Current/next values and wallet costs are shown.
Stocker wears a blue cap, physically walks and carries at most two burgers to the
counter. Full counters preserve staff-held food; employee progress/upgrades save.
Only collected wallet coins fund purchases; no offline staff work or wages.
Existing grocery inventory, economy, levels and upgrades remain available through
Menu; no saved progress is reset. Source backup: `builds/backups/phase3-before-world.zip`.

Double-click **play.cmd** to play on this PC. Double-click **editor.cmd** to open
the Godot project, then press F6/F5 to run (F5 runs the main scene).
Double-click **test.cmd** for the automated checks.

Android: transfer `builds/MiniShopTycoon-phaseG.apk` to an Android 7.0+ phone
and install it using Files. Update the existing app without uninstalling to
retain progress. Schema 7 preserves grocery/machine progress and also saves carried
and counter burgers, pending cash/sales, independent upgrades and stocker state. Source and tests: https://github.com/09rakib/MiniShopTycoon.

The portable engine lives under `tools/godot`; launchers keep its profile and
desktop game saves inside `tools/profile`. No administrator installation needed.
If using a separately installed editor instead, import `project.godot`.

See [setup](docs/setup.md), [manual tests](docs/testing.md),
[architecture](docs/architecture.md), and [phase status](PHASE_STATUS.md).

All gameplay runs locally. No accounts, services, ads, analytics, or networking.
Art is original vector drawing code plus an original SVG icon. Godot includes
its own default font. Engine licensing: https://godotengine.org/license/.
