# Phase status — 27 October 2026

Current checkpoint: **Retired version removed — v0.14.0/code 16**.
User explicitly asked to delete old-version navigation and the old version itself.

- Removed all three retired menu entries, legacy overlay/loading/back paths, old
  scenes/screens, grocery renderer/customer loop, icon loader and ten product icons.
- Removed old Game buy/sell/shelf-upgrade/running/level-up UI entrypoints and capture.
- Menu now contains only current shop, sound, burger machine/stocker and expansion.
- Current burger/fries gameplay and schema 1–8 save compatibility remain; updating
  preserves coins, food inventories, staff and purchased upgrades/furniture.
- 567 checks pass (deleted-feature checks removed, current menu guard added), clean
  regression logs. Save migration and current gameplay checks remain.
- New menu inspected at 480×900 and 360×640. APK/AAB audits verify no retired content
  ships and reject the previous APK; native/content/signature/alignment checks pass.
- Builds: MiniShopTycoon-v0.14.0.apk, and unsigned APK/AAB candidates. See
  docs/test_report_current_only.md and docs/artifacts_current.json for evidence.

Commit/push all source deletions, tests and docs; verify remote hash. APKs and caches
stay local/ignored. Prior phone/signing deferrals persist; no install, key generation
or store upload was performed. Last verified phone build is still v0.11.0/code 12.
Install the new debug APK without uninstalling to update the phone's menu.
