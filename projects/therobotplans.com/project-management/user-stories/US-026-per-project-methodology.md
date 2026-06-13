---
id: US-026
title: "Per-project methodology independence"
personas: [james-oduya]
domain: projects
priority: medium
mvp_phase: "v0.2"
---

## User Story

As a **James Oduya (Agency Owner)**, I want each project to use a different methodology without affecting others so that I can run a Scrum project for one client and a Waterfall project for another within the same workspace.

## Acceptance Criteria

- [ ] Each project stores its methodology configuration independently — changing one project's workflow states, columns, or cadence has zero effect on other projects
- [ ] The portfolio dashboard correctly aggregates health metrics across mixed-methodology projects using normalized indicators (e.g., "on track" means meeting sprint goals for Scrum and hitting milestones for Waterfall)
- [ ] Cross-project views (e.g., "my assigned items") render items with methodology-appropriate status labels rather than forcing a single status taxonomy
- [ ] Team members who work across projects see methodology-specific UI affordances automatically when switching between projects (Kanban board for one, Gantt chart for another)

## Notes

This is essential for agency use cases where each client may dictate their preferred methodology. The platform should never force a single workflow model at the workspace level. Reporting across mixed methodologies is the hard design problem here — the portfolio dashboard needs to abstract away methodology differences into comparable health signals.
