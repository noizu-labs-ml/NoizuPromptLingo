---
id: US-017
title: "Sort Site Listings"
slug: "sort-listings"
personas: [P-003, P-001, P-002, P-008]
epic: "Site Listings"
priority: "should-have"
complexity: "S"
tags: [sorting, listings, quality-score, freshness, date-added]
---

# US-017: Sort Site Listings

## User Story

**As a** Research Journalist (P-003),
**I want to** sort site listings by quality score, freshness, or date added,
**So that** I can find the most authoritative sites or the newest additions depending on my research needs.

## Acceptance Criteria

- [ ] Given I am viewing a category listing, when I open the sort control, then I can select from: "Top Rated" (composite score), "Freshest" (last content update), and "Recently Added" (date added to directory).
- [ ] Given I select a sort option, when the page updates, then the listing re-orders without a full page reload and the active sort is visually indicated.
- [ ] Given I share the URL after sorting, when another user opens it, then they see the same sort order (sort state reflected in URL params).

## Notes

Default sort is "Top Rated" to surface the highest quality sites first. "Freshest" is useful for P-003 who needs current sources. "Recently Added" serves P-008 (Community Curator) tracking new submissions. Connects to US-011 (listings) and US-012 (score breakdown).
