---
id: US-078
title: "Filter mockups by date range"
slug: "filter-by-date-range"
personas: [P-002, P-001]
epic: "Search & Discovery"
priority: "should-have"
complexity: "S"
tags: [search, filter, discovery]
---

# US-078: Filter mockups by date range

## User Story

**As a** Product Manager (P-002),
**I want to** filter my mockup library by date range,
**So that** I can review mockups created during a specific sprint or project phase.

## Acceptance Criteria

- [ ] Given I am viewing the mockup gallery, when I set a start and end date in the date range picker, then only mockups created within that range are displayed
- [ ] Given a date range filter is active, when I clear it, then all mockups regardless of creation date are shown
- [ ] Given an end date earlier than the start date, when I attempt to apply the filter, then an inline validation error is shown and the filter is not applied

## Notes

Date filtering applies to the mockup `created_at` timestamp. Preset options (last 7 days, last 30 days, this sprint) should be offered as shortcuts alongside the custom range picker.
