# US-210: Summoning and Minions

**Persona:** Lena — Tabletop RPG player, sighted, editorial, short sessions
**Priority:** P1
**Epic:** Advanced Combat & Tactics

## Story
As Lena, I want to summon combat allies that act with their own AI but respond to my commands so that the summoner playstyle feels like directing a personal warband rather than pressing a damage button with extra steps.

## Acceptance Criteria
- [ ] Summoning abilities create persistent minions for the duration of combat or summon duration; each minion has a stat block accessible via SR
- [ ] Minions act on their own initiative with AI behavior (attack nearest enemy, protect summoner, hold position) configurable via command menu
- [ ] Command menu navigable by keyboard: target specific minion, issue order (Attack, Defend, Hold, Follow), accessible with M key shortcut
- [ ] Minion actions narrated in round summary alongside player and enemy actions; minion name prefixes each action: "Shadow Wolf attacks the Bandit from the flank — 18 damage"
- [ ] Multiple minions managed via a minion roster panel: name, type, HP, current order, position relative to summoner
- [ ] Minion HP tracked in status channel with a compact format: "Minions: Wolf(47/60) Skeleton(22/40)" — updated after each round
- [ ] Summoning resource (soul shards, mana, reagents) displayed in status channel; cost announced before confirmation when summoning
- [ ] When a minion is killed, announced immediately as assertive live region: "Your Shadow Wolf falls" — not buried in round summary

## Notes
Lena thinks in D&D/Pathfinder terms: a summoner is a tactical commander, not just a DPS class. The AI behavior system must be robust enough that minions act sensibly without constant micromanagement — critical for Lena's short sessions where she can't spend all her attention on minion direction. The command menu design should borrow from accessible dropdown patterns; using M as a shortcut keeps it quick. The minion roster panel is the equivalent of a character sheet for the player's summons — Lena will check it between rounds to decide when to retreat a wounded minion or push an aggressive formation. The compact status channel format for multiple minions is a design challenge: it must convey meaningful information without becoming a dense wall of numbers. When a minion dies, the assertive announcement is critical — minion death can change tactical calculations and must not be missed by blind players relying on SR. The summoning resource should use a thematic name (soul shards for necromancers, mana for mages) rather than a generic label.
