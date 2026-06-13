---
id: US-100
title: "Game Engine Export (Structured Schemas)"
slug: "game-engine-export"
personas: [P-002, P-003, P-007]
epic: "Export & Integration"
priority: "could-have"
complexity: "L"
tags: [export, game-engine, integration, api, structured-data, developer]
---

# US-100: Game Engine Export (Structured Schemas)

## User Story

**As a** game master or narrative designer integrating lore into a game engine or custom toolchain (P-002, P-003, P-007),
**I want to** export universe data in structured schemas compatible with game engines or importable via API,
**So that** my canonical worldbuilding data can drive in-game systems, procedural narrative, and NPC dialogue without manual re-entry.

## Acceptance Criteria

- [ ] Given I am on Universe Settings > Export, when I select "Game Engine Schema" and choose a target format (Generic JSON-LD, RPG Systems Schema, or Custom), then I receive a structured output file with entity types, attribute definitions, and typed relationships.
- [ ] Given I select "RPG Systems Schema," when the export completes, then character entries include fields mapped to common RPG stat blocks (name, class, abilities, affiliations) and location entries include region, climate, and faction control fields.
- [ ] Given I have an API key (US-082), when I call `GET /api/v1/universes/{id}/export?format=game-engine`, then I receive the same structured schema as the UI export in an API response with appropriate `Content-Type` and schema version headers.
- [ ] Given I define a custom export mapping in the Export settings (e.g., map "Character.alignment" → "npc_alignment"), when I run the export, then the output file uses my custom field names.
- [ ] Given the export schema is versioned, when I access the developer docs at `/docs/export-schema`, then I can view the full schema definition, changelog, and example output for each supported format.

## Notes

Depends on US-099 (Markdown/JSON/PDF export) for the base export infrastructure. Depends on US-082 (API key management) for programmatic access. The initial release should focus on Generic JSON-LD; RPG Systems Schema and custom mappings are follow-on features. Related: P-007 (Nova, AI Agent) workflows that consume exported data.
