---
id: US-061
title: "Session Quick-Reference Search Mode"
slug: "quick-reference-search-mode"
personas: [P-002]
epic: "Session Companion"
priority: "must-have"
complexity: "M"
tags: [session, search, quick-reference, gm, lookup]
---

# US-061: Session Quick-Reference Search Mode

## User Story

**As a** veteran game master (P-002),
**I want to** quickly search my canon during a live session without navigating away from my current view,
**So that** I can answer player questions about lore in seconds without breaking the flow of the game.

## Acceptance Criteria

- [ ] Given I am in the Session Companion view, when I activate quick-reference mode (keyboard shortcut or dedicated search bar), then a focused search overlay appears that queries entry names, aliases, and tags across the active universe.
- [ ] Given I type 3 or more characters in quick-reference mode, when results load, then matching entries are displayed within 500ms with name, type icon, and a 2-line summary excerpt.
- [ ] Given I select a result in quick-reference mode, when the entry detail opens, then it opens in a read-only side panel that does not navigate away from my current session view, and I can dismiss it with Escape.
- [ ] Given I am mid-session, when I use quick-reference search, then recently accessed entries in this session are pinned at the top of the results list for faster re-access.

## Notes

Quick-reference mode is designed for sub-second, eyes-half-on-the-table lookup. Depends on US-069 (full-text search). Related: US-062 (improvise mode), US-065 (player-facing view).
