---
id: US-070
title: "Semantic Search (Vector)"
slug: "semantic-search"
personas: [P-001, P-003, P-007]
epic: "Search & Discovery"
priority: "should-have"
complexity: "XL"
tags: [search, semantic, vector, ai, discovery, similarity]
---

# US-070: Semantic Search (Vector)

## User Story

**As a** narrative designer (P-003),
**I want to** search for entries by meaning or concept rather than exact keyword,
**So that** I can find all entries thematically related to "betrayal" or "ancient magic" even when those exact words don't appear in the text.

## Acceptance Criteria

- [ ] Given a universe with vectorized entries, when I toggle "Semantic Search" and enter a concept query (e.g., "corruption of power"), then the system returns a ranked list of entries whose meaning is semantically similar, within 3 seconds.
- [ ] Given semantic search results, when I view the results list, then each result includes a similarity score (e.g., "92% match") displayed alongside the entry name and excerpt, and results are sorted by score descending.
- [ ] Given an entry is created or updated, when the save completes, then a background job re-embeds the entry and updates its vector index within 5 minutes, so the entry is discoverable by semantic search on the next query.
- [ ] Given I use both full-text and semantic search modes, when I switch between them for the same query, then each mode produces its own independent result set without mixing results, and I can view them in separate tabs.

## Notes

Requires a vector embedding pipeline (e.g., OpenAI embeddings or equivalent) and a vector store. This is the highest-complexity search story. Depends on US-069 (full-text search). Also used by P-007 (AI Agent) for grounding context retrieval in US-062. Related: US-074 (suggested connections), US-075 (gap analysis).
