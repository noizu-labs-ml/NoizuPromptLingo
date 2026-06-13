# Canon Editor List View

| Field | Value |
|-------|-------|
| **ID** | canon-editor-list |
| **Type** | Primary |
| **Category** | Canon |
| **User Stories** | US-016, US-017, US-024 |

## Description

List view of all canon entries with filtering, sorting, and status indicators.

## Key Components

- **Filter Bar** — Entry type toggles, status filter (Canon/Draft/Generated) (US-028, US-024)
- **Tag Filter** — Multi-select tag filter with AND logic (US-023)
- **Sort Controls** — Sort by name, date created, last edited (US-017)
- **Entry List** — Cards or table showing name, type, status, tags, last edited (US-016)
- **Status Badges** — Colored badges: Canon (green), Draft (yellow), Generated (blue) (US-024)
- **New Entry Button** — Opens type selector for creating entries (US-016)
- **Entry Actions** — Edit, Delete, View Version History (US-017, US-018, US-025)
- **Pagination** — Load more entries (US-012)

## Interactions

- Type filters hide nodes/edges and update list
- Status filter shows only selected status entries
- Clicking entry card opens detail view
- New Entry button opens type selector modal
- Delete shows confirmation with broken references
- Filter state persists for current session

## Navigation

- Accessible from: Universe Overview, Knowledge Graph (node click)
- Links to: Canon Entry Detail, Canon Editor Create, Version History