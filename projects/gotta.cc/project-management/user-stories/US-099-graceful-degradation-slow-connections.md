---
id: US-099
title: "Graceful Degradation on Slow Connections"
slug: "graceful-degradation-slow-connections"
personas: [P-004, P-001]
epic: "Accessibility & Performance"
priority: "could-have"
complexity: "M"
tags: [performance, resilience, progressive-enhancement, ux, mobile]
---

# US-099: Graceful Degradation on Slow Connections

## User Story

**As a** Casual Link-Follower (P-004),
**I want to** still be able to browse and read listings even on a slow or unreliable connection,
**So that** I am not stuck staring at a spinner when my signal drops mid-browse.

## Acceptance Criteria

- [ ] Given a user is on a slow connection (effective connection type `slow-2g` or `2g` via Network Information API), when a category page loads, then non-critical resources (score charts, thumbnail images, badge animations) are deferred or omitted in favor of fast text content delivery
- [ ] Given a page partially loads before the connection drops, when the user scrolls to already-loaded content, then previously rendered listings remain interactive and readable
- [ ] Given an API call for dynamic content (e.g., score data) times out, when the timeout is reached, then the page shows a "Score data unavailable — try refreshing" message in place of the score section rather than a blank panel or JS error
- [ ] Given the user's browser does not support JavaScript, when they visit a category page, then the core listing information (title, URL, description, text score) is still visible via server-rendered HTML
- [ ] Given the site is in an offline or cached state via a service worker, when the user navigates to a previously visited page, then the cached version is served with a banner indicating it may not be current

## Notes

Progressive enhancement is the design philosophy here — HTML is the baseline, CSS is the enhancement, JS is the enrichment. Server-side rendering of listing data is essential for both performance and no-JS fallback. Service worker caching is a stretch goal but provides significant value for repeat visitors on mobile. See US-098 (mobile responsiveness) for skeleton loading patterns.
