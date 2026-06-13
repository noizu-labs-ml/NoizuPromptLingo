# On-Call Schedule

| Field | Value |
|-------|-------|
| **ID** | `oncall-schedule` |
| **Type** | Primary |
| **Category** | Monitoring & Incidents |
| **User Stories** | US-052 |

## Description

On-call roster showing current assignee, rotation schedule (weekly/biweekly), swap capability between team members, escalation path configuration, and historical on-call log.

## Key Components

- **Current on-call badge** — Who is currently on-call with contact info
- **Rotation calendar** — Visual calendar showing upcoming rotations
- **Swap action** — Request or offer shift swaps with teammates
- **Escalation chain** — Ordered list of escalation contacts
- **History log** — Past on-call shifts and incidents handled

## Interactions

- View who's currently on-call at a glance
- Request swap → notifies target for approval
- Edit escalation chain for different severity levels
- View past on-call history and load distribution
- Integrate with external paging tools (PagerDuty, Opsgenie)

## Navigation

- Accessible from: Monitoring nav, Incident Detail (escalation)
- Links to: Incident Detail, Team settings
