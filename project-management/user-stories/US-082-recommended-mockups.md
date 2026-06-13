---
id: US-082
title: "Recommended mockups based on recent activity"
slug: "recommended-mockups"
personas: [P-002, P-004]
epic: "Search & Discovery"
priority: "should-have"
complexity: "M"
tags: [recommendations, discovery, personalization]
---

# US-082: Recommended mockups based on recent activity

## User Story

**As a** Product Manager (P-002),
**I want to** see mockup recommendations based on my recent activity,
**So that** I can discover relevant templates and past mockups without actively searching.

## Acceptance Criteria

- [ ] Given I have generated at least 3 mockups, when I visit the dashboard, then a "Recommended for you" section shows up to 6 relevant templates or similar past mockups
- [ ] Given I have no prior activity, when I visit the dashboard, then the recommendations section shows curated starter templates instead
- [ ] Given I dismiss a recommendation, when I return to the dashboard, then the dismissed item is no longer shown and a replacement is offered

## Notes

Initial recommendation logic can be based on mockup type frequency and tag overlap (no ML required). A simple collaborative-filter or content-based heuristic is sufficient for v1. Relates to US-080 (public gallery as recommendation source).
