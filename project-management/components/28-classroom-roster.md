# Classroom Roster

| Field | Value |
|-------|-------|
| **ID** | `classroom-roster` |
| **Category** | Tables & Lists |
| **Used In** | 10-Education Portal |

## Description

Student roster for educator classrooms showing student names, fighter builds, match history, and training data. Supports up to 35 students per classroom.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Name list with status indicators only |
| **Expanded** | Full roster with build viewer and match history columns |

## Props / Configuration

- `students` — Student list with associated data
- `maxSize` — Roster capacity limit (default: 35)
- `showBuilds` — Display fighter build column
- `showHistory` — Display match history column

## Interactions

- View full student list
- Inspect an individual student's builds and match history
- View student training heatmaps
- Export student data
