# US-205: Ranged Combat Mechanics

**Persona:** Marcus — Blind power gamer, NVDA+Firefox, PvP focused
**Priority:** P1
**Epic:** Advanced Combat & Tactics

## Story
As Marcus, I want to use bows, crossbows, and thrown weapons with meaningful range and line-of-sight mechanics so that positioning and ammunition management add a tactical layer to ranged combat that rewards mastery.

## Acceptance Criteria
- [ ] Ranged weapons have defined short/medium/long range bands with accuracy and damage modifiers announced when targeting: "Long range — accuracy reduced 30%"
- [ ] Line-of-sight computed by physics engine from player position to target; obstructions narrated: "The pillar blocks your shot — move left for a clear angle"
- [ ] Cover mechanics: targets behind partial cover get damage reduction; cover status included in target description: "Goblin Archer (partial cover — wooden crate)"
- [ ] Ammunition tracked as a resource in the status channel: "Arrows: 12" updated after each shot; quiver empty state announced assertively
- [ ] Low ammunition warning triggered at 25% capacity: "Only 3 arrows remain" inserted into status channel without interrupting SR flow
- [ ] Thrown weapons (daggers, javelins) retrieved from corpses or environment; retrieval announced in post-combat summary
- [ ] Reloading crossbows costs an action; announced in player's turn notification so they can plan accordingly
- [ ] Range to each valid target listed in targeting menu so Marcus can select optimal target given current position

## Notes
Marcus's power-gamer orientation means he will optimize ranged builds. The system must reward this by making range and LoS genuinely matter — not cosmetic labels. Physics engine LoS computation should use the same spatial model as the environmental system (US-206) so that cover is consistent whether used offensively or defensively. Ammunition economy is a resource management layer Marcus will appreciate; the status channel display must be always-visible without requiring a menu open. The frustration point for blind ranged players is not knowing why a shot missed — was it range, cover, or just bad luck? The narration must distinguish these: "Your arrow deflects off the crate — the goblin is well-covered" vs "At this distance, your arrow wobbles and misses wide" vs "The goblin sidesteps your shot." NVDA users can configure verbosity; the game should use standard ARIA patterns that work at all verbosity levels.
