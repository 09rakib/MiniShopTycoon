# Known limits — transformation Phase C

- Machine production is active and capped at ten. Player pickup/carrying is Phase
  D, so the full machine has no player-facing drain yet. Resume-on-removal is
  implemented/tested through the shared bounded inventory primitive.
- New customer queue sales, uncollected cash and wallet pickup are Phases E/F.
  Machine upgrade buying/employees/furniture remain later phases. Configured
  upgrade tiers do not imply purchasable upgrades in this checkpoint.
- The original grocery economy remains under Menu and is independent of burger
  production. Producing a burger never increases wallet, sales or XP.
- Five-second batched saves plus lifecycle flushes preserve machine stock.
  Unnotified abrupt termination may lose up to five seconds of new production.
  Partial timer progress is restarted; no offline production/catch-up is granted.
- Schema 4 migrates compatible prior data. Do not downgrade to earlier APKs after
  migration. Uninstalling/clearing data can erase local progress; no cloud backup.
- Worker position still respawns at a safe location. Room artwork is authored for
  the checked-in layout; changing its dimensions also needs decorative-art edits.
- Prior unreadable/newer save preservation/recovery policies remain unchanged.
- No sustained FPS, low-end, battery, memory or airplane-mode result is claimed.
