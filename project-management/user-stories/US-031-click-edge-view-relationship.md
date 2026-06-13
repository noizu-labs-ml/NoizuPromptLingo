---
id: US-031
title: "Click Edge to View Relationship"
slug: "click-edge-view-relationship"
personas: [P-001, P-002, P-003]
epic: "Knowledge Graph"
priority: "should-have"
complexity: "M"
tags: [knowledge-graph, relationship, edge-interaction, canon]
---

# US-031: Click Edge to View Relationship

## User Story

**As a** narrative designer auditing relationship consistency (P-003),
**I want to** click on a graph edge to see the full details of the relationship it represents,
**So that** I can verify relationship labels, directionality, and any attached notes without leaving the graph view.

## Acceptance Criteria

- [ ] Given the knowledge graph is displayed, when I click on an edge between two nodes, then a popover appears showing the relationship type, direction, and any descriptive notes.
- [ ] Given an edge popover is open, when I click "Edit Relationship", then I am navigated to the relationship editing interface for that canon entry pair.
- [ ] Given an edge has a bidirectional relationship, when the popover opens, then both directions of the relationship are displayed (e.g., "Elena allies with Faction X" and "Faction X allies with Elena").
- [ ] Given an edge popover is open, when I hover over the connected nodes, then they are highlighted in the graph to reinforce context.
- [ ] Given a very short edge (dense graph area), when I click on it, then the click target area is at least 8px wide to ensure usability.

## Notes

Depends on US-026, US-030. Edge data must be part of the graph payload. Relationship editing may be deferred to a later sprint — the popover display is the core AC here.
