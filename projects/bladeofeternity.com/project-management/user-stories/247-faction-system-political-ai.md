# US-247: Faction System & Political AI

**Persona:** Tyler — MMO refugee seeking clan-scale politics, persistent impact, and strategic depth
**Priority:** P1
**Epic:** Advanced Social & Governance

## Story
As Tyler, I want NPC factions with AI-driven political behavior — forming alliances, waging trade wars, shifting allegiances based on player actions — so that the political landscape feels alive and my clan's decisions have real consequences on the world stage.

## Acceptance Criteria
- [ ] World contains 6–12 named NPC factions, each with defined attributes: economic focus, military strength, diplomatic disposition, controlled territories, and relationships with other factions (alliance/neutral/hostile); all readable via `/faction info [name]`
- [ ] Faction AI evaluates world state on a configurable tick (default: every 2 in-game days): resource imbalances trigger trade offers, military disparity triggers alliance proposals, persistent player hostility triggers war declarations
- [ ] Player actions accumulate faction reputation: completing faction quests, trading with faction merchants, fighting faction enemies increases standing; attacking faction members, trading with rivals, or completing rival quests decreases standing
- [ ] Reputation tiers unlock access: Unfriendly (hostile NPCs), Neutral (basic services), Friendly (faction shop discounts), Honored (faction-exclusive quests), Exalted (faction titles, unique items, political influence)
- [ ] Faction panel accessible via `/faction panel` presents: current standings with all factions as a list (faction name, standing tier, standing points), active world events (ongoing wars, trade deals, diplomatic shifts), player's active faction quests
- [ ] All faction events narrated as world news in a dedicated channel: "The Merchant League has declared an embargo against the Iron Brotherhood, effective at dawn. Trade routes through the northern pass are disrupted."
- [ ] Clan-level faction influence: clan leaders can formally pledge their clan to a faction, granting bonus reputation gains for all members and unlocking clan-faction joint operations; pledge is public and visible to rival factions
- [ ] AI faction behavior is inspectable by GMs via admin panel showing faction decision logs with reasoning; GMs can override faction decisions or inject events via the event scripting engine (US-257)

## Notes
The political AI needs to be driven by actual world-state data, not random events. If the Iron Brotherhood has been losing territory for three sessions because Tyler's clan keeps raiding their caravans, the AI should detect this military weakness and have the Merchant League propose an alliance with them — because economically, a weakened Brotherhood is a liability. This causal chain is what makes the world feel real.

The faction AI architecture recommendation: a lightweight OTP GenServer per faction, evaluating state on each tick. Each faction server holds its current attributes, relationship scores with other factions (numeric, ±1000 range), and a queue of pending events. A global FactionSupervisor coordinates multi-faction events (wars require two factions, trade deals require two factions). This keeps the computation distributed and fault-tolerant.

Transparency matters for player trust: players should be able to understand *why* a faction is hostile to them. `/faction explain Iron Brotherhood` should produce: "Your standing with the Iron Brotherhood is Unfriendly (−320 points). Primary causes: 3 caravan raids (−450), 1 completed faction quest (+100), selling weapons to the Brotherhood's enemies (−80) — wait this is actually an interesting idea for dynamic discovery of causes." The faction panel should be navigable by screen reader as a flat list with faction names as headings and standing details as list items under each.

Clan pledge is a major decision — irreversible for 30 real days. The confirmation dialog should be explicit about consequences: rival factions will treat pledged clans as extensions of the faction they've aligned with. This forces Tyler's clan into a genuine political identity.

Watch for faction event spam: if the political AI generates too many events, the world news channel becomes noise. Rate-limit faction announcements to maximum 3 per in-game day, prioritizing the highest-impact events. Archive older announcements in a searchable log: `/faction history`.
