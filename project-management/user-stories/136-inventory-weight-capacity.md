# US-136: Inventory Weight and Capacity

**Persona:** Marcus — Blind power gamer (28, NVDA+Firefox, PvP)
**Priority:** P0
**Epic:** Item Framework & Equipment

## Story
As Marcus, I want my inventory weight tracked with accessible screen-reader views and encumbrance penalties narrated in combat so that weight management is a real strategic constraint I can optimize — not invisible friction.

## Acceptance Criteria
- [ ] Each item has a weight in grams (integer); total carried weight tracked as a running sum updated on every inventory change
- [ ] Four encumbrance tiers with defined weight thresholds (configurable by admin, defaults scale with Strength stat): Unencumbered, Burdened (movement -10%, stamina drain +10%), Heavy (movement -25%, stamina drain +25%, dodge penalty), Overloaded (cannot run, cannot dodge, stamina drain each round)
- [ ] Encumbrance tier change announced immediately via ARIA live region (assertive): "You are now Burdened — movement slowed." Tier improvement also announced.
- [ ] Inventory view supports sorting by: weight (heaviest first), value, type, name — sort preference persists across sessions; sort is announced to screen reader on change
- [ ] `weight` command returns: current total weight, carrying capacity, encumbrance tier, and the five heaviest items with their individual weights
- [ ] Picking up an item that would cause Overloaded state requires explicit confirmation: "Picking up this [iron ingot × 20] (8kg) will leave you Overloaded. Confirm?"
- [ ] Combat events narrate encumbrance penalties when relevant: "You try to sidestep the blow, but your pack weighs you down — the sword catches your arm."
- [ ] Strength increases (level-up, buff, equipment) recalculate carrying capacity and may announce tier improvement: "Your newfound strength lifts your burden — you are Unencumbered."

## Notes
Marcus will immediately determine the optimal weight budget for his PvP loadout: enough gear for survival without hitting Burdened. The `weight` command (AC-5) must be fast — he will use it constantly during pre-PvP inventory management.

The five heaviest items in the `weight` command output is specifically useful for screen reader navigation: rather than reading through 40 items to find what to drop, Marcus can immediately see his top offenders and make decisions. This is a targeted accessibility optimization for heavy inventory users.

Weight thresholds scaling with Strength stat means a high-Strength warrior can carry full plate armor without encumbrance, while a robed mage with the same loot haul is immediately Burdened. This is the correct physical intuition.

The combat narration for encumbrance (AC-7) requires the narrative engine to receive encumbrance tier as a combatant property. Dodge-related events should check encumbrance and modify their prose template selection accordingly. This is a relatively simple context addition.

Containers (US-145) interact with weight: items inside a bag still contribute their weight to total carried weight. A bag itself has its own weight. The weight system should sum recursively through the container hierarchy.
