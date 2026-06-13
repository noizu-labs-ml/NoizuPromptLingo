# Agent Notification Preferences

| Field | Value |
|-------|-------|
| **ID** | `agent-notification-settings` |
| **Type** | Settings |
| **Category** | Agent Management |
| **User Stories** | US-082 |

## Description

Per-agent notification category configuration with threshold-based rules, delivery channel selection (in-app, email, Slack, webhook), and digest mode for reducing notification noise.

## Key Components

- **Category list** — Notification categories (errors, completions, approvals needed, etc.)
- **Delivery channel selector** — Choose channel per category (in-app, email, Slack, webhook)
- **Threshold rules** — Only notify when metric exceeds threshold
- **Team-level override** — Team-wide defaults with individual overrides
- **Digest mode toggle** — Batch notifications into periodic digests

## Interactions

- Configure per-agent, per-category notification rules
- Set thresholds (e.g., only notify if >3 errors in 1 hour)
- Choose delivery channel per category
- Enable digest mode for lower-priority notifications
- Test notification delivery

## Navigation

- Accessible from: Settings nav, Agent Team Dashboard (agent settings)
- Links to: Agent Team Dashboard, User notification settings
