---
id: US-001
title: "Unified today dashboard"
personas: [maya-chen, raj-patel]
domain: today-view
priority: high
mvp_phase: "v0.1"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want to view a unified today dashboard combining personal items, team tasks, agent activity, and ops alerts so that I can start my day with a single glance instead of checking five different tools.

## Acceptance Criteria

- [ ] Dashboard renders a single-page view with sections for personal items, work tasks, active agent summaries, and ops alerts
- [ ] Items from all domains (personal, project, ops) appear in a unified priority-sorted list with source indicators
- [ ] Dashboard loads in under 2 seconds with up to 200 active items across all sources
- [ ] Keyboard shortcut (e.g., `g t`) navigates to today view from anywhere in the app
- [ ] Empty-state guidance appears for new users explaining how items flow into the today view

## Notes

This is the anchor screen of the entire platform. It must feel like a command center, not a cluttered aggregation page. The scale-free data model means a "todo" and an "epic" are the same entity at different zoom levels — the today view should surface the leaf-level actionable items regardless of their hierarchy depth. Dark mode is a hard requirement for Maya's persona.
