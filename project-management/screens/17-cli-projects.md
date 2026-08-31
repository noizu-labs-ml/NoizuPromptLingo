# 17: CLI Projects

| Field | Value |
|-------|-------|
| ID | SCR-17 |
| Surface | cli-ink |
| Type | primary |
| Category | Discovery / Admin |
| Route / Entry | interactive router: `projects` |
| Primary Personas | P-005, P-001 |
| User Stories | US-070, US-071, US-061 |

## Description
Terminal list of indexed projects with inline title/description editing, mirroring Web Projects List (SCR-02).

## Entry Points
- Sidebar/router navigation from any interactive page

## Key Components
- SelectableList of project rows (path, display name, conversation count, last active)
- InlineEdit — activated by `e` (edit title) / `E` (edit description) on the focused row
- TagChips — inline tag display/edit per project

## States
- **Loading:** Spinner while project list resolves
- **Empty:** "No indexed projects" placeholder row
- **Editing:** InlineEdit replaces the row's static text with a text input; `Enter` commits, `Esc` cancels

## Interactions
- `e` → edit title inline; `E` → edit description inline
- `Enter` on a row → CLI Project Detail (SCR-18)

## Navigation
- **From:** router / sidebar
- **To:** SCR-18 CLI Project Detail
