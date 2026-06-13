---
id: US-069
title: "Multi-level OKR hierarchy with roll-up"
personas: [sarah-kim]
domain: goals
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want to create a multi-level OKR hierarchy (company, team, individual) with automatic roll-up so that I can see how my team's work aligns to organizational objectives without manually aggregating progress.

## Acceptance Criteria

- [ ] OKRs support at least three hierarchy levels: organization, team, and individual
- [ ] Child Key Results can be linked to parent Objectives with automatic progress roll-up
- [ ] Roll-up calculation is configurable: weighted average, min-of-children, or custom formula
- [ ] Hierarchy is navigable as both a tree view and a flat filtered list
- [ ] Circular dependency detection prevents linking loops in the OKR graph

## Notes

In the scale-free model, an OKR is just an item with goal semantics: Objectives are parent items, Key Results are children with measurable targets. Roll-up is item aggregation. This means personal todos that link to a KR also contribute to organizational progress. Sarah needs this to report upward while her team works in their own context.
