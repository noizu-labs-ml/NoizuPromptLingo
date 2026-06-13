---
id: US-098
title: "Loading States and Pagination"
slug: "loading-states-and-pagination"
personas: [P-001, P-008]
epic: "Accessibility, Performance & Edge Cases"
priority: "should-have"
complexity: "S"
tags: [performance, loading, pagination, ux]
---

# US-098: Loading States and Pagination

## User Story

**As a** Junior IoT Technician (P-008),
**I want to** see clear loading indicators and navigate large data sets through pagination,
**So that** I always know the system is working and can find the records I need without the interface becoming unresponsive.

## Acceptance Criteria

- [ ] Given any data fetch takes longer than 300ms, when the request is in flight, then a skeleton loader or spinner is displayed in the content area being populated
- [ ] Given a list or table exceeds 50 items, when it renders, then server-side pagination controls appear with page size selector (25, 50, 100) and prev/next buttons
- [ ] Given I am on page 3 of a paginated list, when I refresh the browser, then I return to page 3 with the same filters and sort order preserved via URL query parameters
- [ ] Given a fetch takes longer than 15 seconds, when the timeout occurs, then an error state is shown with a Retry button rather than an indefinite spinner
- [ ] Given I change the page size, when the list re-renders, then focus is moved to the first row of the new page and the total count is updated

## Notes

Infinite scroll is not used for compliance-critical tables (audit logs, incident lists) to ensure reproducible pagination for export and review. Relates to US-099 (offline/degraded mode) and US-100 (empty states).
