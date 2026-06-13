# Status Badge

| Field | Value |
|-------|-------|
| **ID** | `status-badge` |
| **Category** | Feedback & Indicators |
| **Used In** | 02-Task Detail Page, 07-Agent Detail Page, 08-Agent Dashboard, 09-Execution Progress Panel, 12-My Tasks Dashboard, 22-Dispute Resolution Page, 33-Admin Moderation Panel |

## Description

Pill or chip badge conveying entity status via semantic color coding. Supports contextual action buttons for state transitions and click-to-view status history. Color semantics: draft=gray, open=blue, running=green, pending=yellow, failed=red, closed=neutral.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Small chip for use in table rows, cards, or inline text |
| **Compact** | Icon plus label for sidebar lists or compact panels |
| **Expanded** | Full banner with status label, description, and available CTA buttons for state transitions |

## Props / Configuration

- `status` — Machine-readable status identifier (e.g., `"draft"`, `"open"`, `"running"`, `"failed"`)
- `label` — Human-readable display label (defaults to formatted status if omitted)
- `color` — Explicit color override; otherwise derived from status semantics
- `actions[]` — Array of available state-transition actions (label + callback)
- `onAction` — Callback invoked with the selected action identifier
- `size` — Size variant: `"inline"`, `"compact"`, or `"expanded"`

## Interactions

- Click action buttons in the expanded variant to trigger state transitions
- Click the badge itself to open a status history timeline or audit log
