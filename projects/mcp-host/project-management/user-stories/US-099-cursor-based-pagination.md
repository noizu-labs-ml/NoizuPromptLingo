---
id: US-099
title: "System paginates large registry search results with cursor-based pagination"
slug: "cursor-based-pagination"
personas: [P-001, P-008]
epic: "Performance & Integration"
priority: "must-have"
complexity: "M"
tags: [performance, pagination, registry, search, api, cursor-based]
---

# US-099: System Paginates Large Registry Search Results with Cursor-Based Pagination

## User Story

**As an** MCP Tool Developer (P-001),
**I want to** browse registry search results with efficient pagination that performs consistently regardless of how deep in the results I am,
**So that** I can explore the full catalog of MCP servers without encountering slow load times or missing results as I page through large result sets.

## Acceptance Criteria

- [ ] Given a registry search returns more results than the default page size (25), when the response is returned, then it includes a `next_cursor` token, the current page of results, and a `has_more` boolean indicating whether additional pages exist
- [ ] Given a user requests the next page of results, when they pass the `next_cursor` from the previous response, then the system returns the next page starting immediately after the last item of the previous page with no duplicate or missing entries
- [ ] Given a user paginates through a registry with 10,000+ results, when they request page 400 via cursor, then the response time is comparable to requesting page 1 (no performance degradation from offset-based pagination at high page numbers)
- [ ] Given an API client (P-008) makes paginated requests, when no cursor is provided, then the first page is returned with default page size; when a page size parameter is provided (between 1 and 100), then the system respects the requested page size

## Notes

Cursor-based pagination is preferred over offset-based for consistent performance on large datasets and to avoid skipped/duplicate results during concurrent writes. The cursor should be opaque (encoded, not a raw database ID) and have a TTL of 24 hours. Meilisearch natively supports cursor-based pagination which simplifies implementation. Related to the Registry & Discovery component.
