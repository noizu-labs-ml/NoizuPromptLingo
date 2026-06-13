# US-134: Item Sets and Set Bonuses

**Persona:** Tyler — MMO refugee (22, sighted, growth/clans)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Tyler, I want to collect matching equipment sets and earn escalating bonuses so that gear hunting has a long-term goal structure and my clan can coordinate around shared set targets.

## Acceptance Criteria
- [ ] Sets defined in config: each set has a name, a list of 2–6 member items, and a bonus schedule (2-piece bonus, 4-piece bonus, full set bonus)
- [ ] Set membership is stored on each item: item description includes set name and set piece identifier ("Ashwarden's Plate — Chest [2 of 5]")
- [ ] Set progress is tracked in real time: equipping a set piece announces current progress via ARIA live region (polite): "You now wear 2 pieces of Ashwarden's Plate. Set bonus active: +8% fire resistance."
- [ ] Losing a set piece (unequip, destruction) immediately recalculates and announces the bonus loss: "Ashwarden's 2-piece bonus lost."
- [ ] `sets` command displays all in-progress sets: for each set, the pieces equipped and the pieces missing, with missing pieces listed by name for targeted farming
- [ ] Set comparison view for screen reader users: list format showing each slot — "Helm: Ashwarden's Crown [equipped] / Chest: Ashwarden's Plate [equipped] / Legs: Ashwarden's Greaves [missing]"
- [ ] Set bonuses are narrated in combat where relevant: a full-set fire resistance bonus should cause fire damage events to produce "the Ashwarden's blessing deflects the worst of the flames"
- [ ] Clan members can share their set progress; a `roster sets` command shows which set pieces clan members are missing, facilitating coordinated farming runs

## Notes
Tyler's MMO background means he will immediately treat set bonuses as his primary gear goal. The `roster sets` command (AC-8) is the clan coordination feature that makes sets a social activity rather than a solo grind.

Set bonus prose in combat (AC-7) requires the narrative engine to know which set bonuses are active on the combatant. The combat event should carry the active-set-bonus list as context. Not every combat event needs set bonus prose — only those where the bonus is directly relevant (fire damage when fire resistance is the bonus, etc.).

For screen reader users (Marcus, Elena), the set progress ARIA announcements must be polite (not assertive) so they don't interrupt combat narration. The user can query set progress at any time via the `sets` command without waiting for an equip event.

Sets that span item types (weapon + armor + jewelry) require the player to acquire pieces from different content types: a weapon from a boss drop, armor from a dungeon chest, a ring from a crafted recipe. Designing sets this way creates natural play variety rather than grinding one content type for an entire set.

The config-driven set definition means new sets can be added as content updates without code deploys. Validate that all items referenced in a set config actually exist in the item database on startup.
