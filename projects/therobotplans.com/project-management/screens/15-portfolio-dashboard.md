# Multi-Project Portfolio Dashboard

| Field | Value |
|-------|-------|
| **ID** | `portfolio-dashboard` |
| **Type** | Dashboard |
| **Category** | Project Management |
| **User Stories** | US-025, US-026, US-031 |

## Description

Overview of all active projects as cards with health indicators, methodology labels, deadline alerts, cross-project dependencies, and aggregate statistics. The command center for multi-project operators.

## Key Components

- **Project cards** — One card per project showing name, status, progress bar
- **Health indicator** — Green/yellow/red based on velocity, blockers, deadline proximity
- **Methodology badge** — Shows project methodology (Scrum, Kanban, etc.)
- **Deadline countdowns** — Next milestone with days remaining
- **Dependency graph link** — Quick-access to cross-project dependency view
- **Filter/sort bar** — Filter by health, methodology, team; sort by deadline, activity
- **Summary bar** — Aggregate stats (total items, completion rate, active sprints)
- **Risk score** — Composite risk metric per project

## Interactions

- Click card to navigate to project board
- Click health indicator for detail breakdown
- Sort/filter to focus on at-risk projects
- Dependency graph link opens the cross-project visualization
- Create new project from this view

## Navigation

- Accessible from: Main nav (portfolio icon)
- Links to: Project boards, Dependency Graph, Project Creation Wizard, Gantt View
