---
id: US-073
title: "Relevance-Scored Memory Retrieval"
slug: "relevance-retrieval"
personas: [P-001, P-003]
epic: "Memory System"
priority: "must-have"
complexity: "L"
tags: [memory-system, retrieval, relevance-scoring, context-injection, rag]
---

# US-073: Relevance-Scored Memory Retrieval

## User Story

**As an** indie AI game developer (P-001),
**I want to** retrieve the most contextually relevant events from the journal given a query,
**So that** I can inject a focused memory window into LLM prompts without exceeding token limits or flooding context with irrelevant history.

## Acceptance Criteria

- [ ] Given a session with 500 events and a query `"what happened with the blacksmith"`, when `memory.retrieve(session_id, query="what happened with the blacksmith", top_k=5)` is called, then the 5 returned events have the highest relevance scores to the query among all events in the journal.
- [ ] Given `retrieve()` called with `top_k=5` and fewer than 5 events in the session, when the call executes, then all available events are returned without error.
- [ ] Given a retrieval result, when each item is inspected, then it contains the original event dict plus a `relevance_score` float between 0.0 and 1.0.
- [ ] Given `relevance_strategy: "recency"` configured, when `retrieve()` is called, then results are ranked purely by timestamp (most recent first) without LLM or embedding calls.
- [ ] Given `relevance_strategy: "embedding"` configured and an embedding provider set, when `retrieve()` is called, then cosine similarity between the query embedding and event embeddings determines scores.
- [ ] Given `relevance_strategy: "hybrid"` configured with `recency_weight: 0.3` and `semantic_weight: 0.7`, when `retrieve()` is called, then the returned scores are a weighted combination and results differ from either pure strategy alone.
- [ ] Given an embedding provider that raises an error during retrieval, when `retrieve()` runs with `fallback_strategy: "recency"`, then it silently falls back to recency scoring and returns results without propagating the error.

## Notes

Dr. Okafor (P-003) will use hybrid strategies for research on memory-augmented RPG agents. Embedding storage can be in-memory or backed by an external vector store (configurable). Pairs with US-075 (semantic search) which exposes a higher-level search interface over this retrieval layer.
