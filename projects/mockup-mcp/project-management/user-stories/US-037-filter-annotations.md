---
id: US-037
title: "Filter Annotations by Author, Status, or Date"
slug: "filter-annotations"
personas: [P-002, P-005, P-007]
epic: "Stakeholder Feedback"
priority: "should-have"
complexity: "S"
tags: [annotations, filtering, search, feedback]
---

# US-037: Filter Annotations by Author, Status, or Date

## User Story

**As a** QA engineer (P-007),
**I want to** filter annotations by author, status, or date range,
**So that** I can focus on feedback relevant to a specific reviewer or review cycle without scrolling through all comments.

## Acceptance Criteria

- [ ] Given the feedback summary panel, when I select a specific author from the filter, then only annotations from that author are shown
- [ ] Given the feedback panel, when I filter by status (open/resolved), then the list and pin visibility update accordingly
- [ ] Given the feedback panel, when I set a date range, then only annotations created within that range are displayed
- [ ] Given multiple active filters, when all are applied simultaneously, then results reflect the intersection of all filter criteria

## Notes

Filter state should persist for the session but reset on page refresh. Active filter indicators should be clearly visible. This feature feeds directly into the export flow (US-038).
