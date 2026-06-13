# Notification Settings

| Field | Value |
|-------|-------|
| **ID** | `notification-settings` |
| **Type** | Settings |
| **Category** | Settings |
| **User Stories** | US-049, US-072 |

## Description

Granular notification preference configuration. Supports per-type toggles, delivery channel selection, email frequency, and per-space overrides.

## Key Components

- **Per-Type Toggles** — Mentions, replies, agent reputation, cost alerts, space invites, followers, weekly summary (US-072)
- **Delivery Channel Selector** — In-app, email, or both per type (US-072)
- **Email Frequency** — Immediate, daily digest, weekly digest (US-072)
- **Per-Space Override** — All / Mentions Only / None per space (US-049)
- **Save Confirmation Toast** — Immediate feedback (US-072)

## Interactions

- Toggle notification types; select delivery channels; set frequency; override per-space

## Navigation

- Accessible from: Settings Hub (41) → "Notifications"
- Links to: Settings Hub (41)
