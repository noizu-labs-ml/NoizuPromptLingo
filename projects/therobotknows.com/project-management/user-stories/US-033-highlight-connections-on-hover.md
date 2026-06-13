---
id: US-033
title: "Highlight Connections on Hover"
slug: "highlight-connections-on-hover"
personas: [P-001, P-002, P-004, P-008]
epic: "Knowledge Graph"
priority: "must-have"
complexity: "S"
tags: [knowledge-graph, hover, highlight, connections, ux]
---

# US-033: Highlight Connections on Hover

## User Story

**As a** fiction podcaster tracking character relationships across 50 episodes (P-004),
**I want to** hover over a node to highlight all of its direct connections,
**So that** I can immediately see which other entries a character or location is directly related to without clicking through each one.

## Acceptance Criteria

- [ ] Given the knowledge graph is displayed, when I hover over a node, then that node and all directly connected nodes are highlighted, and all other nodes are dimmed to low opacity.
- [ ] Given I am hovering over a node, when the highlight state is active, then connected edges are also highlighted (and colored distinctly from non-connected edges).
- [ ] Given I move my cursor off a node, when hover ends, then the graph returns to its normal state within 150ms.
- [ ] Given a node with more than 20 connections, when I hover over it, then all 20+ connections are highlighted without performance degradation.
- [ ] Given I am hovering over a node, when a label tooltip appears, then it shows the entry name and type within 300ms of hover start.

## Notes

Depends on US-026. This is a core usability feature for dense graphs. Dimming opacity on non-connected nodes should target ~15–20% opacity to maintain graph structure visibility. Related: US-030 (click to open entry).
