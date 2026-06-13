---
id: US-021
title: "Character stat modifiers from equipment"
slug: "equipment-modifiers"
personas: [P-001]
epic: "Character System"
priority: "must-have"
complexity: "M"
tags: [character, equipment, modifiers, stats, combat]
---

# US-021: Character Stat Modifiers from Equipment

## User Story

**As an** indie AI game developer (P-001),
**I want to** define stat modifiers on inventory items so that a character's effective stats reflect their equipped gear,
**So that** game mechanics like combat and skill checks operate on the character's actual capabilities rather than base stats alone.

## Acceptance Criteria

- [ ] Given an `Item` with `properties={"modifiers": {"strength": +2, "defense": +5}}` added to a character's inventory, when I call `character.effective_stats["strength"]`, then the value is `character.stats["strength"] + 2`.
- [ ] Given a character with `stats["defense"] = 10` and an equipped shield with `modifiers={"defense": +5}`, when I call `character.effective_stats["defense"]`, then `15` is returned.
- [ ] Given a character with two equipped items each adding `+2` to `strength`, when I call `character.effective_stats["strength"]`, then both modifiers are summed and applied to the base stat.
- [ ] Given `character.stats["strength"]` (base) and `character.effective_stats["strength"]` (with modifiers), when I modify `character.stats["strength"]` directly, then `character.effective_stats["strength"]` reflects the updated base plus all active modifiers.
- [ ] Given an item with a modifier is removed from inventory via `character.inventory.remove()`, when I call `character.effective_stats`, then the removed item's modifiers are no longer applied.
- [ ] Given a stat modifier that would reduce a stat below a schema-defined minimum, when the modifier is applied, then `effective_stats` returns the schema minimum value rather than a negative number.

## Notes

The distinction between `character.stats` (base values) and `character.effective_stats` (base + all active modifiers) is architecturally important — skill checks (US-018) and narrative context (US-022) should use `effective_stats` by default. Item modifiers should also support percentage multipliers (`strength: "x1.5"`) for games with gear scaling. See US-012 for the inventory item model.
