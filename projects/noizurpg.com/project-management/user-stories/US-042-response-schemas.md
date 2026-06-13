---
id: US-042
title: "Define response schemas per interaction type"
slug: "response-schemas"
personas: [P-001, P-003]
epic: "Narrative Engine"
priority: "should-have"
complexity: "M"
tags: [narrative-engine, schemas, structured-output, interaction-types]
---

# US-042: Define Response Schemas per Interaction Type

## User Story

**As a** AI/ML researcher studying structured LLM outputs (P-003),
**I want to** define response schemas per interaction type (exploration, combat, dialogue, puzzle) that specify required fields and optional narrative sections,
**So that** LLM responses are consistently structured for each context and game logic can reliably extract fields without brittle prompt engineering.

## Acceptance Criteria

- [ ] Given a schema definition for `"exploration"` with required fields `["narrative", "exits"]` and optional `["items_visible", "npc_present"]`, when I call `engine.register_schema("exploration", schema)`, then it is stored and associated with the interaction type.
- [ ] Given a registered schema, when `engine.generate(action, interaction_type="exploration")` is called, then the LLM is prompted to return a response conforming to that schema's structure.
- [ ] Given an LLM response for a schematized interaction, when `engine.validate_response(response, interaction_type="exploration")` is called, then a `SchemaValidationResult` is returned with `valid=True/False` and a list of missing or unexpected fields.
- [ ] Given no schema registered for a given interaction type, when `engine.generate()` is called with that type, then generation proceeds without schema constraints and a `NoSchemaWarning` is logged.
- [ ] Given a schema with a field marked `required=True`, when the LLM response omits that field, then `SchemaValidationResult.valid` is `False` and the field name is listed in `missing_fields`.

## Notes

Response schemas complement US-041 (event parsing) by structuring the narrative wrapper, not just embedded events. P-003 uses schemas to ensure reproducible output structures for experimental analysis. The schema registry should be serializable for inclusion in world snapshots (US-031).
