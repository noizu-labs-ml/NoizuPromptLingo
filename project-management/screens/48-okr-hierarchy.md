# OKR Hierarchy View

| Field | Value |
|-------|-------|
| **ID** | `okr-hierarchy` |
| **Type** | Primary |
| **Category** | Goals & OKRs |
| **User Stories** | US-013, US-069, US-070, US-074 |

## Description

Multi-level OKR tree (organization → team → individual → personal) with auto-progress roll-up from linked work items, visibility controls for personal goals, and stale progress warnings.

## Key Components

- **Tree view** — Hierarchical objective → key result → linked items
- **Flat list toggle** — Switch between tree and flat list views
- **Progress bars** — Per-KR and per-Objective progress indicators
- **Roll-up calculation** — Auto-calculated progress from linked item completion
- **Visibility badges** — Personal (private), team, organization scope
- **Linked items count** — Number of work items contributing to each KR
- **Stale progress warning** — Flag when progress hasn't updated recently

## Interactions

- Expand/collapse tree levels
- Click objective or KR for detail view
- Toggle between tree and flat list
- Filter by team, period, or visibility level
- Create new objectives/KRs inline
- Drag items to link them to KRs

## Navigation

- Accessible from: Main nav (goals section)
- Links to: OKR Check-In, Goal Alignment Viz, OKR Scoring, Item detail
