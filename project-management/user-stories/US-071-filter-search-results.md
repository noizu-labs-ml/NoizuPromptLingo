---
id: US-071
title: "Filter Search Results by Type, Tag, and Era"
slug: "filter-search-results"
personas: [P-001, P-002, P-003, P-004, P-005, P-008]
epic: "Search & Discovery"
priority: "must-have"
complexity: "M"
tags: [search, filters, type, tag, era, facets]
---

# US-071: Filter Search Results by Type, Tag, and Era

## User Story

**As a** webcomic creator (P-008),
**I want to** filter search results by entry type, tag, and era,
**So that** I can narrow 500+ entries down to, for example, "all characters in the Sunken Age tagged as antagonist" without scrolling through unrelated results.

## Acceptance Criteria

- [ ] Given a search returns results, when I apply a type filter (e.g., "Characters only"), then the results list updates immediately to show only entries of the selected type, and the result count badge reflects the filtered total.
- [ ] Given a search returns results, when I apply one or more tag filters, then only entries carrying all selected tags are shown (AND logic by default), with an option to switch to OR logic via a toggle.
- [ ] Given a universe uses eras or time periods, when I apply an era filter, then only entries associated with or active during the selected era are returned.
- [ ] Given multiple filters are active, when I clear all filters, then the full unfiltered result set for the original query is restored in one action, without re-submitting the search.

## Notes

Depends on US-069 (full-text search). Filters should be applied client-side for speed when result sets are small (<500 entries), and server-side for larger universes. Related: US-072 (search result previews).
