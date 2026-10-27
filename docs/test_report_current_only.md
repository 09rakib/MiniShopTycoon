# Remove the retired version — 27 October 2026

User request: delete the option to enter the old game and remove that old version.
Current build is v0.14.0/code 16, package com.minishoptycoon.offlinegame.

## Removed

- Previous grocery shop, Inventory • grocery, Shelf upgrades & goals menu entries.
- Legacy overlay/scene loading, return navigation and associated lifecycle branches.
- main/inventory/upgrades scenes and screen scripts, old ShopView renderer,
  ShopCustomers simulation, ProductIcons loader and ten SVG product icons/imports.
- Game's retired buy/sell/shelf-upgrade/level-up/running interface and old UI capture.

Current menu keeps Back to the shop, Sound, Burger machine & stocker and New
machines & furniture. Burger/fries production, carrying, automatic service/cash,
staff, upgrades, furniture and sound remain. No retired UI code is simply hidden.
The persistent economy/validation model retains schema 1–8 fields for compatible
loading; no existing wallet or food-shop progress is reset by this cleanup.

## Verification

| Suite | Passed |
| --- | ---: |
| Economy/save compatibility | 92 |
| World/current navigation | 35 |
| Production | 32 |
| Handling | 44 |
| Customers | 39 |
| Cash | 34 |
| Operations | 69 |
| Expansion | 50 |
| Touch | 29 |
| Polish | 50 |
| Lifecycle | 73 |
| Resource bounds | 10 |
| Android setup | 10 |
| Total | 567 |

All pass, with no errors/warnings in the final regression logs. Previous total
605 drops by 36 deleted UI/icon checks and three deleted grocery Game-action
checks, with one new retired-menu check added. Save/migration/accounting tests
remain. World tests verify the deleted scene/entrypoint/menu labels, current
workshop input blocking and preserved player/wallet. Resource tests now cycle the
current workshops instead of opening removed overlays.

Current menu rendered and inspected at 480×900 and 360×640 (current-menu previews
beside this report). No retired global script classes remain in the imported cache.

APK/AAB audit now rejects retired scenes/scripts/icons, including remapped/compiled
script variants. It accepts all v0.14.0 outputs and deliberately rejects the previous
v0.13.1 APK as a guard check. ZIP CRC, excluded/private content and ARM64 ELF 16KB
alignment checks pass. Bundletool validation runs in the AAB build wrapper and
passes. Debug APK v2/v3 signature verifies; unsigned release APK zipalign passes.
Manifest checks confirm v0.14.0/code 16, SDK 24/36, ARMv7/ARM64 and no permissions.

Debug APK is the update-compatible install artifact. Unsigned APK/AAB are owner
signing candidates. Phone installation/testing remains deferred per prior user
instruction; last verified phone build is still v0.11.0. Install this update without
uninstalling to see the cleaned menu on the phone while preserving progress.
Signing and store/device acceptance gates remain unchanged.

Exact final sizes/hashes: artifacts_current.json. Historical reports remain as
development history and do not describe the current menu.
