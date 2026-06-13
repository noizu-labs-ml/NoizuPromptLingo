---
id: US-011
title: "View Site Listings Within a Category"
slug: "view-site-listings-in-category"
personas: [P-001, P-003, P-004]
epic: "Site Listings"
priority: "must-have"
complexity: "M"
tags: [listings, category, sites, browsing]
---

# US-011: View Site Listings Within a Category

## User Story

**As a** Research Journalist (P-003),
**I want to** see a paginated list of all approved sites in a category,
**So that** I can scan available sources and decide which ones to visit.

## Acceptance Criteria

- [ ] Given I am on a category page with listed sites, when the page loads, then I see a paginated list of site cards (default 20 per page) each showing name, URL domain, one-line summary, and composite quality score.
- [ ] Given there are more sites than fit on one page, when I reach the bottom of the listing, then pagination controls allow me to navigate to subsequent pages.
- [ ] Given I am viewing site listings, when the page loads, then sites are ordered by composite quality score descending by default.

## Notes

Pagination should support both traditional page controls and infinite scroll as a future enhancement. The default sort by quality score is the core value proposition of the directory — not recency or alphabetical. Connects to US-017 (sorting options).
