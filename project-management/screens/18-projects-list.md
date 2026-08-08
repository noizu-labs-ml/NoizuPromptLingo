# Projects List

| Field | Value |
|-------|-------|
| **ID** | `projects-list` |
| **Type** | Primary |
| **Category** | Core Work |
| **User Stories** | None — structural listing screen; project-scoped work is covered by stories on Sessions (screens 20-21), Ticket Field/Type Admin (27), and Project Detail (19) |

## Description

Org-scoped listing of all projects at `/app/[orgId]/projects` — the container entities that sessions, tickets, and custom fields/types scope to.

## Key Components

- **Project Card Grid** — one card per project with status and activity summary
- **Create Project Button** — launches the new-project creation form
- **Project Search/Filter Bar** — narrows by name or status (active/archived)
- **Archived Project Toggle** — shows/hides archived projects

## Interactions

- User clicks a project card → routes to Project Detail (19)
- User clicks Create Project Button → inline form creates a project and routes into it

## Navigation

- Accessible from: Org Dashboard (17) quick links
- Links to: Project Detail (19)
