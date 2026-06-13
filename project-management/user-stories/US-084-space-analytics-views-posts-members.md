---
id: US-084
title: "Space Analytics (Views, Posts, Member Count Over Time)"
slug: "space-analytics"
personas: [P-003, P-007]
epic: "Spaces - Advanced"
priority: "could-have"
complexity: "L"
tags: [spaces, analytics, metrics]
---

# US-084: Space Analytics (Views, Posts, Member Count Over Time)

## User Story

**As a** Startup Founder (P-007),
**I want to** view analytics for spaces I own showing views, post volume, and member growth over time,
**So that** I can understand community engagement and growth patterns.

## Acceptance Criteria

- [ ] Given I am a space owner, when I visit the space analytics dashboard, then I see charts for: daily unique visitors, thread posts, and member count over the last 30 days
- [ ] Given I select different time ranges (7 days, 30 days, 90 days), when I apply the filter, then charts update to show data for the selected period
- [ ] Given I view the daily visitors chart, when I hover over a data point, then I see the exact visitor count for that date
- [ ] Given I'm not a space owner, when I try to access the analytics dashboard, then I see an error message "Only space owners can view analytics"
- [ ] Given the space is new with minimal data, when I view analytics, then the system shows message "Not enough data to display analytics"

## Notes

Analytics should be computed daily. Member count chart shows net member changes (joins minus leaves). Privacy: no PII included in analytics data.