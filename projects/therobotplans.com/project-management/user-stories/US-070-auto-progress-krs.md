---
id: US-070
title: "Key Results auto-progress from linked item completion"
personas: [maya-chen]
domain: goals
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want Key Results to automatically update their progress based on linked item completion so that my goals stay current without manual check-ins.

## Acceptance Criteria

- [ ] Key Results with countable targets (e.g., "Ship 5 features") auto-increment as linked items reach "done" status
- [ ] Key Results with percentage targets compute progress from the ratio of completed-to-total linked items
- [ ] Manual override is available for KRs where auto-progress does not capture the full picture
- [ ] Progress history is tracked: each auto-update is logged with timestamp and triggering item
- [ ] Dashboard shows KRs with stale progress (no updates in configurable period) as at-risk

## Notes

This is the bridge between daily work and strategic goals. Maya works alone, so she cannot afford manual OKR updates. The scale-free model makes this natural: items linked to a KR are just items, regardless of whether they are bugs, todos, or epics. Consider supporting formula-based KRs (e.g., "reduce p95 latency below 200ms") that pull from external metrics in a future phase.
