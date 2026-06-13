---
id: US-021
title: "Create a project with a chosen methodology"
personas: [sarah-kim]
domain: projects
priority: high
mvp_phase: "v0.1"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want to create a new project and select a methodology (Scrum, Kanban, Waterfall, or custom) so that my team's workflow matches the nature of the work from day one.

## Acceptance Criteria

- [ ] Project creation wizard offers methodology selection as a required step with Scrum, Kanban, Waterfall, and Custom as options
- [ ] Selecting a methodology auto-provisions the corresponding workflow states, item types, and board configuration (e.g., Scrum gets Sprint Backlog/In Progress/Review/Done; Kanban gets configurable columns with WIP limits)
- [ ] Custom methodology allows defining arbitrary workflow states, transitions, and optional ceremonies
- [ ] The chosen methodology is displayed on the project dashboard and can be changed later with a migration prompt for in-flight items
- [ ] Scale-free items (todos, tasks, bugs, epics) are available regardless of methodology — methodology only governs workflow and cadence

## Notes

Methodology selection should feel like a lightweight choice, not a commitment ceremony. The platform should make it easy to switch later. Consider showing a brief preview of what each methodology provides (board layout, ceremonies, metrics) during selection. Custom methodology is the escape hatch for teams that blend approaches.
