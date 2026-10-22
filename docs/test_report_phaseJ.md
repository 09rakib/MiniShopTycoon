# Phase J verification — 23 October 2026

Scope: durable state, migrations, recovery/reset, failed transactions, progression
and simulated application lifecycle. Economy format remains schema 8. No reset or
migration is required for existing v0.11.0 players; no offline income was added.

## Findings and fixes

- LocalSave previously fell back from an unsupported future save to an older
  backup, permitting a later downgrade overwrite. Any encountered newer-schema
  candidate now blocks writes and preserves original files.
- load_into now clears old blocked/message state before a fresh recovery attempt.
- Reset formerly renamed originals and reset live state before confirming the
  replacement could be written. It now prepares/flushed fresh progress, copies
  archives, commits the primary and only then resets live state. A missing folder
  or archive conflict leaves live and primary progress intact. Successful reset
  removes old backup/temp candidates; bounded before-reset archives remain.
- Food transfers and customer sales formerly returned success after a failed save.
  They now restore food/cash/sale ledgers and unpaid tickets before returning failure.
  Player and staff carrying remain intact. Grocery buy/sell/upgrade mutations also
  roll back wallet, stock, expense, tier and XP fields on write failure.
- Successful transactions still use the same synchronous accounting and immediate
  save paths. Controller objects retain their references; presentation does not
  award stock/money and no success cue is emitted for a rejected write.

## Automated results

Godot 4.7.2, headless, eleven suites. Existing 509 checks pass unchanged. New
run_lifecycle_tests.gd passes 76 checks, giving **585 checks, zero failures**.
Final logs contain no SCRIPT ERROR, engine ERROR or WARNING. test.cmd includes
the new suite. The final lifecycle suite was rerun after adding the journey test;
no runtime source changed after the full regression run.

Coverage includes schema 1–8 disk migrations/roundtrips, every nested schema-8
record rejecting malformed data without partial mutation, corrupt-primary backup
recovery, valid temporary recovery, future-schema protection, clearing stale load
errors, reset archive conflict/destination failure, reset persistence and retained
sound preference. Failures use blocked storage and unavailable/conflicting paths;
they do not emulate every possible hardware/filesystem failure.

Game-level checks cover failed burger/fries/staff transfer, failed customer sale
with unpaid ticket restored, failed grocery transactions and shelf purchase,
successful retry without duplicate sale, old timestamp without offline rewards,
level/objectives/capacity restoration. Twenty real Game transaction journeys each
reload from disk while carrying, then deliver, sell and collect: final wallet 900,
20 sales, revenue 400, zero food/cash/tickets left. Lifecycle checks inject pause,
resume and focus notifications into actual controllers, validate pause disk flush,
no paused production/automatic transfer, open-menu retention and fresh-touch resume.

## Android artifact

- `builds/MiniShopTycoon-phaseJ.apk`, debug v0.12.0/code 13.
- Package `com.minishoptycoon.offlinegame`, min SDK 24, target 36.
- ARMv7 + ARM64, portrait, allowBackup false, no app permissions.
- 57,777,373 bytes.
- SHA256 `B8BDE28ECD9F7B015CB682CD79DA821AFBCDA786F114EAE594C3102745D4489F`.
- apksigner v2/v3 verifies; aapt metadata/manifest/permissions inspected.

ADB found no attached device. User explicitly chose to defer phone checks and
finish APK/GitHub. This APK has **not** been installed on the phone. Last verified
device version remains Phase I v0.11.0/code 12. No claim of physical force-kill,
real low-storage testing or measured Android performance is made.

## Deferred physical acceptance

Update without uninstalling. With both foods/staff/upgrades/furniture and sound
off, Home/resume and relaunch while carrying, after service and after cash pickup.
Verify exact saved inventories, coins and pending cash with no replayed customer
payment. Unsaved production can lose up to the existing five-second batch on an
abrupt process kill; no offline catch-up is intended. Confirm reset/cancel only on
disposable test progress. Phase K performance/release remains separately pending.
