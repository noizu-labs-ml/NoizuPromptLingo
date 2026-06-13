# US-139: Item Crafting Recipes

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P0
**Epic:** Item Framework & Equipment

## Story
As Dave, I want a recipe-driven crafting system with discoverable recipes and an accessible recipe book so that crafting mastery is a deep progression path I can research and optimize — not just a menu of known items.

## Acceptance Criteria
- [ ] Recipes stored in a recipes table: each has a name, required ingredients (item_id + quantity), required skill level, required tool type, output item, and discovery method
- [ ] Discovery methods: experimentation (successfully combining ingredients reveals the recipe), NPC hint (quest or paid dialog), lore scroll (dropped item containing recipe), and admin-granted (for tutorial/starter recipes)
- [ ] Failed experimentation: attempting to combine ingredients with no matching recipe consumes ingredients and produces a narrated failure — "The iron ore and pine timber do not combine — the wood scorches and splits."
- [ ] Recipe book (in-game `recipes` command): lists known recipes organized by category (weapons, armor, consumables, components); each entry shows required ingredients, skill level, and output item name
- [ ] Unknown recipe slots are shown in the recipe book as "???" with a discovery hint: "This recipe may be revealed by a skilled alchemist" — visible only if the player has enough skill to potentially learn it
- [ ] Crafting session narrated: "You set the iron ingots on the anvil, raise the hammer, and work the metal for what feels like an hour. The shape slowly emerges." — duration and prose vary by recipe complexity
- [ ] All crafting interactions fully keyboard navigable and screen-reader compatible: ingredient selection, recipe browsing, and crafting confirmation all via command-line syntax (`craft [recipe name] using [materials]`)
- [ ] Recipe data editable by admin without code deploy; new recipes added to config take effect on server reload; malformed recipe entries are logged as warnings and skipped

## Notes
Experimentation-based discovery (AC-2) is the high-engagement mechanic for Dave: he will systematically attempt combinations and document results. Failed attempts consuming ingredients provides a gold sink and limits trivial experimentation at scale. Consider a small chance of partial success (a low-quality version of the desired item) on near-miss combinations to make experimentation feel rewarding even when imperfect.

The recipe book's "???" display for unknown-but-learnable recipes (AC-5) is a directed discovery system: it tells players they're missing something without telling them what. The discovery hint should be specific enough to give direction ("may be revealed by a skilled alchemist in Ashford") without removing the journey.

Crafting session narrative (AC-6) is where the LLM earns its cost: a simple sword recipe should produce generic smith prose, but a complex enchanted weapon recipe should produce something specific and evocative. The LLM receives: recipe name, ingredients, output item, player location, and player crafting skill level as context.

The `craft [recipe] using [materials]` command syntax (AC-7) allows batch crafting: `craft iron shortsword using iron ingot, iron ingot, hickory handle × 5` should attempt to craft 5 swords in sequence if materials allow, narrating each one.

Recipe data should be versioned: if a recipe is changed (ingredient requirements adjusted), existing known recipes in players' recipe books should update to reflect the new requirements. The recipe_id is the stable key; the requirements are mutable.
