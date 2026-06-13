---
id: US-097
title: "Paginated Loading for Large Catalog Views"
slug: "paginated-loading-catalog"
personas: [P-001, P-002, P-004, P-006]
epic: "Accessibility & Performance"
priority: "must-have"
complexity: "M"
tags: [performance, pagination, catalog, loading, ux]
---

# US-097: Paginated Loading for Large Catalog Views

## User Story

**As a** researcher browsing or filtering the full technique catalog (P-001, P-002, P-004, P-006),
**I want to** load catalog results in efficient pages or incremental batches,
**So that** the catalog remains fast and usable even as the technique database grows to thousands of entries.

## Acceptance Criteria

- [ ] Given the catalog list view, when it loads, then the initial render displays within 1.5 seconds on a standard broadband connection (LCP target)
- [ ] Given a catalog page load, when the page renders, then at most 50 technique cards are loaded in the initial batch; further results are loaded on scroll (infinite scroll) or via explicit pagination controls
- [ ] Given infinite scroll, when I reach the bottom of the loaded results, then a loading indicator appears, the next batch loads within 500ms, and focus is not disrupted for keyboard or screen reader users
- [ ] Given a user who prefers explicit pagination, when they toggle to "Page" mode, then numbered page controls replace infinite scroll and the URL reflects the current page (`?page=3`) for shareability
- [ ] Given a URL with a page parameter, when I share it, then the recipient lands on the same page with the same filters applied
- [ ] Given the page while loading additional results, when the user scrolls rapidly, then requests are debounced and no duplicate batches are fetched

## Notes

The choice between infinite scroll and pagination should respect user preference and accessibility: screen reader users generally benefit from pagination. Skeleton loaders (not spinners) should be used while technique cards load. The URL state must always reflect the current view to support deep-linking, sharing, and browser back-navigation.
