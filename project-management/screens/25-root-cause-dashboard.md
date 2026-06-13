# Root Cause Analysis Dashboard

| Field | Value |
|-------|-------|
| **ID** | `root-cause-dashboard` |
| **Type** | Dashboard |
| **Category** | Bug Tracking |
| **User Stories** | US-038 |

## Description

Top root causes ranked by impact (number of linked bugs, severity), trending failure patterns, and mean time from symptom to root cause identification. AI suggests groupings.

## Key Components

- **Root cause ranking** — Top causes sorted by impact score
- **Impact summary** — Bugs affected, total severity weight
- **Linked bugs list** — All bugs connected to a root cause
- **Trending patterns** — Emerging failure patterns over time
- **Agent-suggested groupings** — AI proposes related bugs share a root cause

## Interactions

- Click root cause to see all linked bugs
- Accept/reject AI grouping suggestions
- Create new root cause and link bugs to it
- Filter by project, time range, severity
- Export for engineering reviews

## Navigation

- Accessible from: Bug tracking nav, Bug Detail View
- Links to: Bug Detail, Post-Incident Review
