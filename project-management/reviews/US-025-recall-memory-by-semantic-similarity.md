# Review: Recall Memory by Semantic Similarity

- **Story**: `project-management/user-stories/US-025-recall-memory-by-semantic-similarity.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented in the Elixir backend's memory domain on Weaviate. `Recall.active` (`backend/lib/noizu_prompt_lingua/domains/memory/recall.ex:69`) fuses four text vectors **plus** the 7-dimensional emotional vector, adds an association-graph walk, and merges results with **reciprocal-rank fusion (RRF)**, with a `pg_trgm` Postgres fallback when the vector store is unavailable. Sentinel scoping/authorization is applied to results, so recall respects persona/org boundaries. An MCP-facing tool exists (`backend/lib/noizu_prompt_lingua/domains/memory/tools/recall.ex`), making the capability reachable by agents. Weaviate named-vector configuration (4 text + 7-d emotional VAD+hormones) backs the embedding side. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Agent can query memories by natural-language similarity | Met | `recall.ex:69` multi-vector fusion query |
| Results ranked meaningfully across modalities | Met | RRF fusion of 4 text vectors + emotional vector + graph walk (`recall.ex:69`) |
| Recall is scoped to authorized context (persona/org) | Met | Sentinel authorization applied in the recall path (`recall.ex:69`) |
| Degrades gracefully without vector store | Met | `pg_trgm` fallback in `recall.ex` |
| Exposed as an agent-callable tool | Met | `backend/lib/noizu_prompt_lingua/domains/memory/tools/recall.ex` |

## Gaps / Risks

- Fallback trigram search is lexical — semantic quality degrades when Weaviate is down (acceptable, documented).
- RRF constant and vector weighting are hard-coded; tuning hooks may be needed as corpus grows.

## BDD Scenario

```gherkin
Feature: Semantic memory recall
  Scenario: Agent recalls relevant past context
    Given memories embedded across four text vectors
    When the agent queries recall with a natural-language question
    Then Weaviate near-vector search runs on all text vectors plus the emotional vector
    And graph-associated memories boost relevance via RRF
    And only Sentinel-authorized memories are returned
  Scenario: Vector store unavailable
    When Weaviate is unreachable
    Then pg_trgm lexical fallback returns approximate matches
```
