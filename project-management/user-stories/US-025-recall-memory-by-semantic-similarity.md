---
id: US-025
title: "Recall a memory by semantic similarity"
slug: "recall-memory-by-semantic-similarity"
personas: [P-002]
epic: "Agent Personas & Memory"
priority: "must-have"
complexity: "M"
tags: [memory, semantic-search, recall, embeddings]
---

# US-025: Recall a memory by semantic similarity

## User Story

**As the** Autonomous Coding Agent (P-002),
**I want to** query my associative memory for entries semantically similar to a given prompt or situation,
**So that** I can retrieve relevant past experience even when I don't recall the exact wording or ID of the original memory.

## Acceptance Criteria

- [ ] Given Sable's persona has multiple stored memories (episodic, semantic, or procedural), when it submits a natural-language query, then the system returns the top-N memories ranked by semantic similarity to that query.
- [ ] Given a similarity query, when results return, then each includes a similarity score plus enough metadata — type, timestamp, brief content — to judge relevance without a second round-trip.
- [ ] Given a query with no reasonably similar memories in the store, when Sable runs the recall, then an empty result set is returned rather than low-quality forced matches.
- [ ] Given memories exist across multiple access-controlled compartments, when Sable recalls by similarity, then only memories in compartments it has access to are considered or returned.

## Notes

Complexity M — requires embedding generation plus vector similarity search wired into the persistence layer, not a simple lookup. A distinct retrieval axis from US-026 (emotional signature).
