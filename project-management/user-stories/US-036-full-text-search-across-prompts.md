---
id: US-036
title: "Full-Text Search Across Prompts"
slug: "full-text-search-across-prompts"
personas: [P-001, P-002, P-003, P-005, P-007, P-008]
epic: "Search & Discovery"
priority: "must-have"
complexity: "L"
tags: [search, discovery, full-text, prompts]
---

# US-036: Full-Text Search Across Prompts

## User Story

**As an** AI hobbyist looking for existing work (P-002),
**I want to** search for prompts by keyword across titles, bodies, and tags,
**So that** I can quickly find relevant prompts without manually browsing categories.

## Acceptance Criteria

- [ ] Given I type a query into the search bar and submit, when results are returned, then all prompts whose title, body, or tags contain the query terms are listed, ranked by relevance score descending
- [ ] Given a search returns results, when the list is rendered, then matching terms are highlighted in bold within the title and a truncated excerpt of the body
- [ ] Given my query matches no prompts, when results are returned, then a "no results" empty state is shown with suggestions to broaden the search or browse by category
- [ ] Given I perform a search, when results load, then the response time is under 500ms for indexes up to 100,000 documents

## Notes

Full-text search should be backed by a dedicated search index (e.g., PostgreSQL tsvector, Meilisearch, or Elasticsearch). Stemming and stop-word removal should be enabled by default. Search queries should be logged (anonymized) for analytics and query improvement.
