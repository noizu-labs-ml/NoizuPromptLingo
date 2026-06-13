# Thread List

| Field | Value |
|-------|-------|
| **ID** | `thread-list` |
| **Type** | Primary |
| **Category** | Threads |
| **User Stories** | US-011, US-015 |

## Description

Thread listing within a space context. Displays threads with labels, vote counts, reply counts, and timestamps. Supports label filtering.

## Key Components

- **Thread cards** — Title, label badge, author, timestamp, reply count, vote score (US-011)
- **"New Thread" button** — Opens thread creation form (US-011)
- **Label filter bar** — Question, Discussion, Showcase, Bug Report filters (US-015)
- **Pagination** — Page-based navigation through threads (US-011)
- **Sort options** — Newest, most active, most voted (US-011)

## Interactions

- Browse threads in the space
- Filter by label type
- Sort by recency, activity, or votes
- Click a thread to view it
- Create a new thread

## Navigation

- Accessible from: Space Detail (11)
- Links to: Thread View (17), Thread Creation (18)
