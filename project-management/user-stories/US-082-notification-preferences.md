---
id: US-082
title: "User configures notification preferences"
slug: "notification-preferences"
personas: [P-005, P-001]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "M"
tags: [settings, notifications, email, webhook, in-app]
---

# US-082: User Configures Notification Preferences

## User Story

**As an** Engineering Manager (P-005),
**I want to** configure how and when I receive notifications (email, webhook, in-app) for platform events,
**So that** I stay informed about deployment status, policy violations, and usage anomalies through my preferred channels without being overwhelmed by noise.

## Acceptance Criteria

- [ ] Given a user navigates to Settings > Notifications, when the notification preferences page loads, then they see toggles for each notification channel (email, webhook URL, in-app) organized by event category (deployments, policy alerts, usage thresholds, system health)
- [ ] Given a user enables webhook notifications and provides a URL, when they click "Test Webhook," then the platform sends a test payload to the configured URL and displays the HTTP response status
- [ ] Given a user disables a notification channel for a specific event category, when a matching event occurs, then no notification is sent through that channel for that category while other enabled channels still fire
- [ ] Given a user has configured notification preferences, when they revisit the settings page, then their previously saved preferences are displayed correctly with all toggles reflecting the saved state

## Notes

Notification events should be batched where possible (e.g., digest mode for high-frequency events like tool invocations). Webhook payloads should follow a consistent JSON schema with event type, timestamp, and a signed payload for verification. Related to US-100 (webhook event configuration) for real-time invocation events.
