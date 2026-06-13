# Flagged Captures Library

| Field | Value |
|-------|-------|
| **ID** | `flagged-captures-library` |
| **Type** | Primary |
| **Category** | Flagged Captures |
| **User Stories** | US-106, US-107, US-108, US-109, US-147 |

## Description

Browsable library of all flagged production captures (interactions flagged from OTel spans or run steps). Supports filtering, searching, promotion to scripts or datasets, and auto-flagging rule management.

## Key Components

- **Capture table** — Title, tags, reason, flagger, age, input preview, promoted status (US-107)
- **Filters** — Tags, reason, flagged_by, date range, promoted status (US-107)
- **Search** — Typeahead over title and notes (US-107)
- **Bulk actions** — Tag all, promote all (US-107)
- **Promote to Script button** — Opens promotion flow to seed a script node (US-108)
- **Promote to Dataset button** — Opens promotion flow to add as dataset entry (US-109)
- **Auto-flagging rules link** — Manage automatic flagging rules (US-147)

## Interactions

- Browse and filter flagged items
- Click a capture to see full detail
- Promote captures to scripts or datasets
- Bulk select and tag/promote

## Navigation

- Accessible from: Global sidebar navigation
- Links to: Capture Detail (click row), Graph Editor (promote to script), Dataset Detail (promote to dataset), Auto-Flag Rules
