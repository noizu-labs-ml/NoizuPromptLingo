---
id: US-012
title: "Add inventory items with properties"
slug: "inventory-management"
personas: [P-001]
epic: "Character System"
priority: "must-have"
complexity: "S"
tags: [character, inventory, items, properties]
---

# US-012: Add Inventory Items with Properties

## User Story

**As an** indie AI game developer (P-001),
**I want to** add items with custom properties to a character's inventory and query them,
**So that** the game can track what characters are carrying and use that information in narrative generation and game logic.

## Acceptance Criteria

- [ ] Given a `Character` object, when I call `character.inventory.add(Item(name="Iron Sword", properties={"damage": 8, "type": "weapon", "weight": 5.0}))`, then `character.inventory.count` increments by 1 and the item is retrievable by name.
- [ ] Given a character inventory containing an "Iron Sword", when I call `character.inventory.get("Iron Sword")`, then the returned `Item` object exposes `item.properties["damage"]` as `8`.
- [ ] Given a character inventory, when I call `character.inventory.filter(type="weapon")`, then the returned list contains only items where `properties["type"] == "weapon"`.
- [ ] Given a character inventory, when I call `character.inventory.remove("Iron Sword")` on an item that exists, then `character.inventory.count` decrements by 1 and a subsequent `get("Iron Sword")` raises `ItemNotFoundError`.
- [ ] Given a character inventory, when I call `character.inventory.remove("Nonexistent Item")`, then `ItemNotFoundError` is raised with the item name in the message.
- [ ] Given a character with items in inventory, when I call `character.to_dict()`, then the inventory items and all their properties are included in the serialized output.

## Notes

Items are a key element of Blade of Eternity-style games where equipment drives both narrative and mechanics. The `properties` dict must be open-ended to support arbitrary game-specific metadata (rarity, enchantments, durability). See US-021 for stat modifiers derived from equipment and US-015 for full character serialization.
