---
id: US-098
title: "Paginated & Infinite-Scroll for Long Lists"
slug: "paginated-infinite-scroll-lists"
personas: [P-007, P-001, P-002]
epic: "Performance & Scale"
priority: "should-have"
complexity: "M"
tags: [performance, pagination, infinite-scroll, dashboard, scalability]
---

# US-098: Paginated & Infinite-Scroll for Long Lists

## User Story

**As an** existing client with a mature engagement (P-007),
**I want** long lists such as project history, support tickets, and the activity feed to load quickly with incremental pagination,
**So that** the dashboard remains fast even as engagement history grows over months.

## Acceptance Criteria

- [ ] Given a list with more than 20 items (projects, tickets, activity feed), when the page loads, then only the first 20 items are fetched and rendered
- [ ] Given a paginated list, when the user scrolls to within 200px of the last rendered item, then the next page is automatically fetched and appended (infinite scroll)
- [ ] Given data loading during scroll, when items are being fetched, then skeleton placeholder rows are shown in the expected item positions
- [ ] Given a fetch error during infinite scroll, when the request fails, then a "Load more" manual trigger button appears in place of the automatic loader
- [ ] Given the activity feed, when a new event occurs during an active session, then a "New activity" badge appears at the top of the feed; clicking it scrolls to and reveals the new items
- [ ] Given paginated API endpoints, when queried, then they support cursor-based pagination (not offset-based) for consistent results as items are added

## Notes

Cursor-based pagination is preferred over offset because concurrent inserts can cause offset pagination to skip or repeat items. Implement with Intersection Observer API for scroll detection. List virtualization (react-virtual or similar) is a could-have for very long lists (500+ items). Related to US-099 (image optimization), US-026 (dashboard overview).
