---
id: US-020
title: "Entry Templates by Type"
slug: "entry-templates"
personas: [P-002, P-003]
epic: "Canon Editor — Core"
priority: "must-have"
complexity: "M"
tags: [canon, templates, entry-types, structure]
---

# US-020: Entry Templates by Type

## User Story

**As a** veteran game master (P-002),
**I want to** have pre-structured field sets for each entry type (Character, Location, Event, Faction, Object, Concept, Rule),
**So that** every entry in my homebrew world captures the same categories of information and nothing important is accidentally omitted.

## Acceptance Criteria

- [ ] Given I create a new entry of type "Character," when the form opens, then it contains fields: Name (required), Aliases, Species/Race, Age, Affiliation (linked entry, US-022), Biography (rich text, US-021), Status (alive/dead/unknown), and Tags (US-023).
- [ ] Given I create a new entry of type "Location," when the form opens, then it contains fields: Name (required), Region, Type (city/dungeon/wilderness/etc.), Climate, Population, Description (rich text), Notable NPCs (linked entries), and Tags.
- [ ] Given I create a new entry of type "Rule," when the form opens, then it contains fields: Name (required), Scope (world/faction/character), Rule text (rich text), Exceptions, Source, and Tags.
- [ ] Given an admin has published a custom template for a genre, when I create a universe with that genre selected, then the custom template fields are pre-loaded for the relevant entry types.

## Notes

Full field definitions for all 7 entry types (Character, Location, Event, Faction, Object, Concept, Rule) must be specified in a separate technical spec. Custom templates are an admin-level feature (P-006). Related: US-016, US-015.
