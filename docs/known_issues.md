# Known limits — Phase K candidate

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
- Audio/presentation polish is complete; human tone/volume review and comprehensive
  lifecycle/release checks remain. No measured Android FPS/memory/heat or low-end
  result is claimed. Four reusable effects/voices can replace older feedback.
- Headless tests use a silent sound sink; actual playback was exercised in the
  desktop polish test. Persistent audio preference is separate from economy saves.
- Exact phone install/runtime observations are recorded in test_report_touch.md;
  scripted touch checks do not replace the user's physical feel/multitouch review.
- Phase I artifact/device results are recorded in test_report_phaseI.md.
- Phase J fixes save/reset/transaction failure paths and passes 585 checks. Phone
  Home/relaunch/force-kill and actual low-storage checks were deferred by the user;
  this version has not been installed. See test_report_phaseJ.md. Automated blocked
  storage tests do not emulate every operating-system or filesystem failure.
- Phase K phone measurements/16KB runtime, low-end thermal/memory and signed store
  acceptance remain deferred. Desktop benchmark is not Android FPS evidence.
- Unsigned candidates cannot be installed directly. Keep the debug APK for the
  existing debug phone app; use owner signing for release. No key was generated.
- v0.13.1 resolves the old API compatibility/manifest/strip warnings through a
  pinned prepared toolchain. Future Gradle 10 Groovy DSL deprecations and the
  template's experimental path-check notice remain. See release_preparation.md;
  structural validation alone does not establish production readiness.
