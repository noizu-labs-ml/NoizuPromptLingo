---
id: US-053
title: "Filter by Minimum Quality Score"
slug: "filter-by-minimum-score"
personas: [P-003, P-007, P-008]
epic: "Search & Filtering"
priority: "should-have"
complexity: "S"
tags: [search, filter, score, quality, api]
---

# US-053: Filter by Minimum Quality Score

## User Story

**As a** research journalist (P-003),
**I want to** filter search results by a minimum quality score,
**So that** I only see sites that meet a baseline standard of originality, depth, and human authorship.

## Acceptance Criteria

- [ ] Given search results are displayed, when I set a minimum overall score (e.g., 70/100), then only listings meeting or exceeding that threshold are shown
- [ ] Given the score filter, when I interact with it, then a slider or numeric input is available in the filter panel alongside a label showing the current threshold
- [ ] Given a minimum score filter is set, when results are returned, then score badges on each card visually confirm the site meets the threshold
- [ ] Given I set score filters on individual dimensions (originality, depth, freshness, human authorship, design), when applied, then they compound with AND logic
- [ ] Given a score filter is active, when I share the URL, then the filter threshold is preserved in URL parameters

## Notes

Per-dimension score filters are a power-user feature likely needed by P-007 (API Developer) and P-008 (Community Curator). Overall score filter is sufficient for P-003. Related stories: US-051 (keyword search), US-054 (freshness filter).
