# Roadmap — gameplay transformation

Original numbered Phases 0–3 remain preserved. New A–K phases control expansion.

- A: audit/reuse/backup — completed.
- B: world, worker, joystick, collision, camera, compact HUD — completed.
  Full source published as 1938b5b before starting the next phase.
- C: automatic two-second production, cap/full/resume and local stock — completed
  and published as eb2c606. User authorized continuation.
- D: two-burger carrying, proximity pickup, visible stacks, bounded counter delivery
  and persistent hands/counter — completed and published as e67cd06.
- E: bounded customers, queue, one valid counter sale per customer, cash accrued
  — completed and published as 06ac018.
- F: aggregated proximity cash pickup, atomic wallet transfer, immediate save,
  rollback/retry and floating reward — completed and published as 594ff82.
- G: independent speed/capacity/price upgrades, compact workshop and one visible
  stocker with shared transactions — completed and published as dff71d8.
- H: fries using shared production/transfer/sales, fixed table + two chairs and
  persistent purchases — completed as be2891d.
- User-requested touch patch after H: floating hidden joystick, compact HUD, auto
  pickup/service/cash — completed as b9fc270, phone verification 26a6dd5.
- I: visual/audio/animation and menu refinement — completed, user authorized
  continuation on 22 October. See test_report_phaseI.md.
- J: save/migration/lifecycle and progression verification — completed on
  23 October; 585 automated checks pass, phone checks deferred by user.
- K: candidate preparation authorized on 23 October. Cached draw resources,
  desktop benchmark, unsigned release APK/AAB and policy/signing handoff prepared.
  User explicitly deferred phone measurements and chose unsigned artifacts:
  Android performance/device acceptance and owner signing remain release gates.

At each approved phase: inspect → implement → test/fix → update docs/status →
commit and push to https://github.com/09rakib/MiniShopTycoon → stop for feedback.
The user explicitly requires the push at the end of each future phase. Do not
force-push or discard remote work. See repository_workflow.md.

User authorized K after Phase J with the above deferrals. Stop after publishing
the candidate checkpoint; store upload is not authorized. Keep offline play, no ads/accounts/
servers, and one authoritative pipeline for machine/carried/counter/cash/wallet.
