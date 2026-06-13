---
id: ADR-006
title: "Graph Storage in PostgreSQL (Not Dedicated Graph DB)"
status: accepted
date: 2026-05-27
---

# ADR-006: Graph Storage in PostgreSQL (Not Dedicated Graph DB)

## Context

The association graph — edges connecting memories by semantic similarity, emotional resonance, temporal proximity, causation, and co-occurrence — requires graph traversal for recall. The Recall Agent traverses up to 3 hops from initial candidate memories, following edges above a weight threshold, to discover associated memories along relevant coordinates.

The question: should the association graph live in PostgreSQL (which is already the relational store for metadata), or in a dedicated graph database?

Key constraints:

- **Traversal depth is bounded.** The Recall Agent traverses at most 3 hops (configurable). This is not an unbounded shortest-path problem.
- **Edge count at launch is moderate.** Expected: < 100K edges in year 1, < 1M edges in year 2. Not billion-scale.
- **Edges are heavily filtered.** Most traversals filter by `edge_type` and `min_edge_weight`, reducing the effective fan-out dramatically.
- **PostgreSQL is already deployed** for metadata. Adding a graph DB adds operational surface (ADR-001).
- **Graph queries always join with relational data.** After traversing edges, the Recall Agent needs metadata (emotional state, lifecycle, compartment) from the `memories` table. If the graph is in a separate DB, this requires cross-database joins or multiple round trips.

## Decision

Store the association graph as an adjacency list in PostgreSQL using the `association_edges` table. Use recursive CTEs for bounded traversal:

```sql
WITH RECURSIVE graph_walk AS (
    -- Base case: direct neighbors of seed memories
    SELECT
        ae.target_memory_id AS memory_id,
        ae.weight,
        ae.edge_type,
        1 AS depth,
        ARRAY[ae.source_memory_id, ae.target_memory_id] AS path
    FROM association_edges ae
    WHERE ae.source_memory_id = ANY($1)          -- seed memory IDs
      AND ae.weight >= $2                         -- min_edge_weight
      AND ae.edge_type = ANY($3)                  -- allowed edge types

    UNION ALL

    -- Recursive case: neighbors of neighbors
    SELECT
        ae.target_memory_id,
        ae.weight,
        ae.edge_type,
        gw.depth + 1,
        gw.path || ae.target_memory_id
    FROM association_edges ae
    JOIN graph_walk gw ON ae.source_memory_id = gw.memory_id
    WHERE gw.depth < $4                           -- max_depth (default 3)
      AND ae.weight >= $2
      AND ae.edge_type = ANY($3)
      AND ae.target_memory_id != ALL(gw.path)     -- cycle prevention
)
SELECT DISTINCT ON (memory_id)
    memory_id,
    MIN(depth) AS shortest_depth,
    MAX(weight) AS max_edge_weight
FROM graph_walk
GROUP BY memory_id
ORDER BY memory_id, shortest_depth, max_edge_weight DESC;
```

### Index Strategy

```sql
-- Primary traversal: find edges from a source, filtered by type and weight
CREATE INDEX idx_assoc_source_type_weight
    ON association_edges(source_memory_id, edge_type, weight DESC);

-- Reverse traversal: find what points TO a memory
CREATE INDEX idx_assoc_target
    ON association_edges(target_memory_id);

-- Weight-filtered scans (skip very weak edges)
CREATE INDEX idx_assoc_weight_active
    ON association_edges(weight)
    WHERE weight > 0.1;

-- Curator: find edges due for pruning
CREATE INDEX idx_assoc_prune_candidates
    ON association_edges(weight, updated_at)
    WHERE weight < 0.05;
```

### Migration Path

If graph size exceeds 1M edges and recursive CTE performance degrades, the migration path is:

1. **Apache AGE** — PostgreSQL extension that adds Cypher query support. Same database, no new infrastructure. Evaluate first.
2. **Neo4j** — Dedicated graph DB. Only if AGE is insufficient. Requires cross-database query coordination.

The `storage` package abstracts graph operations behind a `GraphStore` interface, making the backend swappable.

## Alternatives Considered

### Neo4j (Dedicated Graph Database)
- **Pros:** Purpose-built for graph traversal. Cypher query language is more expressive than recursive CTEs. Native support for path finding, community detection, centrality algorithms. Scales to billions of edges.
- **Cons:** Third database to operate (alongside PostgreSQL and Weaviate). Cross-database joins required for every recall — after finding graph neighbors in Neo4j, must fetch metadata from PostgreSQL. Adds ~50ms round-trip latency per recall. Licensing: Community Edition lacks some enterprise features; Enterprise Edition is commercial. For < 1M edges, recursive CTEs in PostgreSQL are fast enough.

### Apache AGE (PostgreSQL Extension)
- **Pros:** Adds Cypher (openCypher) support directly in PostgreSQL. No new database to deploy. Can reference relational tables from Cypher queries. Open source.
- **Cons:** Extension maturity — AGE is relatively young (Apache Incubating, graduated 2023). Not available in all managed PostgreSQL offerings (rules out some cloud-managed Postgres). Adds schema complexity (AGE uses its own graph storage within PostgreSQL). For 3-hop bounded traversal, recursive CTEs are already performant and require no extension.

### Dgraph (Distributed Graph Database)
- **Pros:** Natively distributed, scales horizontally. GraphQL-native query language. Built-in full-text and regex search.
- **Cons:** Heavy operational footprint (distributed consensus, sharding). Overkill for expected graph size. Adds significant infrastructure complexity. Less mature ecosystem than Neo4j.

### In-Memory Graph (Application-Level)
- **Pros:** Fastest possible traversal — no database round trips. Can use optimized graph libraries (graphlib, ngraph).
- **Cons:** Memory-bound — the full graph must fit in application memory. Not durable — requires full reload on restart. Cannot be shared across multiple API server replicas without synchronization. Breaks the "PostgreSQL is system of record" design.

## Consequences

- **Positive:** No new database to deploy or operate. Graph queries can join directly with memory metadata in a single SQL statement. Transactional consistency for edge updates (weight changes are ACID). All existing PostgreSQL tooling (backups, monitoring, migrations) applies to graph data. The `GraphStore` interface allows future migration without application-level changes.
- **Negative:** Recursive CTEs are less expressive than Cypher for complex graph patterns (shortest path, community detection, PageRank). Performance of recursive CTEs degrades with high fan-out or deep traversal — mitigated by the 3-hop bound and weight filtering. Cannot leverage graph-specific algorithms without implementing them in application code.
- **Risks:** If the graph grows beyond 1M edges and queries exceed the 2-second latency budget for active recall, the PostgreSQL approach may need to be revisited. Mitigation: the `GraphStore` interface and the AGE/Neo4j migration path are documented. Monitor query latency (p99) as a key metric and set an alert at 1 second.

## Related

- ADR-001: Three-Layer Storage Architecture — PostgreSQL serves double duty as relational store and graph store
- ADR-005: Hebbian-Like Weight Dynamics — edge weights updated via SQL UPDATE statements in the same transaction as recall logging
- ADR-007: TypeScript as Primary Language — recursive CTE queries generated by the `storage` package using parameterized SQL
