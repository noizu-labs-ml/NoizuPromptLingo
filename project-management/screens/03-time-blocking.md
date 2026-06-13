# Time Blocking Calendar

| Field | Value |
|-------|-------|
| **ID** | `time-blocking-view` |
| **Type** | Primary |
| **Category** | Today & Daily Planning |
| **User Stories** | US-017 |

## Description

A daily timeline view for scheduling work items into time slots. Overlays external calendar events (Google/Outlook) and offers AI-generated schedule suggestions based on item estimates, energy patterns, and meeting gaps.

## Key Components

- **Daily timeline** — Vertical hourly grid (configurable start/end times)
- **Drag from Today list** — Drag items from the sidebar Today list into time slots
- **External calendar events** — Read-only overlay of synced calendar events
- **Time block cards** — Visual blocks showing assigned items with duration
- **Conflict warnings** — Red indicators when blocks overlap or exceed available time
- **AI suggest schedule action** — One-click auto-schedule based on priorities and constraints

## Interactions

- Drag items from Today list onto timeline
- Resize time blocks by dragging edges
- Click blocks to edit or remove
- AI suggestion populates empty slots (user approves or modifies)
- External events shown as non-editable gray blocks

## Navigation

- Accessible from: Today Dashboard (calendar icon), Main nav
- Links to: Today Dashboard, External calendar integration settings
