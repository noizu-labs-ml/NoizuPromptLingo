---
id: US-012
title: "Search Techniques by Keyword"
slug: "search-techniques-by-keyword"
personas: [P-001, P-002, P-003, P-005, P-006]
epic: "Attack Catalog"
priority: "must-have"
complexity: "M"
tags: [catalog, search, keyword, discovery]
---

# US-012: Search Techniques by Keyword

## User Story

**As a** security professional doing rapid triage (P-001, P-002, P-003, P-005, P-006),
**I want to** search the catalog by keyword across technique names, descriptions, and tags,
**So that** I can quickly locate relevant techniques without navigating the full taxonomy tree.

## Acceptance Criteria

- [ ] Given I type in the search bar, when I have entered 2 or more characters, then autocomplete suggestions appear showing matching technique names within 200ms
- [ ] Given I submit a search query, when results are returned, then they are ranked by relevance with the matched terms highlighted in the result snippets
- [ ] Given my search returns no results, when the empty state renders, then I am shown suggested related terms, nearby taxonomy categories, and a link to submit a missing technique
- [ ] Given I perform a search, when I select a result, then I am taken directly to that technique's detail page (US-015) with my search query preserved in the URL for sharing

## Notes

Full-text search should index technique name, description, aliases, tags, and CVE/reference identifiers. Search state should be shareable via URL query params. Autocomplete must not expose draft or unpublished techniques.
