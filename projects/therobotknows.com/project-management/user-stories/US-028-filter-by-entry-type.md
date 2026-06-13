---
id: US-028
title: "Filter Graph by Entry Type"
slug: "filter-by-entry-type"
personas: [P-001, P-003, P-008]
epic: "Knowledge Graph"
priority: "must-have"
complexity: "M"
tags: [knowledge-graph, filter, entry-type, visualization]
---

# US-028: Filter Graph by Entry Type

## User Story

**As a** narrative designer coordinating a writing team (P-003),
**I want to** filter the knowledge graph to show only specific entry types,
**So that** I can isolate character networks or location maps without visual noise from unrelated entry categories.

## Acceptance Criteria

- [ ] Given the knowledge graph is displayed, when I open the filter panel, then I see toggles for each entry type present in the universe (character, location, event, faction, object, concept, rule).
- [ ] Given I deactivate a filter toggle, when the graph updates, then all nodes of that type are hidden and their edges are hidden or collapsed.
- [ ] Given multiple types are hidden, when I activate a hidden type's toggle, then only that type's nodes reappear — other hidden types remain hidden.
- [ ] Given filters are applied, when I reload the page, then filter state persists for the current session.
- [ ] Given all type filters are deactivated, when I view the canvas, then an informational message indicates no entry types are selected.

## Notes

Depends on US-026. Filter state persistence across sessions (not just page reload) is a could-have enhancement. Related: US-029 (filter by era/region/tag).
