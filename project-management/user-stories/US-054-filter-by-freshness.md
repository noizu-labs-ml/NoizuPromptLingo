---
id: US-054
title: "Filter Results by Freshness"
slug: "filter-by-freshness"
personas: [P-003, P-001, P-008]
epic: "Search & Filtering"
priority: "should-have"
complexity: "S"
tags: [search, filter, freshness, recency, date]
---

# US-054: Filter Results by Freshness

## User Story

**As a** research journalist (P-003),
**I want to** filter search results to only sites updated within a specific time window,
**So that** I can find sources that are actively maintained and publishing current content.

## Acceptance Criteria

- [ ] Given the filter panel is open, when I select a freshness window (past 7 days / 30 days / 90 days / 1 year / any time), then results are limited to sites whose last-updated date falls within that window
- [ ] Given a freshness filter is active, when results render, then each listing card displays its last-updated date or relative age
- [ ] Given the "any time" option is selected, when results render, then no date filtering is applied and all matching sites appear
- [ ] Given I combine freshness filter with minimum score filter, when applied, then both constraints are enforced simultaneously
- [ ] Given a freshness filter is set, when I share the URL, then the time window is encoded in URL parameters

## Notes

Freshness data is derived from the AI re-scoring pipeline that periodically re-checks listed sites. The freshness score dimension and the freshness filter are related but distinct — the filter is about when the site was last detected as updated, not just its freshness score. Related: US-053 (score filter), US-055 (results with score display).
