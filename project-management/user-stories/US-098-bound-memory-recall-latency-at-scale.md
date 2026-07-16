---
id: US-098
title: "Bound Memory-Recall Latency as a Persona's Memory Store Grows"
slug: "bound-memory-recall-latency-at-scale"
personas: [P-002]
epic: "Performance & Scale"
priority: "should-have"
complexity: "L"
tags: [performance, memory, scale, latency]
---

# US-098: Bound Memory-Recall Latency as a Persona's Memory Store Grows

## User Story

**As** Sable, the Autonomous Coding Agent (P-002),
**I want to** have my memory-recall queries stay fast even after months of accumulated persona memory,
**So that** long-lived agent sessions don't get progressively slower exactly when accumulated context is most valuable.

## Acceptance Criteria

- [ ] Given a persona's memory store has grown to 100,000-plus stored memories, when a recall query runs, then p95 latency stays within an agreed bound rather than scaling linearly with total memory count.
- [ ] Given the memory store grows over time, when recall latency is measured at multiple size checkpoints (1k, 10k, 100k memories), then the growth curve is sub-linear rather than a full linear scan.
- [ ] Given quarantined memories exist in the store per US-090, when a normal recall query runs, then quarantined entries are excluded without materially adding to query cost.
- [ ] Given recall latency approaches the bound under load, when this happens, then it degrades gracefully with slightly slower but still-relevant results rather than timing out or returning empty results.

## Notes

Sized L — likely requires an indexing or ANN-search strategy change, not just query tuning, and may need decomposition into a follow-up spike if the current store can't meet the bound without a storage-layer change. Depends on US-090's quarantine flag being cheap to filter on.
