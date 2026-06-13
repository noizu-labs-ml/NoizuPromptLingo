---
id: US-022
title: "Kanban board view with drag-and-drop"
personas: [maya-chen, sarah-kim]
domain: projects
priority: high
mvp_phase: "v0.1"
---

## User Story

As a **Maya Chen (Solo Dev)** or **Sarah Kim (Eng Lead)**, I want to view my project items as a Kanban board and drag-and-drop them between columns so that I can visually manage workflow state without opening individual items.

## Acceptance Criteria

- [ ] Board renders columns matching the project's workflow states with item cards showing title, assignee (human or agent), priority indicator, and item type badge
- [ ] Drag-and-drop moves an item between columns and persists the state transition immediately with optimistic UI update
- [ ] Columns display WIP limits (if configured) and visually indicate when a column exceeds its limit
- [ ] Keyboard-first navigation is supported: arrow keys to move between cards/columns, Enter to open, shortcut key to move item to next/previous column
- [ ] Board respects active filters (assignee, label, priority, item type) and persists filter state per user per project

## Notes

This is the primary visual interface for day-to-day work. Cards should be compact but scannable — avoid information overload. Dark mode must be fully supported since Maya lives in it. Consider swimlane grouping as a future enhancement (by assignee, by epic, by priority). Agent-assigned items should have a distinct visual indicator so it's clear at a glance what's human-driven vs. agent-driven.
