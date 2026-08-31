# 18: CLI Project Detail

| Field | Value |
|-------|-------|
| ID | SCR-18 |
| Surface | cli-ink |
| Type | primary |
| Category | Discovery / Admin |
| Route / Entry | interactive router: `project-detail` (from a CLI Projects row) |
| Primary Personas | P-005, P-001 |
| User Stories | US-070, US-071, US-063 |

## Description
Terminal drill-down into one project's conversations, mirroring Web Project Detail (SCR-03): filterable, sortable thread list scoped to a single project path.

## Entry Points
- `Enter` on a row in CLI Projects (SCR-17)

## Key Components
- SelectableList of ConversationRow items scoped to the project
- Filter input (`/` key enters filter mode)
- Sort selector (`o` key enters sort mode)

## States
- **Loading:** Spinner while scoped conversation list resolves
- **Empty:** "No conversations in this project" row
- **Filter mode:** footer prompt captures a text query narrowing the visible rows live

## Interactions
- `/` → filter mode; `o` → sort mode (updated/started/message-count/title)
- `Enter` on a row → CLI Thread (SCR-19)
- `Esc`/`b` → back to CLI Projects

## Navigation
- **From:** SCR-17 CLI Projects
- **To:** SCR-19 CLI Thread, SCR-17 (back)
