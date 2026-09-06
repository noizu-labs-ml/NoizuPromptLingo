# Review: Reinforce or de-emphasize a memory association

- **Story**: `project-management/user-stories/US-027-reinforce-or-deemphasize-a-memory-association.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No memory-association subsystem exists in the codebase. Greps for `association`, `reinforce`, `deemphasize`/`de_emphasize`, `edge_weight`, `memory`, and `recall` across `src/` and `tests/` return no association-graph code; the only "memory" hits are unrelated (`inference_cache.py`, browser capture caching). There is no memory storage table, no weight model, no recall traversal, and no decay mechanism. The persona package (`src/npl_persona/`) is a file-based persona definition library with no graph memory either.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Reinforcing an existing edge increases its weight, bounded at max, reflected in later recalls | Not Met | no evidence found |
| De-emphasizing decreases weight bounded at min, without deleting the edge | Not Met | no evidence found |
| Reinforcing between unconnected memories creates a new edge with initial weight | Not Met | no evidence found |
| Edges decayed below threshold are deprioritized/excluded from recall traversal | Not Met | no evidence found |

## Gaps / Risks

- Entire epic prerequisite chain (US-025/US-026 association graph) is also absent — this story cannot be started incrementally.
- Weight-bounding and decay-threshold semantics will need a storage design decision (new tables + traversal queries) before any implementation.

## BDD Scenario

```gherkin
Feature: Reinforce or de-emphasize memory associations

  Scenario: Reinforce an association
    Given two memories exist with an association edge of weight 0.4
    When the agent reinforces the edge
    Then the edge weight increases (bounded at maximum)
    And subsequent association-based recalls rank the pair higher

  Scenario: De-emphasize an association
    Given two memories exist with an association edge
    When the agent de-emphasizes the edge
    Then the weight decreases toward the minimum without deleting the edge
    And decayed edges are excluded from later recall traversals
```

(Scenario describes target behavior — none of it is executable today.)
