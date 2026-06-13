---
id: US-074
title: "Suggested Connections Between Entries"
slug: "suggested-connections"
personas: [P-001, P-003, P-005, P-008]
epic: "Search & Discovery"
priority: "could-have"
complexity: "L"
tags: [search, discovery, connections, ai, graph, suggestions]
---

# US-074: Suggested Connections Between Entries

## User Story

**As an** epic novelist (P-001),
**I want to** receive AI-powered suggestions for connections I might want to establish between entries,
**So that** I discover relationships I hadn't consciously planned and build a richer knowledge graph with less manual linking effort.

## Acceptance Criteria

- [ ] Given a canon entry is open in the detail view, when I open the "Suggested Connections" panel, then the system displays up to 10 other entries from the same universe that are semantically related, ranked by relevance score.
- [ ] Given a suggested connection is displayed, when I view it, then it shows the target entry name, type, a brief explanation of why the connection is suggested (e.g., "both entries mention the Obsidian War"), and a confidence score.
- [ ] Given I accept a suggested connection, when I confirm, then a bidirectional relationship edge is created between the two entries in the knowledge graph with a user-defined relationship label (e.g., "rival of," "located in").
- [ ] Given I dismiss a suggested connection, when I confirm dismissal, then that specific pairing is not suggested again for the lifetime of the universe, and the dismissal is logged for model feedback purposes.

## Notes

Depends on US-070 (semantic search) for embedding-based similarity. Suggestions are generated lazily (on-demand per entry view) rather than precomputed for all pairs, to control cost. Related: US-075 (gap analysis), Knowledge Graph feature.
