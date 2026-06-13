# Cross-Project Dependency Graph

| Field | Value |
|-------|-------|
| **ID** | `cross-project-dependencies` |
| **Type** | Primary |
| **Category** | Project Management |
| **User Stories** | US-031 |

## Description

Visual graph showing inter-project dependency links, blocked chains, and critical paths spanning multiple projects. Highlights items blocked by work in other projects.

## Key Components

- **Dependency graph visualization** — Interactive node-link graph of cross-project dependencies
- **Blocked chain highlights** — Red paths showing blocked dependency chains
- **Notification triggers** — Configure alerts when upstream dependencies slip
- **Filter by project** — Focus on dependencies involving specific projects
- **Confirmation workflow** — Both sides must confirm a cross-project dependency

## Interactions

- Zoom/pan on the graph
- Click nodes to navigate to item detail
- Filter to focus on specific projects or blocked paths
- Create new dependencies via drag-link
- Red highlights auto-update when dependencies resolve

## Navigation

- Accessible from: Portfolio Dashboard (dependency icon), Project nav
- Links to: Item detail (in any project), Portfolio Dashboard
