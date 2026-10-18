# Phase D manual checkpoint — collect, carry and deliver

Install builds/MiniShopTycoon-phaseD.apk over the existing game without
uninstalling or clearing data. Version 0.6.0/code 6 uses save schema 5 and retains
prior coins, grocery inventory, level, upgrades and existing machine burgers.
New carried/counter stock starts at zero when loading an older version.

## Core gameplay

1. Walk to the COLLECT circle below the burger press. Wait for at least two
   burgers. The lower-right button should show Collect 2; its context label
   shows the machine's exact stock. Tap once: Carry becomes 2/2, two burgers
   disappear from the machine and appear in the worker's hands.
2. Tap/hold again. Full hands block another pickup. There must be no negative
   machine stock, extra burgers or lost burgers. Production resumes if the
   machine was previously full, without needing another button.
3. Walk away. The action button disappears; the worker keeps both burgers.
   Carry count and visible stack remain while walking in every direction.
4. Walk to DELIVER beside the serving counter. Tap Deliver 2: Carry becomes
   0/2, Counter becomes 2/8 and the burgers visibly appear on the counter.
5. Repeat four two-item deliveries to fill 8/8. Pick up two more and return:
   Counter full is disabled and both carried burgers stay with the worker.
6. If you have only one burger available, collect exactly one. The machine
   should never invent a second burger. Empty hands cannot deliver.
7. A stale prompt must not work from afar: move out of the interaction area
   before tapping. No stock should move when the worker is out of range.

## Saving and controls

- Close/reopen while carrying. The worker respawns safely but retains the exact
  carried amount; counter and machine counts also persist.
- Successful pickup/delivery saves immediately, including production since the
  previous batch save. A rejected action changes no inventory or money.
- Try action with one finger while dragging the joystick with another. The
  joystick must not capture action-button touches. Release either finger and
  confirm predictable motion and no duplicate action.
- Menu/background/focus loss block interactions. Android Back returns through
  existing management navigation. Closing management preserves worker position.
- Desktop: joystick or WASD/arrows, and E for the contextual interaction.
- Test airplane mode and Home/resume. Confirm old grocery data under Menu remains
  intact. Do not reset unless you want all old and new progress cleared.

There are no burger customers/sales yet. Counter draining is Phase E, so it
stays full once stocked in this checkpoint. Cash collection is Phase F. Pickup
and delivery do not increase wallet, revenue, XP or customer count. Full-counter
rejection/partial delivery are also covered by automated tests.

## Verification

Run test.cmd: 128 economy + 34 world + 32 production + 44 handling = 238 checks.
Production tests use real timers; handling tests include 10,000 invalid repeated
attempts, conservation, proximity, partial delivery, migration and immediate
save/load. Screenshot script: tests/capture_handling.gd.

The previous phone update was aborted by Android; this phase provides a fresh
APK without automatically retrying that rejected install. Physical phone touch,
restart migration, airplane mode, process death and sustained performance still
need manual testing. No measured FPS, battery or memory result is claimed.

Please report the behavior before Phase E begins. Each finished checkpoint is
committed and pushed to https://github.com/09rakib/MiniShopTycoon as requested.
