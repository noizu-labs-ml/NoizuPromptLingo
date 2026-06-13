---
id: US-052
title: "Filter Search Results by Category"
slug: "filter-by-category"
personas: [P-001, P-003, P-008]
epic: "Search & Filtering"
priority: "must-have"
complexity: "S"
tags: [search, filter, category, facets]
---

# US-052: Filter Search Results by Category

## User Story

**As a** research journalist (P-003),
**I want to** filter my search results by category,
**So that** I can narrow broad keyword results to the domain I am actually researching.

## Acceptance Criteria

- [ ] Given search results are displayed, when I open the category filter panel, then all top-level categories are shown with match counts
- [ ] Given I select a category filter, when the filter is applied, then results are narrowed to only listings within that category or its subcategories
- [ ] Given multiple categories are available as filters, when I select more than one, then results matching any selected category are shown (OR logic)
- [ ] Given a category filter is active, when I clear it, then the full unfiltered result set is restored without re-executing the search
- [ ] Given a search with category filter is active, when I share the URL, then the filter state is preserved in the URL parameters

## Notes

Category filter facets should show counts in real time so users can predict result set size before clicking. Works in combination with score and freshness filters (US-053, US-054). Related stories: US-051 (keyword search), US-053 (score filter).
