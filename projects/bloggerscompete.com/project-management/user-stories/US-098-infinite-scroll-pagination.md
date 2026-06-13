---
id: US-098
title: "Infinite Scroll Pagination"
slug: "infinite-scroll-pagination"
personas: [P-006, P-001]
epic: "Performance & Scale"
priority: "could-have"
complexity: "M"
tags: [performance, pagination, infinite-scroll, UX, discovery]
---

# US-098: Infinite Scroll Pagination

## User Story

**As a** blog reader browsing the discovery feed (P-006),
**I want to** scroll through blogs and competition results without clicking "Next Page" buttons,
**So that** I can browse content fluidly and discover more blogs without interruption.

## Acceptance Criteria

- [ ] Given I am on the blog discovery page with more than 20 results, when I scroll to within 200px of the bottom of the list, then the next page of results is automatically fetched and appended to the list without a full page reload.
- [ ] Given a new page is being fetched during scroll, when the fetch is in progress, then a loading indicator (skeleton cards or spinner) is shown at the bottom of the list so I know more content is loading.
- [ ] Given I have scrolled through all available results, when no more pages exist, then the loading indicator is replaced with a message: "You've reached the end — {count} blogs discovered!" and no further fetches are triggered.
- [ ] Given infinite scroll is active, when I navigate to a blog detail page and press the browser back button, then I am returned to the discovery page at approximately the same scroll position I left (scroll position restoration).
- [ ] Given a fetch for the next page fails (network error), when the error occurs, then a "Load more" button appears as a fallback so I can manually retry rather than the feed silently stopping.
- [ ] Given the infinite scroll list, when rendered, then it is implemented using cursor-based pagination (not offset) on the backend to ensure consistent results as new items are added.
- [ ] Given a user has `prefers-reduced-motion: reduce` enabled (US-097), when using the discovery page, then infinite scroll still functions but without any scroll animation effects.

## Notes

Cursor-based pagination prevents "missing" or "duplicate" items when new content is inserted during a browsing session. Intersection Observer API is the recommended approach for scroll detection (avoids expensive scroll event listeners). Scroll position restoration can be implemented via sessionStorage. Relates to US-092 (empty state — "end of list" is a special empty state), US-099 (loading skeletons).
