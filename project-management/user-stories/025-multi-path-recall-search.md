---
id: story-025
title: "Execute multi-path recall search"
persona: persona-the-recall-agent
priority: must-have
complexity: XL
status: draft
---

# Execute multi-path recall search

**As** The Recall Agent,
**I want to** execute parallel recall searches across multiple retrieval paths — semantic similarity, emotional context, association graph traversal, temporal proximity, and pattern membership — then merge and rank the results,
**So that** recall leverages the full richness of the memory web rather than relying on a single retrieval strategy.

## Acceptance Criteria
- [ ] Multi-path search executes 5 parallel retrieval strategies: vector similarity (semantic), emotional context matching, graph walk (follow top-weighted associations from seed memories), temporal window search, and pattern/synthesis membership lookup
- [ ] Each path returns up to K candidates (configurable, default 20 per path)
- [ ] Results are deduplicated and merged using reciprocal rank fusion (RRF) across all paths
- [ ] The final ranked list includes provenance metadata: which paths surfaced each memory and its per-path rank
- [ ] Total recall latency for multi-path search is <500ms at P95 for a 100K memory web
- [ ] Individual paths can be enabled/disabled per query via a `paths` parameter

## Scenario: Comprehensive recall for a complex question
- **Given** the query "How did we handle the last time Redis went down?" with emotional context of moderate anxiety
- **When** The Recall Agent executes multi-path search
- **Then** the semantic path finds memories mentioning Redis failures, the emotional path finds anxiety-associated operational memories, the graph walk finds memories linked to known Redis incidents, the temporal path finds memories from the same time period as past outages, and the pattern path finds the "Redis reliability" memory cluster — all merged into a single ranked list

## Scenario: Fast semantic-only recall
- **Given** a simple factual query "What database does the auth service use?" with `paths: [semantic]`
- **When** The Recall Agent executes single-path search
- **Then** only vector similarity search runs, returning results in <100ms

## Technical Notes
- Reciprocal rank fusion (RRF) is simple and effective for merging ranked lists: score = sum(1/(k+rank)) across paths, where k is a constant (default 60)
- Parallel execution of paths is critical for latency — use async/concurrent execution
- The graph walk path should use breadth-first traversal with weight-based pruning (don't follow links with weight <0.3)
- Consider a "recall budget" that caps total computation across all paths to prevent runaway queries
- Path weights in the merge can be configured per deployment or per query

## Related Stories
- story-024: Emotional recall is one of the five paths in multi-path search
- story-011: Weaver association links power the graph walk retrieval path
- story-013: Pattern membership provides the pattern/synthesis retrieval path
- story-026: Winnowing filters and refines the merged multi-path results
- story-021: Sentinel access gating is applied after merge but before results are returned
