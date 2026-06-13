---
id: US-095
title: "Paginate large mockup collections"
slug: "paginate-large-collections"
personas: [P-002, P-005, P-001]
epic: "Performance & Scale"
priority: "should-have"
complexity: "S"
tags: [performance, pagination, scalability]
---

# US-095: Paginate large mockup collections

## User Story

**As an** Enterprise Architect (P-005),
**I want to** paginate through large collections of mockups,
**So that** the gallery remains responsive even when I have hundreds of mockups in my workspace.

## Acceptance Criteria

- [ ] Given a workspace has more than 24 mockups, when I view the gallery, then mockups are displayed in pages of 24 with next/previous navigation controls
- [ ] Given I am on a page of results, when I apply a filter or change the sort order, then the results reset to page 1 and the URL updates to reflect the current state
- [ ] Given I navigate directly to a paginated URL (e.g., `?page=3`), when the page loads, then the correct page of results is rendered server-side for direct linking and SEO

## Notes

Cursor-based pagination is preferred over offset-based for large datasets to avoid the "missing rows" problem on concurrent inserts. Page size of 24 is a UI default; the API should support a configurable `per_page` parameter up to 100. Related to US-094 and US-096.
