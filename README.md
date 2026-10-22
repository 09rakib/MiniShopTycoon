# Mini Shop Tycoon

An offline portrait Android grocery shop game built in Godot 4.7.2 / GDScript.
Current checkpoint: **Phase J — save/lifecycle verification (v0.12.0)**.
Launch straight into an original raised 2D burger shop. Move the chef with the
floating joystick: touch and drag anywhere in gameplay (or WASD/arrows on desktop).
Joystick starts hidden, appears faintly at your touch and hides on release. Camera follows within the room;
walls, machine and counter are solid. The world occupies the main screen.

The initial burger press produces one burger every two seconds and stores ten.
Walk to COLLECT to automatically carry up to two burgers. Walk
to DELIVER to automatically place them on the eight-item counter. Full counters preserve any
leftover burger in your hands. Counts, visible stacks
and machine production update together. Up to four customers queue on the right,
buy one available counter burger each and leave. Each sale starts at 20 coins added to Cash waiting;
wallet coins increase only when the chef walks to the CASH circle. One aggregate
pickup transfers the exact amount, clears the cash plate and shows +amount.
Collection saves immediately and cannot pay twice. The top wallet/level HUD is
compact, with carry/counter/pending cash arranged on a slim second line.

Menu → Burger machine & stocker opens independent speed/capacity/price upgrades
and a 300-coin stocker hire. Current/next values and wallet costs are shown.
Stocker wears a blue cap, physically walks and carries at most two burgers to the
counter. Full counters preserve staff-held food; employee progress/upgrades save.
Only collected wallet coins fund purchases; no offline staff work or wages.

Menu → New machines & furniture unlocks a 400-coin fries press (3s, storage 8,
price 16, four counter trays) and a 180-coin table + two-chair set. Collect fries
automatically at FRIES, auto-serve at DELIVER; player carries two of one product per trip.
Customers alternate foods when both are stocked. Stocker handles burgers only.
Furniture adds two persistent seats; dining comes later.
Existing grocery inventory, economy, levels and upgrades remain available through
Menu; no saved progress is reset. Source backup: `builds/backups/phase3-before-world.zip`.

Double-click **play.cmd** to play on this PC. Double-click **editor.cmd** to open
the Godot project, then press F6/F5 to run (F5 runs the main scene).
Double-click **test.cmd** for the automated checks.

Pickup and service lift the chef's hands and show the transferred quantity.
Production has a gentle machine light/steam cue; customers show remaining patience
and leave with a bag and thanks after payment. Cash, upgrades and unlocks have
brief feedback. Eight original short sound cues play through four reused voices.
Menu → Sound toggles all cues and saves the choice locally. Menus fade in while
blocking movement immediately; app focus loss stops sound and transient effects.

Android: transfer `builds/MiniShopTycoon-phaseJ.apk` to an Android 7.0+ phone
and install it using Files. Update the existing app without uninstalling to
retain progress. Schema 8 preserves grocery/machine progress and also saves carried
and counter burgers, pending cash/sales, independent upgrades, stocker state, fries and purchased furniture. Source and tests: https://github.com/09rakib/MiniShopTycoon.

Failed saves now roll back player/staffer transfers, customer sales and grocery
purchases/sales/upgrades. Unsupported newer saves block writes instead of falling
back to an older backup. Explicit reset prepares fresh progress before replacing
the primary and archives old files; failed preparation leaves live progress intact.
585 automated checks pass; see docs/test_report_phaseJ.md. Phone testing of this
version is deferred at the user's request; Phase I v0.11.0 was installed previously.

The portable engine lives under `tools/godot`; launchers keep its profile and
desktop game saves inside `tools/profile`. No administrator installation needed.
If using a separately installed editor instead, import `project.godot`.

See [setup](docs/setup.md), [manual tests](docs/testing.md),
[architecture](docs/architecture.md), and [phase status](PHASE_STATUS.md).

All gameplay runs locally. No accounts, services, ads, analytics, or networking.
Art is original vector drawing code plus an original SVG icon; sound is original
synthesized PCM audio (regenerate with `python tests/generate_audio.py`). Godot includes
its own default font. Engine licensing: https://godotengine.org/license/.
