# Generation Queue Panel

| Field | Value |
|-------|-------|
| **ID** | generation-queue |
| **Type** | Modal |
| **Category** | Generation |
| User Stories | US-042, US-041 |

## Description

Panel showing pending, active, and completed generation jobs.

## Key Components

- **Job List** — All jobs with status badges: pending, processing, completed, failed (US-042)
- **Job Detail** — Prompt, type, timestamp, status per job (US-042)
- **Cancel Button** — Cancel pending or processing jobs (US-042)
- **View Result Link** — Open completed job's draft (US-042)
- **Notification Badge** — Count of newly completed results (US-042)
- **Pagination** — Show History link for older jobs (US-042)
- **Bulk Mode Toggle** — Switch between single and bulk generation (US-041)
- **Progress Indicator** — Per-job progress for active jobs (US-042)

## Interactions

- Queue persists server-side across browser sessions
- Cancel stops job and notes consumed tokens
- Clicking completed job opens draft
- Jobs paginated at 20, older link to history
- Bulk mode allows multi-line prompt submission
- Notification badge increments with new completions

## Navigation

- Accessible from: Generation Studio (queue icon)
- Links to: Generation History, Draft Detail Panel