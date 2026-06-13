# US-149: Item and Quest Integration

**Persona:** Jamie — IF enthusiast (26, sighted, narrative quality)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Jamie, I want quest items to be lore-rich objects with narrative weight rather than anonymous inventory tokens so that each artifact I carry tells part of the story — and the game ensures I don't accidentally throw that story away.

## Acceptance Criteria
- [ ] Quest items tagged with `quest_item: true` and associated `quest_ids: [...]` linking them to one or more active quests; tagging applied in the item record, not just quest state
- [ ] Quest items are protected: cannot be dropped, sold to NPCs, listed on auction house, salvaged, or destroyed while the associated quest is active — all such attempts return a narrated refusal: "The ancient key feels important — you resist the urge to sell it."
- [ ] `examine [quest item]` produces lore-rich extended description: the item's role in the quest narrative, its origin, and any context clues — LLM-generated with quest and zone context as input
- [ ] Quest items highlighted in inventory with a distinct label: "[Quest]" marker appears after item name in inventory lists — consistent across all inventory views and accessible to screen readers as a text annotation
- [ ] When a quest completes or fails, quest item protection is lifted: item either transforms (quest reward crafted from the item), is consumed (a ritual burns the artifact), or becomes a keepsake (protection removed, item freely tradeable or keepable as memorabilia)
- [ ] Keepsake quest items (AC-5 final state) have their lore extended with the quest resolution: `examine` shows the completed quest epilogue appended to the item's description
- [ ] Multiple quests can reference the same item type (a "forest mushroom" used in three different quests); the item tracks which specific quest instance is relevant per player
- [ ] Quest items do not trigger low-inventory warnings or auto-sort into containers — they stay where placed by the player; the player's intentional placement is respected

## Notes
The "keepsake" outcome (AC-5) is the feature Jamie will care most about: after completing a long quest chain that required a specific artifact, he wants to keep it as a memento and look at it years later to remember the story. The extended lore showing the quest resolution means the item is a compressed record of the narrative experience.

The lore generated at examine time (AC-3) is one of the most LLM-token-intensive features in the item system: it requires the quest context, the zone context, and the item template as input. Cache this generation per (quest_id, item_template_id) pair — not per player instance, since the lore is quest-level not character-level. Invalidate on quest content updates.

The protection against accidental sale/drop (AC-2) solves a real user experience problem in quest-driven games: nothing is more frustrating than realizing you sold the key to the next area. The protection should be silent — no special UI required, just a narrated refusal that explains why.

Multiple quest references to the same item type (AC-7) is an important edge case: a "forest mushroom" in inventory slot 3 might be quest item for Quest A for Player X and a generic crafting material for Player Y. The protection logic must be per-player, per-quest-state — not per item template.

Quest item examination (AC-3) should also work before the quest is fully underway: if a player picks up an artifact that will trigger a quest when brought to an NPC, the examine output should hint at its significance without spoiling the quest: "Something about this talisman feels significant — perhaps someone in the village would know more."
