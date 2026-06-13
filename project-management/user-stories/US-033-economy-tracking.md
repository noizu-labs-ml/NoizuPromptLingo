---
id: US-033
title: "Resource and economy tracking"
slug: "economy-tracking"
personas: [P-001]
epic: "World State Manager"
priority: "should-have"
complexity: "M"
tags: [world-state, economy, resources, trading]
---

# US-033: Resource and Economy Tracking

## User Story

**As a** indie AI game developer building a survival RPG (P-001),
**I want to** define world-level resources with supply/demand quantities per location, and track transactions between entities,
**So that** the game economy is a live data layer that the Narrative Engine can reference when describing market conditions, scarcity, and trade opportunities.

## Acceptance Criteria

- [ ] Given a resource definition `{"id": "iron", "name": "Iron Ore", "unit": "kg"}`, when I call `world.economy.register_resource(resource)`, then it is stored and queryable.
- [ ] Given a location with registered supply data, when I call `world.economy.set_supply(location_id, resource_id, quantity=500)`, then `world.economy.get_supply(location_id, resource_id)` returns `500`.
- [ ] Given a transaction `{"from": location_A, "to": location_B, "resource": "iron", "quantity": 50}`, when I call `world.economy.transact(transaction)`, then supply at A decreases by 50 and supply at B increases by 50 atomically.
- [ ] Given a transaction that would reduce supply below zero, when I call `world.economy.transact(transaction)`, then an `InsufficientSupplyError` is raised and no quantities are modified.
- [ ] Given a resource with supply below a configurable `scarcity_threshold`, when context is assembled for a location, then a `scarcity` flag and current supply level are included in the location's context payload.

## Notes

Economy data enables P-001 to build trading, crafting, and survival mechanics grounded in world state. The Narrative Engine can use scarcity signals to color NPC dialogue without additional configuration. Integrates with US-035 (world event triggers) to fire events on economic thresholds.
