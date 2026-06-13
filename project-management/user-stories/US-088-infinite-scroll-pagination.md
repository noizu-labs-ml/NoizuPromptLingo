---
id: US-088
title: "Infinite Scroll and Pagination for Feeds"
slug: "infinite-scroll-pagination-feeds"
personas: [P-001, P-002, P-003, P-006]
epic: "Performance & Scale"
priority: "should-have"
complexity: "M"
tags: [performance, pagination, infinite-scroll, feed, ux]
---

# US-088: Infinite Scroll and Pagination for Feeds

## User Story

**As an** AI Hobbyist (P-002) or Prompt Engineer (P-001),
**I want to** load more prompts smoothly as I scroll down the feed,
**So that** I can browse a large volume of content without disruptive page loads or losing my place.

## Acceptance Criteria

- [ ] Given a user scrolling through the main feed, when they approach within 3 prompt cards of the end of the loaded list, then the next page of prompts is automatically fetched and appended
- [ ] Given infinite scroll is loading the next batch, when the fetch is in progress, then a skeleton loading indicator is shown at the bottom of the list
- [ ] Given a user who has scrolled deep into the feed and copies the URL, when they share it and another user opens the link, then the recipient lands at the top of the feed (cursor-based pagination URLs are not required for sharing)
- [ ] Given a user reaches the end of all available content, when there are no more prompts to load, then a clear end-of-feed message is displayed rather than a perpetual loading state
- [ ] Given a user prefers traditional pagination (e.g., due to assistive technology), when they enable a pagination preference in settings, then numbered page controls replace infinite scroll

## Notes

Cursor-based pagination is preferred over offset-based to avoid duplicate/missing items as new prompts are added. The pagination preference for accessibility users is important — infinite scroll can disorient screen reader users. Backend must expose a `next_cursor` field in list responses.
