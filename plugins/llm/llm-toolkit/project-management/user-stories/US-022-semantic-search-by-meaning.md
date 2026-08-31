---
id: US-022
title: "Semantic search by meaning"
slug: semantic-search-by-meaning
personas: [P-001, P-003]
epic: "Search & Discovery"
priority: must-have
complexity: high
tags: [search, semantic]
---

# US-022: Semantic Search by Meaning

## User Story

**As an** ML fine-tuning engineer
**I want to** switch search to semantic mode and have my query embedded and matched against conversation embeddings by meaning
**So that** I can surface relevant training-worthy exchanges even when they don't share exact keywords with my query

## Acceptance Criteria

- **Given** the background indexer has generated MiniLM embeddings for all indexed conversations
  **When** I enter a semantic query like "handling flaky retries in an API client" and submit
  **Then** results include conversations discussing exponential backoff or timeout handling even if those exact words never appear in the query

- **Given** I run the same query in keyword mode versus semantic mode
  **When** I compare result sets
  **Then** semantic mode returns a distinct ranked list based on embedding similarity rather than exact term matches

- **Given** the embedding model has not finished indexing a newly added project
  **When** I run a semantic search
  **Then** the UI indicates that some results may be incomplete/pending rather than silently omitting the project

- **Given** Marcus can't recall the exact terms used in an old debugging session
  **When** he switches to semantic mode and describes the problem in his own words
  **Then** the matching thread appears in the top results ranked by similarity

## Notes
This is the highest-value tool for Elena, who mines the whole corpus for training examples using semantic recall rather than exact phrasing; correctness of the MiniLM embedding pipeline and similarity ranking is core to her workflow (see US-027 for surfacing the similarity score itself). High complexity reflects the need to keep embeddings in sync with the incremental background indexer.
