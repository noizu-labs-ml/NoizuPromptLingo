# 03: Project Detail

| Field | Value |
|-------|-------|
| ID | SCR-03 |
| Surface | web |
| Type | primary |
| Category | Discovery / Admin |
| Route / Entry | `/projects/:slug` (slug = URL-encoded project path) |
| Primary Personas | P-005, P-001, P-006 |
| User Stories | US-070, US-071, US-063, US-083 |

## Description
Drill-down from Projects List (SCR-02): every conversation that belongs to a single project directory, with the same filter/sort/preview affordances as Explore but scoped to one project. Used for project-scoped audits and for finding "that thread in this repo."

## Entry Points
- Project card click from SCR-02
- Project badge click from Thread Viewer, Explore results

## Key Components
- ProjectHeader — project path, display name, description, tag list, total conversation count
- ThreadList / ThreadRow — title, date, message count, tags, status badge, first/last-message preview
- ViewControls — sort (updated/started/message count/title), page size
- Pagination
- EmptyState — orphaned project directory with zero conversations (US-083)

## States
- **Loading:** skeleton header + skeleton rows
- **Empty:** "No conversations indexed under this path" — relevant when a project directory was orphaned/moved (US-083)
- **Error:** project not found (invalid slug) → 404-style message with link back to SCR-02

## Interactions
- Filter input narrows the thread list client-side within the loaded page
- Row click → Thread Viewer (SCR-04)
- Rehome action available per-thread (moves a conversation's project association — US-063)

## Navigation
- **From:** SCR-02 Projects List
- **To:** SCR-04 Thread Viewer, SCR-02 (back)
