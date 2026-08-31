# 02: Projects List

| Field | Value |
|-------|-------|
| ID | SCR-02 |
| Surface | web |
| Type | dashboard |
| Category | Discovery / Admin |
| Route / Entry | `/projects` |
| Primary Personas | P-005, P-001, P-006 |
| User Stories | US-070, US-071, US-061 |

## Description
Project-grouped overview of everything indexed, one card per project directory. The organizational home base — "everything in this project" — for engineering leads scanning across many repos and for power users jumping back into a specific codebase's history.

## Entry Points
- Global nav "Projects"
- Project badge/link from Explore (SCR-01), Thread Viewer (SCR-04)

## Key Components
- ProjectCard — project path (shortened to last 2 segments), display name, description, tag list, conversation count, last-active timestamp
- TagList (inline editable) — add/remove tags on a project directly from the card
- ViewControls — sort (last active / conversation count / title)
- EmptyState — no indexed projects yet

## States
- **Loading:** skeleton cards while `GET /api/projects` resolves
- **Empty:** first-run guidance pointing at index configuration (SCR-14 Settings)
- **Error:** inline error banner on fetch failure

## Interactions
- Card click → Project Detail (SCR-03)
- Inline tag add/remove persists immediately (optimistic update, `PATCH` project tags)
- Sort control re-orders the card grid client-side

## Navigation
- **From:** global nav, project badge links elsewhere
- **To:** SCR-03 Project Detail
