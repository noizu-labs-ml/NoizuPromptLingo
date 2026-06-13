---
id: US-090
title: "Skeleton Loading States"
slug: "skeleton-loading-states"
personas: [P-002, P-006, P-008]
epic: "Performance & Scale"
priority: "could-have"
complexity: "S"
tags: [performance, skeleton-loading, ux, perceived-performance]
---

# US-090: Skeleton Loading States

## User Story

**As an** AI Newcomer (P-008) or Content Creator (P-006),
**I want to** see skeleton placeholder screens while content loads,
**So that** the page feels responsive and I understand that content is on its way rather than assuming the page is broken.

## Acceptance Criteria

- [ ] Given a user navigates to the main feed, when the initial data fetch is in progress, then a set of at least 5 skeleton prompt card placeholders is shown in place of the real cards
- [ ] Given a user navigates to a prompt detail page, when the prompt is loading, then a skeleton layout matching the approximate shape of the detail view (title block, body block, metadata row, comment blocks) is shown
- [ ] Given skeleton screens are displayed, when they render, then they use an animated shimmer effect to communicate active loading (not static grey boxes)
- [ ] Given content loads in under 300ms (e.g., from cache), when the data arrives before the skeleton animation completes its first cycle, then the skeleton is replaced immediately without flashing

## Notes

Skeletons should closely approximate the visual weight of the real content to minimize layout shift (CLS). Skeleton components can be reused across feed and detail views with minor configuration. The 300ms threshold prevents visible skeleton flashes on fast connections — consider using a minimum display time of 200ms if data arrives sooner.
