# Review: Bound Memory-Recall Latency as a Persona's Memory Store Grows

- **Story**: `project-management/user-stories/US-098-bound-memory-recall-latency-at-scale.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The recall architecture in the Elixir backend (`backend/lib/noizu_prompt_lingua/domains/memory/recall.ex`) is genuinely sub-linear by design rather than a full scan: semantic paths are Weaviate named-vector ANN searches (`recall.ex:210-224`), the lexical fallback is a `pg_trgm` similarity query with `LIMIT` (`:226-238`), the association-graph walk is a recursive CTE hard-bounded by fan-out 8 / 3 hops (`:30-32, 141-180`), and RRF fusion caps candidates before hydration (`:77-94`). Quarantined memories never enter the recall path at all — they are written to a separate `Quarantine` table (`store.ex:157-167`), and recall's base scope filters to `state in [:active, :consolidating]` (`recall.ex:27, 261-263`). Graceful degradation exists (Weaviate outage collapses to the lexical arm, `recall.ex:194-206`; graph-walk failures return `[]`, `:170-179`), and per-query latency is logged to `RecallLog` with `duration_ms` and a path breakdown (`recall.ex:321-343`). What's missing is the measurement/enforcement half: no benchmark harness at the 1k/10k/100k checkpoints, no p95 latency bound defined or asserted, and no load test showing graceful degradation at scale. Recall correctness tests exist (`backend/test/noizu_prompt_lingua/domains/memory/store_recall_residual_test.exs` and related) but none are scale/latency tests. Confidence: high on architecture, medium on the scale claims.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| 100k+ memory store: p95 recall latency stays within an agreed bound, not linear in count | Partially Met | Sub-linear paths by construction (ANN `recall.ex:210-224`, bounded CTE `:141-180`, candidate caps `:40-41`); but no agreed bound, no p95 measurement, and no benchmark at 100k |
| Growth curve is sub-linear, measured at 1k/10k/100k checkpoints | Partially Met | Architecture supports it (Weaviate ANN + indexed trigram + bounded walk); no checkpoint benchmark harness or recorded curve exists — `duration_ms` in `RecallLog` (`recall.ex:321-343`) is the raw material but nothing aggregates it |
| Quarantined memories excluded without materially adding query cost | Met | Quarantine is a separate table (`store.ex:157-167`) so quarantined content is absent from the memory store entirely; recall scope filter `state in [:active, :consolidating]` (`recall.ex:27, 261-263`) costs nothing extra |
| Degrades gracefully near the bound (slower but relevant, not timeouts/empty) | Partially Met | Weaviate-unreachable fallback to lexical arm (`recall.ex:194-206`) and empty-graph tolerance (`:139, 170-179`) are real degradation paths, but they cover component outage — not latency-under-load behavior, which is untested |

## Gaps / Risks

- The story itself anticipates this shape ("may need decomposition into a follow-up spike") — the spike (benchmark at scale checkpoints, define the p95 bound) is exactly what's missing.
- `pg_trgm similarity > 0.03` over the whole table (`recall.ex:231`) is the one potentially linear path; it needs a GIN trigram index and a scale measurement to clear the criterion.
- `Sentinel.authorize/2` runs post-hydration (`recall.ex:92`); on very large candidate sets this is post-DB work — currently bounded by candidate caps, but worth watching.
- RecallLog writes are best-effort and unindexed for latency analytics — aggregating p95 across a fleet would need a rollup.

## BDD Scenario

```gherkin
Feature: Bounded memory-recall latency at scale

  Scenario: Recall on a 100k-memory persona
    Given a persona's memory store holds 100,000+ active memories
    When a recall query runs
    Then p95 latency is within the agreed bound
    # Today: PARTIAL — architecture is ANN-based and bounded, but no benchmark
    # or p95 gate exists to demonstrate it.

  Scenario: Latency curve across growth checkpoints
    When recall latency is measured at 1k, 10k, and 100k stored memories
    Then the curve is sub-linear (not proportional to store size)

  Scenario: Quarantined memories never surface
    Given a memory was quarantined by the injection guard (store.ex:35-37)
    When a normal recall query runs
    Then the quarantined entry is absent from results
    And the exclusion added no measurable query cost
    # Today: MET — quarantine rows live outside the memory table entirely.

  Scenario: Vector store outage under load
    Given Weaviate is unreachable
    When a recall query runs
    Then results still return via the pg_trgm lexical fallback
    Rather than timing out or returning empty results
    # Today: MET at the code level (recall.ex:194-206); untested under load.
```
