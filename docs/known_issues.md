# Known issues and limits — transformation Phase B

- This checkpoint is a playable movement foundation. Production, burger carrying,
  new customer queue sales, uncollected cash, machine upgrades and employees are
  future phases. The stationary machine/counter/cash tray are world fixtures.
- Previous grocery economy/inventory/upgrades/customer features remain in Menu.
  They operate on the original saved business and do not represent burger sales.
- Worker position resets to a safe spawn on relaunch. Grocery progress remains
  persisted under schema 3; movement does not write files every frame.
- Raised 2D visuals are original procedural artwork. No dynamic shadows, complex
  physics props, pathfinding or external dependencies were added.
- Floor art currently targets the checked-in room dimensions. Changing room size
  in JSON also requires adapting the authored decorative floor bounds.
- At camera limits the worker can approach screen edges; control/equipment
  readability and physical multitouch cancellation need user phone feedback.
- Existing save recovery limitations still apply: unreadable/newer saves are
  preserved and automatic writes stop until explicit reset/recovery. Clearing
  Android data or uninstalling may erase local progress; there is no cloud backup.
- No sustained-device FPS, memory, battery or low-end performance claim is made.
- No reference image files were supplied with the transformation text attachment.
