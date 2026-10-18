# Phase status — 18 October 2026

Current checkpoint: **Transformation Phase B — movement foundation implemented.**

## Existing project preserved

- Original Phases 0–3: Godot 4.7.2 project, ten-product grocery economy,
  stockroom, upgrades, XP/levels, goals and versioned local saves.
- Source backup created before changing the entry point:
  builds/backups/phase3-before-world.zip (946,065 bytes). Prior APKs retained.
- New scene and scripts are additive. Previous grocery gameplay remains under
  Menu. Its only code change is an embedded-mode Android Back guard.
- Save schema remains 3; no reset/conversion or new currency source introduced.

## Completed transformation work

- Phase A: inspected scripts, scenes, economy, upgrades, persistence and tooling;
  documented audit/reuse/risks/architecture in docs/transformation_audit.md.
- Phase B: original elevated 2D shop; controllable chef; joystick; normalized
  motion; walking/facing; static collision walls, machine, counter and props;
  bounded smooth camera; compact wallet/level HUD and management overlay.
- Controls clear on release/cancel/pause/focus loss and menu entry. Keyboard/mouse
  support desktop development; Android uses the joystick.
- New world disables old automatic grocery sales unless explicitly entering the
  preserved grocery shop. Returning does not reload the new world.
- 128 previous regression checks plus 34 new world checks pass (162 total).
- Actual rendered scene captures inspected at 480×900, 360×640 and 480×1040.

## Android build and current work

- Built builds/MiniShopTycoon-phaseB.apk, v0.4.0/code 4, 57,682,656 bytes.
- Verified APK v2/v3 signatures, Android 7.0 minimum, target SDK 36, ARMv7/ARM64
  and absence of requested permissions. Same package identity and debug key.
- Installed/started on vivo V2405A; actual screen inspected and two joystick
  smoke-test gestures performed. Prior 129 coins and level 2 remained visible.
- Real viewport-routed joystick press/drag/release checks pass; physical input
  comfort, multitouch and sustained phone play still await user confirmation.
- User requested GitHub upload before continuing, then automatic commit/push at
  every subsequent phase checkpoint. Repository: github.com/09rakib/MiniShopTycoon.

## Awaiting user testing

- Joystick comfort, responsiveness, diagonal movement and immediate stopping.
- Machine/counter/wall collision and camera framing on the portrait phone.
- Dragging outside joystick, second-finger input, Home/resume and Android Back.
- Preserved grocery data and return from management without movement resets.
- Airplane mode and several minutes of use; report clipping, lag or tight paths.
- Exact instructions: docs/testing.md. STOP before Phase C until approved.

## Pending transformation phases

C production; D carrying/delivery; E customers/sales; F cash pickup; G machine
upgrades/employees; H more machines/furniture; I polish; J save verification;
K measured Android performance and release preparation. None implemented early.
The new A–K roadmap supersedes pending numbered phases for future development.

## Known limits

- Machine/counter/cash tray are positioned fixtures, not working burger systems
  yet. No fake pickup button, generated sale or immediate wallet increase added.
- Worker position intentionally respawns on relaunch; existing business progress
  remains persisted. No walking-triggered disk writes.
- Camera limits and original raised 2D artwork are lightweight; no measured FPS,
  memory/battery or low-end performance result is claimed.
- Physical multitouch, cancellation, lifecycle and sustained play need user QA.
- Reference images were not present in the supplied attachment; written design
  directed the original visuals. See docs/known_issues.md.
