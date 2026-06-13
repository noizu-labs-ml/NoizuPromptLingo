# US-150: Item Economy Balancing Tools

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P2
**Epic:** Item Framework & Equipment

## Story
As Dave, I want an admin dashboard with item distribution metrics, trade volumes, and economy health alerts so that I can detect and correct inflation, scarcity, and crafting imbalances before they damage the player experience.

## Acceptance Criteria
- [ ] Dashboard displays: total item counts by rarity tier (all items in the world: in inventories, containers, listings, escrow), crafting event counts by recipe over a rolling 7-day window, and AH trade volumes by item type
- [ ] Inflation metric: tracks average AH sale price per item type over 7/30/90-day windows; flags items where 7-day average has risen more than 25% vs. 30-day baseline
- [ ] Scarcity metric: flags item types where player-held supply has dropped below a configurable minimum threshold; useful for detecting loot table misconfiguration or over-aggressive sinking
- [ ] Most-crafted and least-crafted recipe rankings, updated daily; least-crafted recipes (0 crafts in 30 days) are highlighted as candidates for rebalancing or removal
- [ ] Economy health alerts: automated alerts fire when inflation, scarcity, or drop-rate anomalies exceed defined thresholds — delivered to admin via server notification and optionally via webhook (configurable endpoint)
- [ ] All charts rendered as accessible data tables alongside any visual representation: trade volume chart is accompanied by a table with columns (date, item_type, volume, avg_price); screen reader users access the data table; sighted users get both
- [ ] Historical trend data retained for at least 90 days; queryable via an admin CLI command for custom date ranges: `economy report --item "iron longsword" --from 2024-01-01 --to 2024-03-31`
- [ ] Dashboard access gated to admin role; all dashboard queries read from a read replica or materialized view to avoid impacting game server performance

## Notes
Dave's sysadmin background means he will want the admin CLI (AC-7) more than the web dashboard. The CLI command should output clean, tabular text that can be piped to tools like `awk`, `sort`, or `grep`. Pipe-friendliness is a quality indicator for sysadmin tools.

The inflation threshold (AC-2) of 25% rise in 7 days is a default starting point — different items have different natural price volatility. Rare crafting materials during a seasonal event will spike legitimately. The threshold should be configurable per item type, and the admin should be able to suppress alerts for known legitimate spikes.

The least-crafted recipe report (AC-4) is the continuous balancing signal: if a recipe has never been crafted in 30 days, either the output item is not valuable, the ingredients are too expensive, the required skill is too high, or the recipe is simply unknown to players. Each of these has a different solution, and the admin needs additional context to distinguish them. The report should include: recipe discovery count (how many players know it), average skill level of players who know it, and ingredient cost estimate from AH prices.

The economy audit log schema (shared with US-138 and US-143) is the data source for all these metrics. The schema must support efficient aggregation queries by item_type, event_type, timestamp range, and player_id. Index design is critical — without proper indexes, these queries will be expensive on a live server.

The accessible data table requirement (AC-6) applies to all dashboards in the game, not just this one. Establishing this pattern here creates a reusable component: a `<economy-chart>` web component that renders both a visual chart and a hidden-but-accessible data table simultaneously, with a toggle for screen-reader users to promote the table to primary view.
