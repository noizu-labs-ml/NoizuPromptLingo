# Project Card

| Field | Value |
|-------|-------|
| **ID** | `project-card` |
| **Category** | Cards & Tiles |
| **Used In** | 05-Projects Dashboard, 06-Project Type Selector |

## Description

Self-contained card displaying a project's title, current phase/step, agent status, last edited timestamp, and phase progress bar. Primary navigation element from the dashboard.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Dashboard card (title + phase badge + last edited) |
| **Expanded** | Card with full progress bar, agent status, and quick action menu |

## Props / Configuration

- `title` — Project name
- `phase` — Current phase (Sketch/Draft/Ink/Publish)
- `step` — Current step number and name
- `agentStatus` — Idle | Working | Waiting | Error
- `lastEdited` — Timestamp
- `progress` — Array of phase completion states
- `actions` — Quick action menu items

## Interactions

- Click body → navigate to current step
- Click "Continue" CTA → same navigation
- Kebab menu → Duplicate/Export/Archive/Delete with confirmations
