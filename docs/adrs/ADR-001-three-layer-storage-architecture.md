---
id: ADR-001
title: "Three-Layer Storage Architecture (Weaviate + PostgreSQL + Redis)"
status: accepted
date: 2026-05-27
---

# ADR-001: Three-Layer Storage Architecture (Weaviate + PostgreSQL + Redis)

## Context

The Robot Remembers has three fundamentally different query patterns that must be served with low latency:

1. **Semantic similarity search** — "find memories whose content is close to this query." This requires approximate nearest-neighbor (ANN) search over dense vector embeddings. Latency target: < 200ms for Top-50.
2. **Relational metadata queries** — "find memories formed during debugging, at night, with cortisol > 0.7, in the last 30 days." This requires structured filtering over JSONB metadata, lifecycle state, compartment policies, and temporal ranges. Also: association edge traversal via recursive CTEs (see ADR-006). Needs ACID transactions for lifecycle state transitions.
3. **Sub-100ms hot index** — Tangential insertion requires a pre-computed cache of emotionally resonant memories that can be queried on every conversational turn without incurring the full retrieval pipeline. Latency target: < 10ms for cache hit.

These three patterns have conflicting optimization profiles. A single database cannot serve all three without significant compromise.

## Decision

Use three specialized stores, each optimized for its query pattern:

| Layer | Technology | Stores | Query Pattern |
|-------|-----------|--------|---------------|
| **Vector store** | Weaviate | Content text, summary, embedding vectors, content_type, compartment, created_at | ANN similarity search, Top-K retrieval |
| **Relational store** | PostgreSQL | Full metadata (JSONB), lifecycle state, emotional/contextual metadata, agent state, compartment policies, quarantine buffer, audit logs, association edges | Attribute filtering, temporal queries, graph traversal (recursive CTE), transactional state management |
| **Hot index** | Redis | Pre-computed emotionally resonant memory IDs + summary payload, keyed by emotional state bucket | Sub-10ms cache lookup for tangential insertion |

All three stores are linked by `memory_id` (UUID). PostgreSQL is the system of record. Weaviate and Redis are derived — they can be rebuilt from PostgreSQL + re-embedding if lost.

**Consistency model:** PostgreSQL writes are synchronous. Weaviate writes are fire-and-forget with retry queue (eventual consistency acceptable for a few hundred ms). Redis is refreshed asynchronously by the Monitor's emotional state broadcasts.

## Alternatives Considered

### PostgreSQL with pgvector Only
- **Pros:** Single database, operational simplicity, ACID for everything, pgvector supports ANN search with HNSW indexes.
- **Cons:** pgvector ANN performance degrades significantly beyond ~500K vectors without careful tuning. Cannot serve the hot index pattern (no sub-10ms cache semantic). Mixing vector search workload with transactional metadata workload on the same instance creates resource contention. No built-in multi-tenancy or collection-level schema management for vectors.

### Weaviate Only
- **Pros:** Native vector search, built-in filtering, GraphQL API, supports structured properties alongside vectors.
- **Cons:** Not a relational database — no ACID transactions, no recursive CTEs for graph traversal, no mature JSONB query capabilities. Cannot enforce referential integrity for lifecycle state machines. Poor fit for the quarantine/audit/compartment use cases that need transactional guarantees.

### Single Unified Store (Custom)
- **Pros:** No cross-store consistency concerns, single deployment target.
- **Cons:** Would require building a custom database that combines ANN search, relational queries, graph traversal, and in-memory caching. This is a multi-year infrastructure project, not a product feature.

## Consequences

- **Positive:** Each query pattern is served by the technology best suited to it. Vector search throughput scales independently of metadata query load. Hot index latency is bounded by Redis's in-memory model. Clear separation of concerns in the storage layer.
- **Negative:** Three databases to operate, monitor, and back up. Cross-store consistency requires careful write ordering (Postgres first, then Weaviate, then Redis refresh). Developers must understand which store to query for which pattern — abstracted by the `storage` package but still a conceptual burden.
- **Risks:** Cross-store drift if the Weaviate write queue backs up during high load. Redis cache invalidation bugs could cause tangential insertion to surface stale or missing memories. Weaviate version upgrades may require re-indexing.

## Related

- ADR-004: Dual Retrieval Modes (Active Recall + Tangential Insertion) — drives the Redis hot index requirement
- ADR-006: Graph Storage in PostgreSQL — explains why graph traversal stays in Postgres rather than a dedicated graph DB
