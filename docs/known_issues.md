# Known limits — touch/control update on Phase H

- Floating joystick stays centered on the initial touch for one gesture; next
  touch relocates it. Idle/release/cancel/menu/focus loss draws nothing. Buttons
  and management overlays are excluded from movement capture.
- Joystick opacity: base 14%, thumb 32%. Near screen edges part of the ring may
  clip, while movement still uses the exact touch origin and normalized direction.
- Automatic pickup/service/cash checks use current worker position every 150 ms.
  Full hands/shelves and wrong product type retain food; no repeated empty/full
  save spam. Menu/blocked/suspended controls prevent transfer. Worker respawns
  safely on reload; if already near an eligible station it can interact there.
- Schema 8, old upgrades/staff/fries/furniture and financial rules stay intact.
  Immediate transfer saves; production batches five seconds and lifecycle flushes.
  Sudden process kill can lose newest unsaved production; no offline income.
- Burger stocker handles burgers only; player carries fries automatically near
  its stations. Table/two chairs are fixed with two seats, no dining bonus yet.
- Full audio/animation polish, comprehensive lifecycle/release checks remain later
  phases. No measured Android FPS/memory/heat or low-end result is claimed here.
- Exact phone install/runtime observations are recorded in test_report_touch.md;
  scripted touch checks do not replace the user's physical feel/multitouch review.
