# Bug Detail View

| Field | Value |
|-------|-------|
| **ID** | `bug-detail` |
| **Type** | Primary |
| **Category** | Bug Tracking |
| **User Stories** | US-033, US-034, US-035, US-038, US-039 |

## Description

Full bug lifecycle view showing AI triage results, incident links, root cause links, pipeline stage progress (reported → triaged → in-progress → fix-deployed → verified), and auto-enrichment data.

## Key Components

- **Lifecycle pipeline indicator** — Visual progress through bug states
- **AI triage severity badge** — AI-assigned severity with confidence and override
- **Incident links section** — Connected incidents related to this bug
- **Root cause link** — Link to identified root cause (may link multiple bugs)
- **Auto-context panel** — Enrichment data (environment, logs, last deploy)
- **Activity timeline** — All actions, comments, state changes chronologically
- **Linked PRs/deploys** — Associated code changes and deploy events

## Interactions

- Transition bug state via pipeline indicator buttons
- Override AI triage with manual severity
- Link to incidents or root causes
- Add comments to activity timeline
- View linked PRs and their deploy status
- Mark as verified after deploy

## Navigation

- Accessible from: Bug list, Kanban Board, Incident detail
- Links to: Incident detail, Root Cause Dashboard, Pipeline Status, PR detail
