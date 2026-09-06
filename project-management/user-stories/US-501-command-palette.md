---
id: US-501
title: "Reach any destination or action from a keyboard command palette"
slug: "command-palette"
personas: [P-001, P-003]
epic: "UX Foundations"
priority: "must-have"
complexity: "M"
tags: [ux, navigation, keyboard, shell, command-palette]
---

# US-501: Reach any destination or action from a keyboard command palette

## User Story

**As a** Harness Operator (P-001) working alongside a Delivery Lead (P-003) across sessions, boards, chat, files, and data,
**I want to** open a command palette with `⌘K` that offers navigation targets, contextual actions, and my recent destinations,
**So that** the roughly thirty secondary destinations the icon rail cannot show stay one keystroke away instead of buried in an accordion.

## Acceptance Criteria

- [ ] Given any authenticated app screen, when the user presses `⌘K` (or `Ctrl+K`), then the palette opens with focus in its input, traps focus while open, and restores focus to the prior element on `Esc`.
- [ ] Given the palette is open with an empty query, when it renders, then it lists recent destinations first followed by the primary rail destinations, and arrow keys plus `Enter` activate a result without touching the mouse.
- [ ] Given a screen that registers actions with the palette provider registry, when that screen is active and the palette opens, then those screen-contributed actions appear in an actions group and are gone once the user navigates away.
- [ ] Given a query that matches nothing, when results are computed, then the palette shows zero-results guidance naming what is searchable rather than an empty list.
- [ ] Given an action the caller is not permitted to invoke, when results render, then the action is omitted or disabled with generic denial copy that never names a missing scope (decision D2).

## Notes

Plan sections: UX-PLAN §2.1 (shell decision), §3.2 screen 50, §4 (`CommandPalette` component contract), §6 (shortcut model), §9 (story re-baseline). Backend readiness is **R** — the palette is client-only. Port the existing implementation from the orphaned kit at `frontend/components/` rather than authoring new (decision D6). Related stories: US-503 (breadcrumbs) and US-502 (global search) complete the navigation triad introduced by the shell swap; US-091/US-092 own the keyboard and live-region conventions this palette must not contradict; US-506 supplies the denial copy for gated actions.
