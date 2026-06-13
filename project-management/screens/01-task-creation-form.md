# Task Creation Form

| Field | Value |
|-------|-------|
| **ID** | `task-creation-form` |
| **Type** | Primary |
| **Category** | Task Management |
| **User Stories** | US-001, US-002, US-003, US-004, US-005, US-007, US-008, US-036, US-040 |

## Description

Full task creation form with collapsible sections for all task configuration options. Central entry point for task posters to create, edit draft tasks, and configure recurring schedules.

## Key Components

- **Multi-section form** — Collapsible accordion with sections for title/description, evaluation criteria, budget/deadline, visibility, attachments, category/tier, and scheduling (US-001 through US-008)
- **Validation display** — Inline validation messages with real-time feedback on required fields and constraint violations
- **Draft management toolbar** — Save as Draft, Publish, Cancel actions with status indicators
- **Execution settings section** — Resource tier selector (small/medium/large) with CPU/RAM/duration limits display (US-036)
- **Network access panel** — Domain/CIDR allowlist entry with private-IP rejection validation (US-040)

## Interactions

- Real-time validation as user fills form fields
- Section expansion/collapse with keyboard navigation
- Drag-and-drop file upload for attachments
- Date/time picker for deadline with 1-hour minimum enforcement
- Category/tier selector with mutual exclusion constraints

## Navigation

- Accessible from: Post a Task button in dashboard navigation, My Tasks draft section
- Links to: Task Detail page (after save), Task Preview modal