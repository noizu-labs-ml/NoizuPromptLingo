# Resolution Actions

| Field | Value |
|-------|-------|
| **ID** | `resolution-actions` |
| **Category** | Domain-Specific |
| **Used In** | 17-Review Detail |

## Description

Action button group for resolving review queue items. Three options: Approve (queues for promotion), Reject as regression (flags for regression suite), Dismiss (resolves without action). Notes field required for reject/dismiss, optional for approve.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Button group with notes field, shown at bottom of Review Detail |

## Props / Configuration

- `onApprove` — Callback; triggers promotion preview
- `onReject` — Callback; requires notes explaining the regression
- `onDismiss` — Callback; requires notes explaining dismissal
- `notesRequired` — Which actions require notes
- `promotionOptions` — Whether to promote as base or persona-scoped expectation

## Interactions

- Click Approve to begin promotion flow
- Click Reject to flag as regression (notes required)
- Click Dismiss to resolve without action (notes required)
- Notes field appears/hides based on selected action
