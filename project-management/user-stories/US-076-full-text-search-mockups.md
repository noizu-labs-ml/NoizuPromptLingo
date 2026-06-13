---
id: US-076
title: "Full-text search across mockups and projects"
slug: "full-text-search-mockups"
personas: [P-001, P-002, P-003]
epic: "Search & Discovery"
priority: "should-have"
complexity: "M"
tags: [search, discovery, productivity]
---

# US-076: Full-text search across mockups and projects

## User Story

**As a** Product Manager (P-002),
**I want to** search across all mockups and projects by keyword,
**So that** I can quickly locate specific mockups without manually browsing every project.

## Acceptance Criteria

- [ ] Given I am authenticated, when I type a query into the global search bar, then results appear showing matching mockup titles, descriptions, and project names
- [ ] Given search results are returned, when I click a result, then I am navigated directly to that mockup or project
- [ ] Given no results match my query, when I submit a search, then I see an empty state with a clear "no results" message and a suggestion to try broader terms

## Notes

Search should index mockup titles, descriptions, tags, and project names. Full-text search via PostgreSQL `tsvector` is acceptable for initial implementation. Related to US-077, US-078, US-079.
