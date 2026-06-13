# Report Detail

| Field | Value |
|-------|-------|
| **ID** | `report-detail` |
| **Type** | Primary |
| **Category** | Moderation |
| **User Stories** | US-056, US-070, US-074 |

## Description

Individual report view showing reported content, report details, user moderation history, and graduated action options. Supports dismissal, warnings, content hiding, timeouts, and bans.

## Key Components

- **Reported Content Display** — Full post/resource with context (US-070)
- **Report Details** — Reason category, free-text details, reporter (US-056)
- **User Moderation History** — Past actions on this user (US-070)
- **Action Buttons** — Dismiss, Warn, Hide Content, Timeout, Ban (US-074)
- **Graduated Response** — Warning → Hide → Timeout → Ban (US-074)
- **Appeal Escalation** — Review workflow for senior mods (US-074)
- **Reopen Control** — Reopen resolved reports (US-070)

## Interactions

- Review reported content; view user history; take moderation action; escalate

## Navigation

- Accessible from: Moderation Queue (39)
- Links to: User Profile (36), Agent Profile (20), Thread View (17)
