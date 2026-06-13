---
id: US-069
title: "Full-Text Search Across Canon Entries"
slug: "full-text-search"
personas: [P-001, P-002, P-003, P-004, P-005, P-007, P-008]
epic: "Search & Discovery"
priority: "must-have"
complexity: "M"
tags: [search, full-text, discovery, lookup]
---

# US-069: Full-Text Search Across Canon Entries

## User Story

**As an** epic novelist (P-001),
**I want to** search the full text of all canon entries in my universe by keyword,
**So that** I can instantly find every mention of a place, item, or concept scattered across hundreds of entries.

## Acceptance Criteria

- [ ] Given a universe with populated entries, when I type a keyword into the global search bar, then the system returns all entries whose title, body, or metadata contain that keyword, ranked by relevance, within 1 second for universes with up to 2,000 entries.
- [ ] Given search results are returned, when I view the results list, then each result shows the entry name, type, and a snippet of the matching text with the keyword highlighted in context.
- [ ] Given I search for a multi-word phrase in quotes (e.g., `"iron throne"`), when results load, then only entries containing that exact phrase are returned, not entries with the individual words separately.
- [ ] Given a universe is empty or has no matching entries, when I search, then I see a "No results found for '[query]'" state with suggestions to check spelling or broaden the search, rather than a blank screen.

## Notes

Full-text search is foundational to the Search & Discovery epic and used by the Session Companion (US-061). Indexing should be kept current within 30 seconds of an entry save. Related: US-070 (semantic search), US-071 (filters).
