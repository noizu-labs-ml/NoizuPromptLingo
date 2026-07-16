---
id: US-027
title: "Reinforce or de-emphasize a memory association"
slug: "reinforce-or-deemphasize-a-memory-association"
personas: [P-002]
epic: "Agent Personas & Memory"
priority: "should-have"
complexity: "M"
tags: [memory, associations, learning, graph]
---

# US-027: Reinforce or de-emphasize a memory association

## User Story

**As the** Autonomous Coding Agent (P-002),
**I want to** strengthen or weaken the weighted association edge between two related memories,
**So that** my recall quality improves over time as I learn which connections actually matter.

## Acceptance Criteria

- [ ] Given two existing memories with an association edge between them, when Sable reinforces that edge, then its weight increases, bounded at a defined maximum, and the change is reflected in subsequent association-based recalls.
- [ ] Given two existing memories with an association edge, when Sable de-emphasizes it, then its weight decreases, bounded at a defined minimum, rather than the edge being deleted outright.
- [ ] Given two memories with no existing association, when Sable attempts to reinforce a connection between them, then a new association edge is created with an initial weight instead of the call failing.
- [ ] Given an association edge whose weight decays below a minimum threshold, when a recall traversal runs, then that edge is effectively deprioritized or excluded from results without requiring manual deletion.

## Notes

Complexity M — weight bounds and decay-threshold behavior need care to avoid runaway growth or orphaned edges. Builds on the association graph implied by US-025 and US-026.
