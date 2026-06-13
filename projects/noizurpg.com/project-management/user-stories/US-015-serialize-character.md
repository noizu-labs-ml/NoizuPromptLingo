---
id: US-015
title: "Serialize character to JSON/YAML"
slug: "serialize-character"
personas: [P-001, P-006]
epic: "Character System"
priority: "must-have"
complexity: "S"
tags: [character, serialization, json, yaml, persistence]
---

# US-015: Serialize Character to JSON/YAML

## User Story

**As an** indie AI game developer or game studio lead (P-001, P-006),
**I want to** serialize a fully-populated `Character` object to JSON or YAML and deserialize it back to an identical object,
**So that** I can persist game state between sessions and integrate character data with external tools and pipelines.

## Acceptance Criteria

- [ ] Given a `Character` object with stats, inventory, relationships, and knowledge populated, when I call `character.to_json()`, then the output is a valid JSON string containing all populated fields with no data loss.
- [ ] Given a `Character` object, when I call `character.to_yaml()`, then the output is a valid YAML string that round-trips correctly through `Character.from_yaml()` producing an object equal to the original.
- [ ] Given a JSON string produced by `character.to_json()`, when I call `Character.from_json(json_string)`, then the reconstructed `Character` object has `character.stats`, `character.inventory`, `character.relationships`, and `character.knowledge` all equal to the original object's values.
- [ ] Given a `Character` serialized with NoizuRPG version `1.0`, when I deserialize it with NoizuRPG version `1.1` (with a non-breaking schema change), then the deserialization succeeds and new optional fields are populated with their default values.
- [ ] Given a malformed JSON string passed to `Character.from_json()`, then a `CharacterDeserializationError` is raised with a descriptive message identifying the parse failure location.

## Notes

Serialization is the foundation for save/load (US-016), import/export (US-009), and any external tooling that Aisha's studio (P-006) might build on top of NoizuRPG. The YAML format should be human-readable and manually editable — studio designers should be able to tweak character YAML directly without running Python. Schema versioning must be embedded in the serialized output.
