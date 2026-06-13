---
id: US-012
title: "Universe Overview Dashboard"
slug: "universe-overview-dashboard"
personas: [P-001, P-004]
epic: "Universe Management"
priority: "must-have"
complexity: "M"
tags: [universe, dashboard, overview, navigation]
---

# US-012: Universe Overview Dashboard

## User Story

**As a** fiction podcaster (P-004),
**I want to** see a summary dashboard for each of my universes,
**So that** I can quickly assess the state of my lore, spot gaps, and navigate to the area I need.

## Acceptance Criteria

- [ ] Given I select a universe from my Dashboard, when the Universe Overview loads, then I see: entry counts by type (characters, locations, events, etc.), recent activity feed (last 10 edits), consistency score (if a check has been run), and quick-access buttons for Canon Editor, Knowledge Graph, and Generation Studio.
- [ ] Given the overview is displayed, when I click an entry type count (e.g., "12 Characters"), then I am taken to the Canon Editor filtered to that entry type.
- [ ] Given a consistency check has never been run, when the overview loads, then the consistency score shows "Not checked yet" with a prompt to run the checker.
- [ ] Given I have multiple universes, when I am on the overview for one, then a sidebar or breadcrumb allows switching to another universe without returning to the root Dashboard.

## Notes

Depends on US-009. Activity feed must be paginated (load more). Entry counts are live; they must not be stale by more than one navigation cycle. Related: US-010 (settings), US-013 (delete).
