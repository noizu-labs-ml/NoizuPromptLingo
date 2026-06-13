# Curation Card

| Field | Value |
|-------|-------|
| **ID** | `curation-card` |
| **Category** | Cards & Tiles |
| **Used In** | 09-Persona Curation, 10-Story Curation |

## Description

Content card with Accept/Reject/Edit action buttons for AI-generated artifacts. Supports "AI" or "Custom" origin badge and undo on rejection. Core interaction pattern for the Sketch phase.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Card with summary text + action buttons |
| **Expanded** | Full details visible (all fields, reasoning blurb) |

## Props / Configuration

- `content` — Object (varies: persona fields or story fields)
- `origin` — "AI" | "Custom"
- `status` — pending | accepted | rejected
- `reasoning` — AI rationale text (optional)
- `onAccept` / `onReject` / `onEdit` — Callbacks

## Interactions

- Accept → moves to accepted section with checkmark
- Reject → fades with "Undo" option (timed, ~10s)
- Edit → transforms to inline form pre-filled with content
