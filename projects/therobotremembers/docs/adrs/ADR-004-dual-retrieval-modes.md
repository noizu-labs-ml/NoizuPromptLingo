---
id: ADR-004
title: "Dual Retrieval Modes (Active Recall + Tangential Insertion)"
status: accepted
date: 2026-05-27
---

# ADR-004: Dual Retrieval Modes (Active Recall + Tangential Insertion)

## Context

The memory system serves two fundamentally different use cases with incompatible performance profiles:

1. **Active Recall** — The agent or operator explicitly asks: "What do I know about X?" This is a deliberate, effortful search. The user is waiting for an answer. Latency budget is generous (< 2 seconds), search should be deep and thorough.

2. **Tangential Insertion** — The system passively monitors ongoing conversation and injects relevant memories when emotional/contextual resonance exceeds a threshold, without being asked. This must not disrupt conversational flow. Latency budget is tight (< 100ms), and only the strongest matches should surface.

These two modes are analogous to the difference between "trying to remember someone's name" (effortful, recursive, focused) and "a song plays and you suddenly remember a summer vacation" (effortless, serendipitous, unbidden).

The key architectural challenge: tangential insertion runs on every conversational turn. If it uses the full retrieval pipeline (vector search + metadata filter + graph traversal), it will add unacceptable latency to every interaction.

## Decision

Implement two distinct retrieval paths with separate infrastructure:

### Active Recall Path

| Property | Value |
|----------|-------|
| **Trigger** | Explicit API call or agent self-query |
| **Latency budget** | < 2 seconds |
| **Pipeline** | Vector search (Top-50) -> metadata filter -> graph traversal (3 hops) -> winnow (10-20) -> format |
| **Stores queried** | Weaviate + PostgreSQL + graph (recursive CTE) |
| **Dreamer** | May invoke real-time synthesis if results are sparse |
| **Output format** | Structured XML with full content, metadata, and association links |

### Tangential Insertion Path

| Property | Value |
|----------|-------|
| **Trigger** | Background resonance detection on conversation stream |
| **Latency budget** | < 100ms (< 10ms for cache hit) |
| **Pipeline** | Hot index lookup (Redis) -> single-hop association check -> winnow (1-3) -> format |
| **Stores queried** | Redis hot index only (precomputed) |
| **Dreamer** | Never (too slow) |
| **Output format** | Brief inline notes blended with conversational context |

### Hot Index Architecture

The hot index is a Redis-backed pre-computed cache that makes tangential insertion possible:

1. The Monitor continuously broadcasts the agent's current emotional state.
2. A background worker pre-fetches memories with high emotional resonance for the current state bucket.
3. Memories are stored in Redis as sorted sets keyed by emotional state region, scored by resonance.
4. The hot index is refreshed on significant emotional state change or every N conversational turns (configurable, default 5).
5. Tangential insertion queries only this hot index. Only hits scoring above the tangential threshold (configurable, default 0.75) are injected.

### Emotional State Bucketing

The 7-dimensional emotional vector (ADR-002) is quantized into discrete buckets for Redis keying:

```
bucket_key = f"hot:{quantize(valence, 4)}:{quantize(arousal, 3)}:{quantize(dominance, 3)}"
```

This creates approximately 36 emotional regions. Each bucket holds the top-100 resonant memories as a Redis sorted set.

## Alternatives Considered

### Single Retrieval Path with Configurable Parameters
- **Pros:** One codebase for retrieval. Toggle depth/latency via parameters. Simpler to maintain.
- **Cons:** The 100ms tangential budget cannot be achieved by "configuring" the full pipeline to be faster — it requires fundamentally different infrastructure (pre-computed cache vs. real-time query). A single path would either be too slow for tangential (if it queries Weaviate) or too shallow for active recall (if it only queries the cache).

### Always-On Tangential Only (No Active Recall)
- **Pros:** Simpler architecture — only the hot index path. The system always surfaces memories proactively, never waits to be asked.
- **Cons:** Users sometimes need to deliberately search ("what did we decide about X?"). Tangential insertion is winnowed to 1-3 results — insufficient for deliberate research. Cannot support the "traverse associations from a starting memory" use case.

### Active Recall Only with Periodic Summaries
- **Pros:** No hot index infrastructure needed. Background process generates periodic "memory digests" instead of real-time tangential insertion.
- **Cons:** Loses the serendipitous "oh, I remember something relevant" experience. Periodic summaries are batched and stale by the time they surface. The whole point of the emotional model is to enable resonance-driven surfacing — removing tangential insertion guts the core value proposition.

## Consequences

- **Positive:** Each retrieval mode is optimized for its use case. Active recall is thorough and deep. Tangential insertion is fast and unobtrusive. The hot index makes per-turn memory surfacing viable at scale. The two modes complement each other — tangential insertion surfaces memories that prompt the user to do a deliberate active recall.
- **Negative:** Two codepaths for retrieval = two codepaths to maintain, test, and debug. The hot index is a cache with all the classic cache problems (staleness, invalidation, cold start). Redis adds operational surface to the storage architecture (ADR-001). The emotional state bucketing scheme is somewhat arbitrary — bucket boundaries affect which memories are pre-fetched.
- **Risks:** Hot index staleness during rapid emotional state transitions (e.g., agent goes from calm to stressed in one turn — the cache still holds "calm" memories). Mitigation: invalidate and eagerly refresh on large emotional state deltas. Cold start problem: on system restart, the hot index is empty until the background worker completes its first pass. Mitigation: serve active recall results until the hot index warms up.

## Related

- ADR-001: Three-Layer Storage Architecture — the Redis layer exists primarily to serve tangential insertion
- ADR-002: Emotional Metadata Model — emotional resonance is the scoring function for both paths
- ADR-003: Multi-Agent Ensemble — the Recall Agent implements both paths; the Monitor drives hot index refresh
