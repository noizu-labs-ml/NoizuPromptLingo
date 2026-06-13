# US-138: Loot Tables and Drop Rates

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Dave, I want configurable loot tables with rarity tiers and a pity timer system so that loot feels fair and I can tune drop rates in response to economy conditions without pushing code.

## Acceptance Criteria
- [ ] Loot tables defined in config (YAML/JSON): each enemy, chest, and zone event references a named loot table; tables specify items by rarity tier with weighted probabilities
- [ ] Five rarity tiers: common (gray), uncommon (green), rare (blue), epic (purple), legendary (gold) — each tier has a base drop probability range and a narrative flourish on drop: "The bandit captain's final breath escapes... and from his belt a blue shimmer catches your eye."
- [ ] Loot table config changes take effect within 60 seconds of file write without server restart; server polls config file hash and reloads on change
- [ ] Pity timer: each player accumulates a counter per loot source type (dungeon boss, elite mob, zone chest) that increments on non-legendary drops and guarantees a legendary drop at a configurable threshold (default: 50 non-legendary drops)
- [ ] Pity counter is per-player, per-source-type, and persists across sessions; visible to the player via `luck` command as a vague narrative hint: "Fortune seems close — your luck feels ready to turn."
- [ ] Multiple items can drop simultaneously; each resolved independently from the loot table; total drop narrated as a single scene: "The chest yields: a leather jerkin (common), two iron ingots, and — unexpectedly — a silver amulet that catches the torchlight."
- [ ] Zone-wide drop rate modifiers supported (e.g., weekend event +25% rare drop chance for zone X); applied as a multiplier on the base table, configurable per zone with start/end timestamps
- [ ] Loot table audit log: every drop recorded with (player_id, source_id, item_id, rarity, timestamp) for economy analysis and drop rate validation

## Notes
Dave's sysadmin instincts mean he will want to query the audit log (AC-8) directly from a database console. The log schema should be clean and indexed on source_id and rarity so he can run ad-hoc queries like "how many legendary drops from the Lich King in the last 7 days."

The 60-second hot reload (AC-3) is important for live events: if a Halloween event needs a 2x drop rate for the next 4 hours, Dave should be able to push that config change without scheduling downtime. The server must handle the reload gracefully (finish current loot resolution with old table, start next with new).

The pity timer narrative hint ("Fortune seems close") should have multiple levels: vague for low pity, slightly more direct for high pity ("Your luck feels overdue"). This gives players a sense of progress toward their guaranteed drop without revealing the exact threshold.

Multiple simultaneous drops (AC-6) should have a configurable maximum per event to prevent absurd loot explosions from high-drop-rate configs. Default cap: 5 items per event. Excess items are silently discarded (not a player-facing event).

The audit log is the data source for the economy balancing dashboard (US-150). The two systems should share schema design from the start.
