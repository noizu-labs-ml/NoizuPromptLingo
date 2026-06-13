---
id: US-035
title: "World event triggers"
slug: "world-event-triggers"
personas: [P-001, P-003]
epic: "World State Manager"
priority: "should-have"
complexity: "L"
tags: [world-state, events, triggers, automation]
---

# US-035: World Event Triggers

## User Story

**As a** AI/ML researcher studying emergent narrative (P-003),
**I want to** define conditional triggers that fire world events when specific state conditions are met,
**So that** the world evolves autonomously in response to player actions and state changes without requiring imperative scripting for every scenario.

## Acceptance Criteria

- [ ] Given a trigger definition `{"condition": "faction_relation(A, B) < -0.8", "event": "war_declared", "once": True}`, when I call `world.add_trigger(trigger)`, then the trigger is stored and evaluated on each state mutation.
- [ ] Given a registered trigger whose condition evaluates to `True` after a state mutation, when `world.evaluate_triggers()` is called, then the associated event is fired and recorded on the timeline.
- [ ] Given a trigger marked `"once": True` that has already fired, when its condition becomes True again, then the trigger does NOT fire a second time.
- [ ] Given a trigger marked `"once": False`, when its condition is continuously True over three consecutive ticks, then the event fires once per tick (not deduplicated).
- [ ] Given a trigger that fires an event, when that event's handler mutates world state, then triggers are re-evaluated after the mutation (with cycle detection to prevent infinite loops, capped at configurable `max_trigger_depth`).
- [ ] Given a trigger with an invalid condition expression, when it is added via `world.add_trigger()`, then a `TriggerSyntaxError` is raised at registration time, not at evaluation time.

## Notes

This is a large story due to the condition evaluation engine and cycle-detection requirements. P-003 uses trigger systems to study emergent behavior patterns. Relates to US-028 (faction system), US-029 (timeline), and US-033 (economy tracking) as trigger condition sources.
