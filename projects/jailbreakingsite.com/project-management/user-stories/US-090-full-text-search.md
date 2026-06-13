---
id: US-090
title: "Full-Text Search Across All Content Types"
slug: "full-text-search"
personas: [P-001, P-004, P-006, P-008]
epic: "Search & Discovery"
priority: "must-have"
complexity: "L"
tags: [search, discovery, catalog, full-text, ux]
---

# US-090: Full-Text Search Across All Content Types

## User Story

**As a** researcher or practitioner looking for specific threat intelligence (P-001, P-004, P-006, P-008),
**I want to** run a single search query that spans techniques, labs, community discussions, and researcher profiles,
**So that** I can find relevant information regardless of where it lives on the platform without knowing in advance which section to look in.

## Acceptance Criteria

- [ ] Given the global search bar (accessible from any page via keyboard shortcut and header), when I type a query, then results appear within 300ms using a debounced live-search with result type grouping (Techniques, Labs, Discussions, Researchers)
- [ ] Given search results, when I view them, then each result shows type badge, title, a highlighted excerpt with matched terms bolded, and a relevance score indicator
- [ ] Given a search query matching a technique name or ID exactly, when results render, then the exact match appears first regardless of ranking algorithm
- [ ] Given I submit a full search (Enter key), when I land on the search results page, then I can filter by content type, date range, severity, and category without re-typing the query
- [ ] Given search results with no matches, when the empty state renders, then I see suggested alternative queries, links to browse by category, and a CTA to submit a new technique if none exists
- [ ] Given the search index, when a new technique is published or a discussion post is created, then it is indexed and searchable within 60 seconds

## Notes

Full-text search should support quoted phrases (`"prompt injection"`) and exclusion (`-category:social-engineering`). Typo tolerance for common misspellings of model names and technique terms is strongly desirable. Indexing should be async (e.g., Elasticsearch, Typesense, or Meilisearch) to avoid query load on the primary database.
