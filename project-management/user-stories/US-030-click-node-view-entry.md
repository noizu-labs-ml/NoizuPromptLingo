---
id: US-030
title: "Click Node to View Entry"
slug: "click-node-view-entry"
personas: [P-001, P-002, P-003, P-004, P-005, P-008]
epic: "Knowledge Graph"
priority: "must-have"
complexity: "S"
tags: [knowledge-graph, navigation, entry-detail, node-interaction]
---

# US-030: Click Node to View Entry

## User Story

**As a** webcomic creator referencing canon during scripting (P-008),
**I want to** click on any node in the knowledge graph to open its canon entry,
**So that** I can quickly access entry details while visually exploring character and location relationships.

## Acceptance Criteria

- [ ] Given the knowledge graph is displayed, when I single-click a node, then a side panel or popover opens showing the entry's title, type, and a summary/excerpt.
- [ ] Given the node popover is open, when I click "Open Full Entry", then I am navigated to the full Canon Editor view for that entry.
- [ ] Given I click a node, when the popover opens, then it shows direct relationship labels (e.g., "Allied with: Faction X", "Located in: Region Y").
- [ ] Given a node popover is open, when I click anywhere on the canvas background, then the popover closes without navigating away.
- [ ] Given I am on the graph and click a node, when the popover opens, then it does so within 200ms without re-fetching data from the server.

## Notes

Depends on US-026. Entry data should be pre-loaded with the graph payload to enable sub-200ms popover performance. Related: US-031 (click edge to see relationship).
