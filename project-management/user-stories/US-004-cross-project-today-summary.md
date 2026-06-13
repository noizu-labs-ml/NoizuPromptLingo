---
id: US-004
title: "Cross-project today summary for multi-client work"
personas: [diana-kovacs]
domain: today-view
priority: medium
mvp_phase: "v0.2"
---

## User Story

As a **Diana Kovacs (Freelance Multi-Client)**, I want to see a cross-project summary on my today view for all active client projects so that I can balance my time across clients and never miss a deadline.

## Acceptance Criteria

- [ ] Today view groups items by project/client with a collapsible header showing project name, item count, and nearest deadline
- [ ] A per-project time allocation indicator shows planned vs. actual hours for today (integrates with time tracking)
- [ ] Items from inactive or paused projects are excluded by default with a toggle to include them
- [ ] Cross-project deadline conflicts are highlighted with a visual warning when two clients have overlapping due dates
- [ ] Filtering by client/project is available without leaving the today view

## Notes

Diana manages 3-5 concurrent client projects. The today view must prevent context collapse where all items blur together. The MCP integration (her primary tool connector) means items may arrive from external systems — the summary should handle items regardless of origin. Consider a mini Gantt or timeline row per project.
