# Transformation Phase B manual checkpoint

The game now opens directly into a walkable burger shop. This checkpoint is
movement/layout only. The burger machine, serving counter and cash tray are
positioned solid fixtures; production/carrying/sales/cash start in Phases C–F.

## Run

- PC: double-click play.cmd. Use WASD/arrows or drag the joystick with the mouse.
- Android: install builds/MiniShopTycoon-phaseB.apk as an update without
  uninstalling/clearing data. The saved grocery game remains under Menu.
- Source snapshot before transformation: builds/backups/phase3-before-world.zip.

## Movement and collision

1. Drag the lower-left joystick in every direction; try diagonals. The worker
   should face movement, walk smoothly and stop as soon as you release.
2. Start a drag and move your finger outside the joystick circle, then release.
   The worker must stop. A second finger touching Menu must not steal movement.
3. Walk up to the burger machine, around both sides, then to the serving counter.
   Walk into each solid object: the worker's feet must not pass through it.
4. Walk along all walls and the entrance boundary. Stay inside the shop. The
   painted expansion bay and queue circles are floor markings, not solid props.
5. Move from one side to the other. The camera should follow gently, keep the
   active area readable and show no unintended empty area beyond the room.
6. Check character size, equipment labels and control visibility on your screen.
   System bars remain visible; the joystick sits above the navigation area.

## Controls and old progress

1. While moving, open Menu. Movement stops immediately. Return to the shop;
   movement waits for a fresh joystick drag and the worker stays in place.
2. Open Inventory and Shelf upgrades & goals. Confirm your previous coins,
   products, capacity, level and upgrades are still present. Purchases continue
   to use the original validated grocery economy.
3. Previous grocery shop opens the original dashboard and its existing customer
   gameplay. It is intentionally separate from the future burger loop.
4. Use Back to Little Bun, then Back to the shop. The new world is not reloaded;
   worker position is kept. Legacy automatic sales stop outside the grocery view.
5. Android Back closes grocery content to management; closes management to the
   world; and opens management when pressed in the world.
6. Press Home during movement, then return. The joystick should be neutral and
   the worker must not continue moving without a new touch.
7. Close/reopen or force stop. Grocery progress persists; the worker starts at a
   safe spawn. No new movement-only save data is introduced in this checkpoint.
8. Test airplane mode and several minutes of walking. Report input lag, crashes,
   heat, camera problems, clipping or routes that feel too tight.

## Automated checks and evidence

- test.cmd runs the original 128 regression checks plus 31 world/input/physics
  checks and flags engine script errors in the logs.
- tests/capture_world.gd renders screenshots at 480×900, 360×640 and 480×1040.
- docs/test_report_phaseB.md records actual results and connected-device status.

Please report your phone observations before Phase C begins. No production,
carrying, new customer sales, employees or furniture expansion is implemented yet.
