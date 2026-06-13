---
id: US-053
title: "Filter search results by metadata"
slug: "filter-search-results"
personas: [P-001, P-004, P-007]
epic: "Registry & Discovery"
priority: "should-have"
complexity: "M"
tags: [registry, search, filters, faceted-search]
---

# US-053: Filter Search Results by Metadata

## User Story

**As a** Solo AI Hobbyist (P-007),
**I want to** filter search and browse results by auth method, popularity, health status, and other metadata,
**So that** I can narrow down to MCP servers that match my technical constraints and reliability expectations.

## Acceptance Criteria

- [ ] Given the user is viewing search results (US-051) or category listings (US-052), when the filter panel is visible, then it displays filter groups for: auth method, health status, trust score range, popularity (download/invocation count), and publisher verification status.
- [ ] Given the user selects one or more filter values, when they apply the filters, then the result list updates within 300ms to show only servers matching all selected filters (AND logic across groups, OR logic within a group).
- [ ] Given the user filters by auth method, when they select "API key" or "OAuth 2.0" or "None," then only servers supporting the selected auth method are shown.
- [ ] Given the user filters by health status, when they select "Healthy," then only servers with a passing health probe status (US-060) within the last 5 minutes are shown.
- [ ] Given the user filters by trust score range, when they set a minimum threshold via a slider, then only servers meeting or exceeding that score (US-056) are displayed.
- [ ] Given the user has active filters, when they view the filter panel, then all active filters are visually highlighted and a "Clear all" action resets to unfiltered results.

## Notes

Filter values should be dynamically populated from the result set (faceted search). Auth method options include: API key, OAuth 2.0, mTLS, and None. Related: US-051, US-052, US-056, US-060.
