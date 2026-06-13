---
id: US-075
title: "Semantic Search Over Game History"
slug: "semantic-search"
personas: [P-001, P-003]
epic: "Memory System"
priority: "should-have"
complexity: "L"
tags: [memory-system, semantic-search, embeddings, vector-search, history]
---

# US-075: Semantic Search Over Game History

## User Story

**As an** indie AI game developer (P-001),
**I want to** perform natural-language semantic searches over the entire game history,
**So that** I can surface relevant past events for narrative callbacks, NPC memory responses, and plot consistency checks without constructing complex filter queries.

## Acceptance Criteria

- [ ] Given a session journal with 1,000 events and an embedding provider configured, when `memory.search(session_id, query="the time the player betrayed the guild", top_k=5)` is called, then the 5 returned events are those most semantically similar to the query, each including a `score` float.
- [ ] Given `search()` called with `filters={"event_type": "dialogue"}`, when results are returned, then all returned events have `event_type == "dialogue"` regardless of their semantic scores relative to non-dialogue events.
- [ ] Given `search()` called with `date_range={"after": "2025-01-10T00:00:00Z"}`, when results are returned, then all returned events have timestamps after the specified date.
- [ ] Given an embedding provider not configured and `search()` called, then a `SearchNotAvailableError` is raised with a message instructing the user to configure an embedding provider.
- [ ] Given `search()` called with `include_summaries=True` (for sessions with compressed history per US-072), when results are returned, then compressed summary events are eligible for inclusion alongside raw events.
- [ ] Given `memory.index_session(session_id)` called explicitly, when it completes, then all un-indexed events in that session have embeddings stored and subsequent `search()` calls run without per-call embedding generation for those events.
- [ ] Given `memory.search()` called on a session with zero events, then it returns an empty list without error.

## Notes

Dr. Okafor (P-003) will use semantic search to study how memory retrieval quality affects narrative coherence in research settings. Builds on US-073 (relevance retrieval) as the underlying scoring layer; `search()` is a higher-level API that adds filtering, date ranges, and index management. `L` complexity due to embedding index lifecycle and filter composition.
