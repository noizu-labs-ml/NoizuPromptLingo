# US-250: Guild Alliances & Confederations

**Persona:** Tyler — MMO refugee who wants large-scale clan politics and coordinated power
**Priority:** P1
**Epic:** Advanced Social & Governance

## Story
As Tyler, I want my clan to form formal alliances with other clans — sharing communication channels, coordinating wars, and conducting diplomacy — so that large-scale player politics becomes as deep as the individual combat system.

## Acceptance Criteria
- [ ] Alliance proposals initiated by clan leader via `/alliance propose [clan-name] [terms]`; terms are a text field (200 chars) describing the alliance intent (mutual defense, trade, non-aggression); receiving clan leader gets notification with proposal text and options: Accept, Decline, Counter-propose
- [ ] Accepted alliances create a shared Alliance channel visible to all members of all allied clans; channel name defaults to the alliance name (set at proposal); channel is a full ARIA live region with same SR support as clan chat
- [ ] Alliance panel accessible via `/alliance panel` shows: alliance name, member clans list with online counts, shared war declarations, active diplomatic status with other alliances; navigable as structured list
- [ ] Alliances can declare war on other alliances (not individual clans) via `/alliance war [alliance-name]`; requires approval from all allied clan leaders within 24 hours; war declaration narrated as world news event
- [ ] During war state: members of warring alliances are flagged as combatants in PvP-enabled zones; kill/death records tracked at alliance level and displayed in war summary: `/alliance war status` shows kill totals per clan, top combatants, war duration
- [ ] Confederations: alliances may confederate (alliance of alliances) via mutual agreement; confederations share a broadcast channel (one-way announcements from confederation leadership) but not full chat; maximum 3 levels of nesting (clan → alliance → confederation)
- [ ] Dissolution: any allied clan leader can propose alliance dissolution; if majority of allied clan leaders agree within 48 hours, alliance dissolves; pending wars are resolved by GM arbitration; shared channel archived and accessible to former members for 7 days
- [ ] Alliance diplomatic status with other alliances tracked as: War, Hostile, Neutral, Friendly, Allied; displayed in alliance panel; NPC faction system (US-247) recognizes alliance diplomatic status when calculating faction reputation for member clans

## Notes
The three-tier hierarchy (clan → alliance → confederation) mirrors real political structures without being so deep that it becomes opaque. The key design constraint: each tier has diminishing communication bandwidth. Clans have full chat; alliances have full chat; confederations have broadcast-only (leader speaks, members listen). This prevents a 500-player confederation from having an unusable chat channel while preserving the political significance of confederation membership.

The war declaration mechanics need to prevent griefing. Requiring all allied clan leaders to approve a war declaration means one hot-headed clan leader can't drag an entire alliance into a conflict. The 24-hour approval window respects Tyler's concern about real-time coordination — his allies in different time zones need time to weigh in.

Alliance war kill tracking is the key hook for Tyler. He wants to see numbers — his clan's contribution to the war effort, how the alliance is performing against the enemy. The war summary should be a leaderboard navigable by screen reader: "Alliance War Summary: Iron Brotherhood Alliance vs. Merchant Council Alliance. Day 3. Iron Brotherhood: 142 kills, 89 deaths. Top killer: Marcus (23 kills)."

The NPC faction integration (US-247) is a meaningful depth addition. If Tyler's alliance is at war with the Merchant Council alliance, and the Merchant Council is allied with the Merchant League NPC faction, the NPC faction AI should recognize this and potentially embargo Tyler's alliance's trade routes. This creates geopolitical texture that rewards players who engage with both systems.

Anti-griefing: alliances cannot declare war on alliances with average player level 30+ levels below theirs (prevents large alliances farming small ones for war points). War declarations also require a minimum PvP activity threshold — alliances that have been dormant for 14+ days cannot be war declared against; they must first re-engage with the world.
