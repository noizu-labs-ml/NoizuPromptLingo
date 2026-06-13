---
id: US-099
title: "Loading Skeleton States"
slug: "loading-skeleton-states"
personas: [P-001, P-004, P-006]
epic: "Performance & Scale"
priority: "could-have"
complexity: "S"
tags: [performance, UX, loading, skeleton, perceived-performance]
---

# US-099: Loading Skeleton States

## User Story

**As a** user on a slow connection loading the leaderboard or blog feed (P-006),
**I want to** see placeholder skeleton screens while content loads,
**So that** the page feels responsive and I understand the layout before data arrives, instead of staring at a blank screen.

## Acceptance Criteria

- [ ] Given I navigate to the leaderboard page, when data is being fetched, then skeleton placeholder cards matching the approximate dimensions of real leaderboard rows are displayed in place of content.
- [ ] Given I navigate to the blog discovery page, when the initial blog list is loading, then skeleton cards (mimicking blog card layout: image placeholder, title bar, tag chips) are displayed for the expected number of results per page (20 items).
- [ ] Given the AI score page is loading a blog's score breakdown, when the fetch is in progress, then skeleton placeholders are shown for the radar chart area, each score dimension bar, and the overall score badge.
- [ ] Given a skeleton state is displayed, when `prefers-reduced-motion: reduce` is not set, then the skeleton uses a subtle shimmer/pulse animation to indicate loading activity.
- [ ] Given `prefers-reduced-motion: reduce` is active (US-097), when skeleton states are shown, then they are static (no shimmer animation) but still displayed as placeholders.
- [ ] Given data loads successfully, when the fetch resolves, then skeleton components are replaced with real content without layout shift (Cumulative Layout Shift score impact < 0.1 for the transition).
- [ ] Given a skeleton state has been visible for more than 10 seconds (indicating a hung request), when the timeout is reached, then the skeleton is replaced with an error state: "Something took too long to load — [Retry]."

## Notes

Skeleton components should match actual content dimensions closely to minimize layout shift. Shimmer effect implemented via CSS `@keyframes` on a gradient background-position. Timeout/error state prevents infinite loading confusion. Relates to US-098 (infinite scroll — uses skeletons for "next page" loading), US-097 (reduced motion).
