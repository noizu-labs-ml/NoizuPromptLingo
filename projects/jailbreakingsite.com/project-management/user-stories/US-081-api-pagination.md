---
id: US-081
title: "API Pagination for Large Result Sets"
slug: "api-pagination"
personas: [P-001, P-003, P-006]
epic: "API & Integration"
priority: "must-have"
complexity: "S"
tags: [api, pagination, developer-experience, performance]
---

# US-081: API Pagination for Large Result Sets

## User Story

**As a** developer consuming the full technique catalog programmatically (P-001, P-003, P-006),
**I want to** paginate through large result sets with a stable cursor-based API,
**So that** I can reliably ingest all records without memory overloads, missed records, or inconsistencies from concurrent inserts.

## Acceptance Criteria

- [ ] Given a list endpoint (`/v1/techniques`), when I request without pagination params, then the first page of 50 results is returned with a `meta.pagination` object containing `total`, `page`, `per_page`, `next_cursor`, and `prev_cursor`
- [ ] Given a `next_cursor` in the response, when I pass `?cursor={value}`, then the next stable page of results is returned with no duplicates or gaps
- [ ] Given a `per_page` param, when I pass `?per_page=100`, then up to 100 results are returned (max 200 enforced server-side)
- [ ] Given I am on the last page, when I receive the response, then `next_cursor` is `null`
- [ ] Given cursor-based pagination, when new records are inserted during iteration, then already-delivered pages are unaffected (stable cursor semantics)
- [ ] Given an invalid or expired cursor, when I use it, then a 400 is returned with `error.code: invalid_cursor` and a hint to restart pagination

## Notes

Cursor-based pagination is preferred over offset/limit to avoid the "page shift" problem on a live dataset. Cursors should be opaque base64 tokens encoding a stable sort key + ID. Offset pagination (`?page=N`) is an acceptable alias for non-critical endpoints but must be documented as eventually-consistent.
