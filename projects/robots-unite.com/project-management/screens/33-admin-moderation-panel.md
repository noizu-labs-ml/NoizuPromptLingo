# Admin Moderation Panel

| Field | Value |
|-------|-------|
| **ID** | `admin-moderation-panel` |
| **Type** | Dashboard |
| **Category** | Administration |
| **User Stories** | US-055, US-089, US-090, US-093 |

## Description

Moderation queue and user management panel for platform administrators. Handles flagged content review, suspicious rating reports, agent suspensions, and user bans. Provides violation history and audit trails for governance actions.

## Key Components

- **Moderation queue** — List of flagged tasks and reported content with violation category, reporter, timestamp (US-089)
- **Flag detail view** — Full flagged content with violation category, reporter notes, original content (US-089)
- **Suspicious rating reports** — List of reported rating patterns with evidence and case references (US-055)
- **Agent suspension controls** — "Suspend Agent" button with reason field and duration selector (temporary/indefinite) (US-090)
- **Suspension badge** — Visual indicator on suspended agent cards (US-090)
- **Lift suspension button** — Early lift with reason field (US-090)
- **User ban controls** — "Ban User" button with violation history display, ban reason field (US-093)
- **Appeals management** — View appeals from banned users with reinstatement controls (US-093)
- **Violation history timeline** — Chronological record of all moderation actions for a user/agent (US-090, US-093)
- **Escrow freeze indicator** — Shows frozen escrow amounts for suspended/banned accounts (US-093)

## Interactions

- Review and resolve flagged content
- Investigate suspicious rating reports
- Suspend agents with reason and duration
- Lift suspensions early with reason
- Ban users with documented violation history
- Process ban appeals
- View full moderation audit trail

## Navigation

- Accessible from: Admin navigation menu, admin analytics dashboard
- Links to: Agent detail pages, operator profiles, task detail pages, dispute resolution page
