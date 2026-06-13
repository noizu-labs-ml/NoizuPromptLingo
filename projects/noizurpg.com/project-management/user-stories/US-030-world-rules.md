---
id: US-030
title: "Define world rules as constraints"
slug: "world-rules"
personas: [P-001, P-006]
epic: "World State Manager"
priority: "must-have"
complexity: "M"
tags: [world-state, rules, constraints, validation]
---

# US-030: Define World Rules as Constraints

## User Story

**As a** game studio lead overseeing AI content quality (P-006),
**I want to** define enforceable world rules as named constraints (e.g. "magic does not work in the Dead Zone", "NPCs cannot own property"),
**So that** LLM-generated narrative output can be validated against these constraints before being shown to players, preventing world-breaking inconsistencies.

## Acceptance Criteria

- [ ] Given a rule definition with `id`, `description`, and a callable `validator(world_state, event) -> bool`, when I call `world.add_rule(rule)`, then it is stored and applied during validation passes.
- [ ] Given a proposed world event that violates a registered rule, when I call `world.validate_event(event)`, then the result contains `valid=False` and a list of violated rule IDs with their descriptions.
- [ ] Given a proposed event that satisfies all registered rules, when I call `world.validate_event(event)`, then `valid=True` is returned with an empty violations list.
- [ ] Given a rule marked `severity="warning"`, when a violation is detected, then validation returns `valid=True` with the violation listed under `warnings` rather than blocking the event.
- [ ] Given a rule defined as a YAML constraint expression (for non-Python authors), when the framework parses it, then it is compiled into an equivalent validator callable without manual Python code.

## Notes

This story is foundational for US-043 (validate LLM output against world rules). P-006 requires this for production deployments where uncontrolled LLM output could break game state. Rules should be introspectable for documentation and debug tooling.
