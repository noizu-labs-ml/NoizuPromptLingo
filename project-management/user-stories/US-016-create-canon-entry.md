---
id: US-016
title: "Create a Canon Entry"
slug: "create-canon-entry"
personas: [P-001, P-002, P-003]
epic: "Canon Editor — Core"
priority: "must-have"
complexity: "L"
tags: [canon, entry, create, core]
---

# US-016: Create a Canon Entry

## User Story

**As an** epic novelist (P-001),
**I want to** create a canon entry for any element of my world — character, location, event, faction, object, concept, or rule — from a single unified interface,
**So that** my entire 200-page world bible can live in structured, queryable records rather than scattered documents.

## Acceptance Criteria

- [ ] Given I am in the Canon Editor, when I click "New Entry," then I am presented with a type selector offering: Character, Location, Event, Faction, Object, Concept, Rule.
- [ ] Given I select a type, when the entry form opens, then it displays the type-specific field template (e.g., Character includes: name, aliases, species, affiliation, biography; Location includes: name, region, climate, history).
- [ ] Given I fill required fields (at minimum: name and type) and click "Save," then the entry is created, assigned a unique ID, set to "Draft" status, and appears in the Canon Editor list.
- [ ] Given the entry is saved, when I view the Knowledge Graph, then the new entry appears as a node with the correct type icon and no relationships yet.

## Notes

Depends on US-009 (universe must exist). Type-specific field templates are defined in US-020 (entry templates). Entry status (draft/canon/generated) is covered in US-023. Related: US-017 (edit), US-018 (delete).
