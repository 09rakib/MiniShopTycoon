# Roadmap — gameplay transformation

Original numbered Phases 0–3 remain preserved. New A–K phases control expansion.

- A: audit/reuse/backup — completed.
- B: world, worker, joystick, collision, camera, compact HUD — completed.
  Full source published as 1938b5b before starting the next phase.
- C: automatic two-second production, cap/full/resume and local stock — completed
  and published as eb2c606. User authorized continuation.
- D: two-burger carrying, proximity pickup, visible stacks, bounded counter delivery
  and persistent hands/counter — current tested checkpoint. Stop before E.
- E: bounded customers, queue, one valid counter sale per customer, cash accrued.
- F: aggregated cash pickup with atomic transfer to wallet and safe save.
- G: real machine upgrades and one reliable employee type.
- H: further machine content and fixed valid furniture placement.
- I: visuals/audio/animation and mobile refinement.
- J: comprehensive save/migration/lifecycle and progression verification.
- K: measured Android performance, final AAB/release and current policy checks.

At each approved phase: inspect → implement → test/fix → update docs/status →
commit and push to https://github.com/09rakib/MiniShopTycoon → stop for feedback.
The user explicitly requires the push at the end of each future phase. Do not
force-push or discard remote work. See repository_workflow.md.

Only D was authorized after the Phase C checkpoint. Stop before E until the user
approves or explicitly requests continuation. Keep offline play, no ads/accounts/
servers, and one authoritative pipeline for machine/carried/counter/cash/wallet.
