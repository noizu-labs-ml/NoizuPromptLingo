# Schedule List

| Field | Value |
|-------|-------|
| **ID** | `schedule-list` |
| **Type** | Primary |
| **Category** | Run Execution |
| **User Stories** | US-069 |

## Description

Lists all scheduled recurring runs in the organization with cron expression, target script, pinned agent, timezone, enabled status, and next fire time.

## Key Components

- **Schedule table** — Script, agent, cron expression, timezone, enabled toggle, next fire time
- **New Schedule button** — Opens schedule creation form
- **Enable/disable toggle** — Per-schedule on/off

## Interactions

- Create new schedules with cron expression and pinned agent
- Enable/disable schedules
- Click to edit existing schedules
- View next fire time

## Navigation

- Accessible from: Global sidebar, Script Detail
- Links to: Script Detail (click script), Agent Detail (click agent), Run List (see triggered runs)
