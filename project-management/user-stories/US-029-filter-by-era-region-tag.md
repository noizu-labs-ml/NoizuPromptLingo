---
id: US-029
title: "Filter Graph by Era, Region, or Tag"
slug: "filter-by-era-region-tag"
personas: [P-001, P-004, P-008]
epic: "Knowledge Graph"
priority: "should-have"
complexity: "M"
tags: [knowledge-graph, filter, era, region, tag, metadata]
---

# US-029: Filter Graph by Era, Region, or Tag

## User Story

**As a** epic novelist managing a multi-era fantasy series (P-001),
**I want to** filter the knowledge graph by narrative era, geographic region, or custom tags,
**So that** I can focus on a specific slice of my world's history or geography without switching universes.

## Acceptance Criteria

- [ ] Given the knowledge graph filter panel is open, when I select an era from a dropdown of eras defined in my universe, then only nodes tagged with that era remain visible.
- [ ] Given the knowledge graph filter panel is open, when I select a region, then only nodes associated with that region are displayed.
- [ ] Given the filter panel is open, when I type a tag into a tag search field, then matching nodes are highlighted and non-matching nodes are dimmed.
- [ ] Given multiple filter dimensions are active (era + tag), when the graph updates, then only nodes matching ALL active filters are shown (AND logic).
- [ ] Given filters are active, when I click "Clear All Filters", then the graph returns to its default unfiltered state.

## Notes

Depends on US-026 and US-028. Era and region values are derived from entry metadata — the canon editor must support these metadata fields for filtering to work. Related: US-028.
