# Pipeline Status View

| Field | Value |
|-------|-------|
| **ID** | `pipeline-status` |
| **Type** | Primary |
| **Category** | CI/CD & Deployments |
| **User Stories** | US-041, US-046 |

## Description

Per-project CI/CD pipeline status showing pass/fail/running indicators, expandable stage breakdowns, failure context with AI analysis, and linked work items.

## Key Components

- **Pipeline list** — All recent pipeline runs with status indicators
- **Status indicators** — Green (pass), red (fail), yellow (running), gray (pending)
- **Stage breakdown (expandable)** — Click to expand individual stage results
- **Failure log excerpt** — Relevant log lines for failed stages
- **Linked items** — Work items associated with the pipeline run
- **Auto-refresh** — Real-time status updates for running pipelines
- **AI failure analysis** — Agent-generated root cause hypothesis for failures

## Interactions

- Click pipeline to expand stage breakdown
- Click failure to see log context and AI analysis
- Navigate to linked work items
- Retry failed pipeline
- Filter by branch, status, date range

## Navigation

- Accessible from: Project nav (CI/CD section), Deploy Changelog
- Links to: Item detail, Deploy Approval, Rollback, Environment Dashboard
