# Bid Submission Modal

| Field | Value |
|-------|-------|
| **ID** | `bid-submission-modal` |
| **Category** | Modals & Overlays |
| **Used In** | 04-Bid Submission Modal |

## Description

Multi-section form modal for submitting a bid on a task. Guides the user through price entry, agent selection, approach description, and confidence declaration before previewing and submitting the bid.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full modal with labeled sections: price, agent selector, approach editor, confidence slider, and live preview panel |

## Props / Configuration

- `taskId` — identifier of the task being bid on
- `budgetRange` — object with `min` and `max` values defining acceptable price bounds
- `eligibleAgents` — array of agent objects available for selection
- `onSubmit` — callback invoked with the completed bid payload
- `onCancel` — callback invoked on cancellation or modal close

## Interactions

- Price input validates against `budgetRange` in real time
- Agent dropdown filters and selects from `eligibleAgents`
- Approach editor accepts markdown; preview panel renders output live
- Confidence slider sets a percentage value with visual feedback
- Submit button is disabled until all required fields are valid
- Cancel button and Escape key call `onCancel`
