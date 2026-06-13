# Morning Planning Wizard

| Field | Value |
|-------|-------|
| **ID** | `morning-planning` |
| **Type** | Storyboard |
| **Category** | Today & Daily Planning |
| **User Stories** | US-018 |

## Description

AI-assisted daily planning flow that triggers on first login or via menu action. Analyzes backlog, calendar, active streaks, and yesterday's incomplete items to suggest today's priorities.

## Key Components

- **AI-suggested item list** — Ranked suggestions pulled from backlog, calendar, and incomplete items
- **Rationale per item** — Brief explanation why each item was suggested
- **Accept/remove/reorder controls** — Inline actions to curate the suggested plan
- **Confirm plan action** — Finalizes the day plan and populates Today Dashboard
- **Calendar context panel** — Shows today's calendar events as constraints

## Flow Steps

1. **Review suggestions** — AI presents prioritized list with rationale
2. **Curate** — User accepts, removes, reorders, or adds items
3. **Confirm** — Finalized plan populates the Today Dashboard

## Navigation

- Triggered from: First daily login, "Plan my day" action
- Outputs to: Today Dashboard (populates items)
