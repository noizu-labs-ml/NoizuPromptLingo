# Backlog Grooming View

| Field | Value |
|-------|-------|
| **ID** | `backlog-grooming` |
| **Type** | Primary |
| **Category** | Project Management |
| **User Stories** | US-028 |

## Description

AI-assisted grooming interface presenting priority suggestions, story point estimates, stale item flags, and grouping recommendations. Designed for batch decision-making on backlog health.

## Key Components

- **Backlog item list** — Full backlog with current priority and estimates
- **AI suggestion diff** — Shows proposed changes (priority up/down, estimate change)
- **Accept/reject per item** — Inline approve or dismiss AI suggestions
- **Stale item flags** — Items untouched for N weeks highlighted
- **Estimation confidence** — AI confidence in suggested story points
- **Bulk accept actions** — Accept all suggestions matching a filter

## Interactions

- Review AI suggestions inline (diff style)
- Accept/reject individually or in bulk
- Stale items can be archived, deprioritized, or reviewed
- Manual override of any AI suggestion
- Session summary shows decisions made

## Navigation

- Accessible from: Project nav (backlog section)
- Links to: Sprint Planning, Item detail, Archive
