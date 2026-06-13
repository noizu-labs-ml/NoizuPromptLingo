---
id: US-072
title: "Visualize goal alignment across teams and individuals"
personas: [james-oduya]
domain: goals
priority: low
mvp_phase: "v0.4"
---

## User Story

As a **James Oduya (Agency Owner)**, I want to visualize goal alignment across teams and individuals as a tree or graph so that I can identify misalignment, orphaned efforts, and coverage gaps across my agency.

## Acceptance Criteria

- [ ] Alignment visualization renders as an interactive tree/graph showing Objectives, Key Results, and linked work items
- [ ] Nodes are color-coded by status (on-track, at-risk, off-track, not-started)
- [ ] Clicking a node navigates to the item detail view; hovering shows a summary tooltip
- [ ] Orphan detection highlights teams or individuals with work not linked to any OKR
- [ ] Visualization supports filtering by team, project, time period, and hierarchy level

## Notes

James manages multiple client projects and internal teams. The alignment viz is his portfolio-level strategic view. Consider both a sunburst/radial layout (good for hierarchy) and a force-directed graph (good for cross-cutting alignment). Performance must handle 200+ nodes without degradation. This is a read-heavy feature; optimize for fast rendering over real-time updates.
