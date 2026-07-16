---
id: US-090
title: "Quarantine Flagged Content at Memory Ingest"
slug: "memory-flagged-quarantine-at-ingest"
personas: [P-002, P-006]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "M"
tags: [memory, moderation, security, quarantine]
---

# US-090: Quarantine Flagged Content at Memory Ingest

## User Story

**As** Ilya Petrov, the Platform Administrator (P-006),
**I want to** have content that trips moderation/safety heuristics quarantined at the moment the Autonomous Coding Agent (P-002) writes it to persona memory,
**So that** flagged content never enters an agent's active recall context while remaining auditable rather than silently dropped.

## Acceptance Criteria

- [ ] Given an agent submits a memory write whose content matches a quarantine heuristic, when ingest runs, then the memory is stored in a quarantined state and excluded from normal recall queries.
- [ ] Given a memory is quarantined, when the submitting agent (P-002) receives the ingest response, then it is told the write was quarantined rather than accepted as if it succeeded normally.
- [ ] Given a memory is quarantined, when Ilya (P-006) reviews the quarantine queue, then he can see the flagged content, the trigger reason, and can either release it to normal memory or permanently delete it.
- [ ] Given a quarantined memory is released by an administrator, when the persona's next recall query runs, then the released memory is eligible for retrieval like any other memory.

## Notes

Distinct from a hard rejection — quarantine preserves content for human review rather than losing it outright. Interacts with US-098: quarantined memories must be excluded cheaply at scale, not scanned per query.
