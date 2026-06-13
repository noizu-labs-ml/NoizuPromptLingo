# Review Queue

| Field | Value |
|-------|-------|
| **ID** | `review-queue` |
| **Type** | Primary |
| **Category** | Review & Promotion |
| **User Stories** | US-088, US-089, US-090, US-137, US-138, US-139, US-140, US-141 |

## Description

Central page for triaging pending freeball nodes awaiting review. Lists all pending items across scripts with filtering, sorting, bulk actions, and assignment workflow. Badge count shown in global nav.

## Key Components

- **Queue table** — Rows with parent script/node, freeball prompt preview, confidence, runner model, timestamp, run link (US-088)
- **Filters** — Script, persona, confidence range, age, runner model, assigned user (US-088)
- **Sort controls** — Confidence ascending/descending (US-088)
- **Claim action** — Assign item to self for review (US-089)
- **Bulk selection** — Multi-select with approve all / dismiss all / flag regression (US-138)
- **Assignment workflow** — Assign to specific teammates (US-140)
- **SLA aging badges** — Visual indicators for items past SLA (US-141)
- **Queue count badge** — Shown in global nav (US-088)
- **My Queue tab** — Items assigned to logged-in user (US-140)

## Interactions

- Filter and sort to prioritize review
- Claim an item to begin review
- Click item to open Review Detail
- Bulk select and apply actions
- Assign items to teammates

## Navigation

- Accessible from: Global sidebar navigation (with badge count)
- Links to: Review Detail (click claimed item), Run Detail (click run link)
