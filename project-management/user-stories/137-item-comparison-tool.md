# US-137: Item Comparison Tool

**Persona:** Marcus — Blind power gamer (28, NVDA+Firefox, PvP)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Marcus, I want a screen-reader-optimized item comparison that announces stat differences in plain language so that I can make gear decisions at competitive speed without mental arithmetic.

## Acceptance Criteria
- [ ] Comparison triggered from any item context: inventory, shop, loot screen, auction house — the command `compare [item]` or a keyboard shortcut opens the comparison view
- [ ] Comparison output format for screen readers: each differing stat announced as a delta — "+5 attack, -2 dodge, +1 strength vs. your current iron longsword" — rather than two parallel stat blocks requiring mental subtraction
- [ ] Stats that are equal between items are suppressed in the comparison summary (available via `compare verbose` for full breakdown)
- [ ] Implicit slot is inferred: if the item being compared fits the currently-equipped slot, comparison is against that slot's item automatically; if multiple slots could apply (ring), player is prompted to choose
- [ ] Comparison available between two arbitrary items (neither equipped): `compare [item A] with [item B]` for shop browsing or auction house research
- [ ] Enchantments and set memberships included in comparison: "current item has Fire Damage +10 / new item has no enchantments" and "new item is part of Ashwarden's Plate [you own 1 of 5]"
- [ ] Comparison respects item identification state: unidentified items compare as their generic description — "unknown properties vs. current iron longsword"
- [ ] Comparison results persist in a scrollback buffer for at least 5 minutes so that Marcus can return to the comparison after exploring a different item

## Notes
The delta format (AC-2) is the core insight: screen reader users should not have to hold two numbers in working memory and subtract them. The system does the math; the user hears the verdict. This is a first-class accessibility feature, not an afterthought.

Suppressing equal stats (AC-3) is important for efficiency. If comparing two swords where everything except attack power is identical, announcing all 12 stats is noise. The verbose mode exists for completeness, but the default should be optimized for decision speed.

The enchantment comparison (AC-6) requires the comparison engine to treat enchantments as a first-class comparable dimension, not just a text note. If current item has fire damage and new item does not, that is a real DPS difference that should be quantified if possible (estimated DPS contribution from enchantment).

Scrollback buffer (AC-8): Marcus may be mid-combat or navigating quickly. A comparison he ran 3 minutes ago should still be accessible without re-running it. Store the last 5 comparison results in the session, accessible via `compare history`.

This feature should be usable entirely via keyboard commands, with no requirement to navigate a UI panel. Command-line-first design is the correct approach for both the MUD veteran (Dave) and the power gamer (Marcus).
