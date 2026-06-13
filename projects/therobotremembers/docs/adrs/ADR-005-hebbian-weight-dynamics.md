---
id: ADR-005
title: "Hebbian-Like Weight Dynamics for Associations"
status: accepted
date: 2026-05-27
---

# ADR-005: Hebbian-Like Weight Dynamics for Associations

## Context

The association graph is the backbone of the recall system. Edges connect memories along multiple dimensions (semantic, emotional, temporal, causal, co-occurrence, synthetic). Each edge carries a weight (0.0 to 1.0) that represents the strength of the association.

These weights must be dynamic — they should evolve based on actual usage patterns:

- **Associations that lead to useful recall should strengthen.** If the path A -> B -> C consistently surfaces relevant memories, the edges A-B and B-C should gain weight.
- **Unused associations should weaken.** If an edge was created but never participates in a recall path, it should decay toward pruning.
- **Co-activated associations should strengthen.** If memories A and B are consistently recalled together (even if the query didn't target both), the edge between them should strengthen — "memories that fire together wire together."

The weight dynamics directly affect recall quality: strong edges are traversed preferentially, weak edges are skipped by the Recall Agent's `min_edge_weight` filter. Getting the dynamics wrong means either a brittle graph (too aggressive decay) or a noisy graph (everything connected to everything at medium weight).

## Decision

Implement a three-mechanism weight dynamics model:

### 1. Exponential Decay

All edge weights decay over time unless reinforced. The decay function mirrors memory decay (ADR architecture, section 9.1) but with a longer half-life:

```
edge_weight(t) = current_weight * e^(-lambda * t)
where:
  lambda = ln(2) / half_life
  t = hours since last reinforcement
  half_life = 720 hours (30 days) for all edge types
```

Edges below `prune_threshold` (default 0.05) for longer than `grace_period` (default 72 hours) are pruned by the Curator.

### 2. Multiplicative Reinforcement

When an edge participates in a successful recall path (the recall was used and not denforced):

```
new_weight = min(1.0, current_weight + edge_boost)
edge_boost = 0.1 * recall_relevance_score
```

Where `recall_relevance_score` is the final relevance score (0.0-1.0) of the memory that the edge led to. Higher-relevance recalls produce stronger reinforcement. This is multiplicative in practice because frequently recalled edges accumulate boost faster than they decay.

### 3. Hebbian Co-Activation

When two memories are recalled in the same recall session — regardless of whether the query targeted both:

```
co_recall_boost = 0.05 * min(relevance_a, relevance_b)
```

If an edge already exists between A and B, apply the boost. If no edge exists, create one with `edge_type: co-occurrence` and initial weight equal to `co_recall_boost`.

This implements the Hebbian principle: memories that are consistently co-activated develop associations, and those associations strengthen with repetition. Over time, the graph develops emergent structure that reflects actual usage patterns.

### Weight Update Rules Summary

| Event | Effect on Edge Weight | Formula |
|-------|----------------------|---------|
| Time passes | Decay | `w * e^(-lambda * t)` |
| Edge used in recall | Strengthen | `min(1.0, w + 0.1 * relevance)` |
| Memories co-recalled | Strengthen (or create) | `min(1.0, w + 0.05 * min(rel_a, rel_b))` |
| Edge source/target denforced | Weaken | `max(0.0, w - 0.15)` |
| Below threshold for grace period | Prune | Edge deleted (tombstone) |

### Tunables

All parameters are exposed as ConfigMap values (see Implementation Guide):

- `EDGE_DECAY_HALF_LIFE_HOURS` (default: 720)
- `EDGE_REINFORCE_BASE_BOOST` (default: 0.1)
- `EDGE_CORECALL_BASE_BOOST` (default: 0.05)
- `EDGE_DENFORCE_PENALTY` (default: 0.15)
- `EDGE_PRUNE_THRESHOLD` (default: 0.05)
- `EDGE_PRUNE_GRACE_HOURS` (default: 72)

## Alternatives Considered

### Static Weights
- **Pros:** Simplest possible model. Set weight at creation time based on similarity scores, never change. Deterministic — no surprising graph evolution.
- **Cons:** The graph never learns. An initially low-weight edge that turns out to be critically useful stays low-weight forever. Useless edges never get pruned. The system cannot adapt to actual usage patterns.

### Simple LRU (Least Recently Used)
- **Pros:** Easy to implement — track last-access time, evict oldest. Well-understood caching strategy.
- **Cons:** LRU is binary (keep or evict) — no graduated weight. A memory recalled once 5 minutes ago has the same weight as one recalled 100 times 5 minutes ago. Cannot model the "frequently useful" vs. "accessed once by accident" distinction.

### Collaborative Filtering
- **Pros:** Could learn association patterns across multiple agent instances or users. "Agents who found memory A useful also found memory B useful."
- **Cons:** Requires multi-tenant training data that does not exist at launch. Cold start problem is severe. The emotional/contextual dimensions make collaborative filtering non-trivial — two agents' "frustration at 2 AM" memories are personal and not transferable.

### Neural Weight Learning (Learned Embeddings for Edges)
- **Pros:** Could learn complex, non-linear weight dynamics that the hand-crafted model misses. Potentially optimal long-term.
- **Cons:** Requires training data (successful vs. unsuccessful recalls with associated graph states) that does not exist at launch. Opaque — cannot explain why an edge has a given weight. Tuning requires ML expertise, not just parameter adjustment. Overkill for the expected graph size (< 1M edges at launch).

## Consequences

- **Positive:** The graph evolves to reflect actual usage. Frequently useful associations strengthen; useless ones decay. Hebbian co-activation creates emergent structure that was not explicitly programmed. All parameters are tunable via ConfigMap without code changes. The model is interpretable — an operator can look at an edge and understand why it has its current weight.
- **Negative:** Weight dynamics introduce temporal complexity — the graph's behavior depends on its history, not just its current state. Debugging "why did this edge decay?" requires reconstructing the reinforcement history. The Hebbian mechanism can create "echo chamber" effects where frequently co-recalled memories reinforce each other to the exclusion of novel associations.
- **Risks:** Runaway reinforcement: a popular recall path gets increasingly dominant, starving other paths. Mitigation: cap reinforcement at 1.0 and ensure the Dreamer periodically injects speculative edges to diversify the graph. Decay too aggressive: valuable but infrequently used edges are pruned before they prove useful. Mitigation: the Curator checks for high-weight neighbors before pruning (see architecture section 9.5).

## Related

- ADR-003: Multi-Agent Ensemble — the Weaver implements weight dynamics, the Curator implements pruning, and they operate in designed tension
- ADR-006: Graph Storage in PostgreSQL — edge weights stored in `association_edges.weight` column
- ADR-002: Emotional Metadata Model — emotional similarity is one factor in initial edge weight assignment
