# Inbox

| Field | Value |
|-------|-------|
| **ID** | `inbox-list` |
| **Type** | Primary |
| **Category** | Inbox & Capture |
| **User Stories** | US-006, US-008, US-009 |

## Description

Central inbox for all captured items awaiting triage. Items arrive from quick capture, email ingestion, voice notes, and external integrations. AI classification suggests project assignment, priority, and item type with confidence scores.

## Key Components

- **Item list** — Chronological list of untriaged items
- **AI suggestion overlay** — Per-item classification suggestions (project, priority, type)
- **Accept/reject buttons** — Inline actions to approve or dismiss AI suggestions
- **Batch triage queue** — Sequential triage mode processing items one at a time
- **Confidence indicator** — Visual score for AI classification confidence
- **Source badge** — Indicates origin (typed, email, voice, share-sheet)
- **Filter bar** — Filter by source, date, confidence level

## Interactions

- Accept AI suggestion → item moves to assigned project/list
- Reject → manual triage (project picker, priority selector)
- Batch mode processes items sequentially with keyboard shortcuts
- Swipe left/right on mobile for quick triage
- Bulk select for mass triage actions

## Navigation

- Accessible from: Main nav (inbox icon), badge count indicator
- Links to: Project boards, Personal lists, Item detail
