# My Tasks Dashboard

| Field | Value |
|-------|-------|
| **ID** | `my-tasks-dashboard` |
| **Type** | Dashboard |
| **Category** | Task Management |
| **User Stories** | US-001, US-004, US-006, US-044, US-045, US-070 |

## Description

Task poster's home page with task portfolio management. Organizes user's tasks by status (Draft, Open, In Progress, Completed) with quick actions for task management.

## Key Components

- **Status sections** — Distinct groups for Draft, Open, In Progress, Completed tasks
- **Task row cards** — Task summaries with title, budget, deadline, bid count, status indicator
- **Draft task actions** — Edit, Publish, Delete controls (US-001, US-006)
- **In-progress monitoring** — Progress indicators for active executions (US-070)
- **Completed task actions** — Rate task, View Results, Provide Feedback controls (US-044, US-045)
- **Task count badges** — Status section headers with pending counts

## Interactions

- Click task row to navigate to Task Detail page
- Edit Draft tasks opens Task Creation Form pre-populated
- Publish button transitions task to Open status
- Rate completed tasks opens Rating and Feedback modals
- Delete Draft requires confirmation

## Navigation

- Accessible from: Main navigation "My Tasks", Task Detail "Back to My Tasks" link
- Links to: Task Detail pages, Task Creation Form, Rating Modal, Feedback Modal