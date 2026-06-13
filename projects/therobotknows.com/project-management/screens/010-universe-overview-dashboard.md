# Universe Overview Dashboard

| Field | Value |
|-------|-------|
| **ID** | universe-overview-dashboard |
| **Type** | Dashboard |
| **Category** | Universe |
| **User Stories** | US-012, US-073 |

## Description

Summary dashboard for universe showing entry counts, activity, consistency score, and quick access.

## Key Components

- **Entry Count Cards** — Counts by type (characters, locations, events, etc.) (US-012)
- **Recent Activity Feed** — Last 10 edits with timestamps (US-012)
- **Consistency Score** — Score indicator with "run check" prompt if never run (US-012)
- **Quick Access Buttons** — Canon Editor, Knowledge Graph, Generation Studio (US-012)
- **Recent Entries Feed** — 20 most recent entries with editor and timestamp (US-073)
- **Universe Actions** — Settings, Delete, Duplicate buttons (US-013, US-014)
- **Universe Switcher** — Sidebar/breadcrumb to switch universes (US-012)

## Interactions

- Clicking entry count filters Canon Editor to that type
- Activity feed paginated with load more
- Consistency score prompts first-time check
- Quick access buttons navigate to respective areas
- Entry counts are live, not stale

## Navigation

- Accessible from: Dashboard (universe selection), Universe Settings
- Links to: Canon Editor (by type), Knowledge Graph, Generation Studio, Consistency Dashboard, Universe Settings