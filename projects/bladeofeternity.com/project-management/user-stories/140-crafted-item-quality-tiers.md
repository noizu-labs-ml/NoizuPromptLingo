# US-140: Crafted Item Quality Tiers

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Dave, I want crafted items to emerge with quality tiers determined by skill, materials, and tools so that mastering a craft is a meaningful achievement with measurable output — and masterwork items are genuinely exceptional.

## Acceptance Criteria
- [ ] Five quality tiers: poor, standard, fine, masterwork, legendary — each applies a proportional multiplier to all item stats (poor: 0.75×, standard: 1.0×, fine: 1.15×, masterwork: 1.35×, legendary: 1.6×)
- [ ] Quality determined by a weighted formula: crafter skill level (40% weight), material grade (30%), tool tier (20%), and a variance roll (10%) — formula configurable by admin
- [ ] Legendary craft quality is exceptionally rare: requires max skill, finest materials, master-tier tools, and a critical success on the variance roll (probability < 2%); each legendary craft announced server-wide
- [ ] Item name reflects quality tier: "poor iron shortsword," "fine iron shortsword," "masterwork iron shortsword of the Ember Forge" (masterwork and above receive a generated epithet)
- [ ] The epithet on masterwork+ items is LLM-generated from: crafter name, material, output item type, and location — "of the Ashford Forge," "Tempered by Vera Coldhand," "The Ember-Kissed"
- [ ] Quality tier announced on crafting completion: "Your work is done — you hold a fine iron shortsword, its balance better than you expected."
- [ ] Quality multipliers apply to: attack/defense values, durability (max_durability scaled), enchantment capacity (poor: 0 slots, standard: 1, fine: 1, masterwork: 2, legendary: 3), and sell value
- [ ] Crafter's name is embedded in the item's metadata: `examine [item]` reveals "Crafted by Dave Ironhollow" — this persists through all future owners

## Notes
The crafter's name on the item (AC-8) is a social feature: a well-known master smith's items are recognizable. This creates emergent player reputation — buyers will seek out items crafted by known masters. This requires crafter name to be immutable on the item record even if the player renames their character.

The server-wide legendary craft announcement (AC-3) is intentional social pressure: it draws attention to top crafters and creates status incentives. However, it should only fire for character-crafted legendaries — admin-granted items should not trigger the announcement.

The epithet generation (AC-5) is a light LLM cost per masterwork item. Given that masterwork craft probability is relatively low, the total token budget for this feature is manageable. Cache the epithet once generated — do not regenerate on each examination.

Quality multiplier applying to durability (AC-7) means a legendary-quality item has 1.6× the base max_durability of a standard item. This interacts well with the repair system: legendary-quality items are worth repairing carefully because their max_durability is precious.

The variance roll (10% weight in the formula) should use a seeded RNG tied to the craft event timestamp + player_id, not a pure random call. This ensures the outcome is deterministic and auditable: if a player disputes a quality outcome, the result can be reproduced from the seed.
