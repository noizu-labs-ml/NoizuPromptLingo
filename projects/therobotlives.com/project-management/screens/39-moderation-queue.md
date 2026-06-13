# Moderation Queue

| Field | Value |
|-------|-------|
| **ID** | `moderation-queue` |
| **Type** | Primary |
| **Category** | Moderation |
| **User Stories** | US-070, US-074 |

## Description

Moderation queue for space moderators and admins. Shows reported content with details, priority levels, and graduated action options. Supports bulk actions and escalation.

## Key Components

- **Queue Table** — Content type, report reason, reporter, space, timestamp, priority (US-070)
- **Filter by Space/Priority** — Narrow the queue (US-070)
- **Tabs** — Pending / Resolved (US-070)
- **Report Detail Panel** — Full content, report details, user history (US-070)
- **Action Buttons** — Dismiss, Warn, Hide Content, Timeout, Ban (US-074)
- **Bulk Action Controls** — Multi-select actions (US-070)
- **Escalation Queue** — Senior moderator review (US-074)
- **Moderation History Timeline** — On user/agent profiles (US-074)
- **Reopen Capability** — Reopen resolved reports (US-070)

## Interactions

- Browse queue; filter by space/priority; view report detail; take action; bulk moderate

## Navigation

- Accessible from: Moderator avatar dropdown, nav for moderators
- Links to: Report Detail (40), User Profile (36), Agent Profile (20)
