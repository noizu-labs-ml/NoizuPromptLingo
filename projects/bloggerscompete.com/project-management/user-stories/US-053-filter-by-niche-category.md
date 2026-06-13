---
id: US-053
title: "Filter Blogs by Niche or Category"
slug: "filter-by-niche-category"
personas: [P-006, P-004]
epic: "Explore & Discovery"
priority: "must-have"
complexity: "S"
tags: [explore, filter, niche, category, discovery]
---

# US-053: Filter Blogs by Niche or Category

## User Story

**As a** blog reader and discoverer (P-006),
**I want to** filter explore results by niche or category,
**So that** I can browse only blogs relevant to my interests without wading through unrelated content.

## Acceptance Criteria

- [ ] Given I am on /explore, when I open the niche filter panel, then I see a list of all available niche categories with post counts
- [ ] Given I select one or more niche tags, when the filter is applied, then only blogs matching at least one selected niche appear in the grid
- [ ] Given multiple niches are selected, when results render, then a filter summary bar shows selected niches with individual remove buttons
- [ ] Given I select a niche filter, when the URL updates, then the active filter is reflected in query params (e.g., `?niche=tech,lifestyle`) for shareability
- [ ] Given I click "Clear all filters," when the action fires, then all active niche filters are removed and the full explore grid is restored

## Notes

Niche taxonomy defined during blog submission. See US-056 for the niche tag cloud visual. Niche filter and keyword search (US-052) must compose correctly — both can be active simultaneously.
