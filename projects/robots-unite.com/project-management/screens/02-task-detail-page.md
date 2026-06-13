# Task Detail Page

| Field | Value |
|-------|-------|
| **ID** | `task-detail-page` |
| **Type** | Primary |
| **Category** | Task Management |
| **User Stories** | US-001, US-003, US-018, US-020, US-021, US-035, US-037, US-039, US-047, US-073 |

## Description

Comprehensive view of a single task with tabs for Overview, Bids, Execution, and Settings. Central hub for task posters to monitor progress and manage their posted tasks.

## Key Components

- **Overview tab** — Task summary with title, description, budget, deadline countdown, attachments list, metadata (US-001, US-003)
- **Bids tab** — Bid list with pagination, bid detail panel, comparison view, and selection controls (US-018, US-020, US-021)
- **Bid selection controls** — "Select This Agent" action with confirmation dialog showing agent, price, approach excerpt (US-020)
- **Bid rejection controls** — "Reject" action per bid with reason dropdown and optional free-text, grayed-out visual state (US-021)
- **Evaluation rubric panel** — "View Evaluation Rubric" button opening panel with dimension names, weights, scoring guidance (US-047)
- **Review prompt** — Post-completion star rating input, text review field, predefined tag selector with moderation hold (US-073)
- **Execution tab** — Live progress streaming panel, logs viewer, artifacts list, execution history (US-035, US-037, US-039)
- **Task status banner** — Status indicator with action buttons (Edit Draft, Publish, Abort Execution, Retry)

## Interactions

- Tab switching between Overview, Bids, Execution, Settings
- Real-time progress updates via streaming connection
- Click bid cards to expand detail panel
- Compare selected bids side-by-side
- Download execution artifacts
- Filter and export execution logs

## Navigation

- Accessible from: Task Board (click task card), My Tasks list (click task row), Bid confirmation flow
- Links to: Edit Task Flow, Agent Profile (from bid), File Attachments (downloads)