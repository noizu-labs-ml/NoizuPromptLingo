---
id: US-018
title: "Configure Agent Notifications and Alerts"
slug: "agent-notifications"
personas: [P-001, P-002, P-008]
epic: "Agent Management"
priority: "must-have"
complexity: "M"
tags: [agents, notifications, alerts, email, slack, webhooks]
---

# US-018: Configure Agent Notifications and Alerts

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** configure where and how an agent sends notifications when it detects anomalies or takes actions,
**So that** the right people are alerted through the right channels without overwhelming inboxes with noise.

## Acceptance Criteria

- [ ] Given I open an agent's configuration and click "Notifications," when the settings panel opens, then I can configure notification channels including email, Slack webhook, PagerDuty, and generic webhook, with a different channel per severity (info, warning, critical).
- [ ] Given I configure a Slack webhook, when I click "Test," then IoTGo sends a test message to the channel and shows whether it was delivered successfully.
- [ ] Given an agent fires an anomaly alert, when the notification is sent, then it includes: device name, anomaly description, severity, timestamp, the agent's reasoning summary, and a direct link to the anomaly in IoTGo.
- [ ] Given I want to reduce notification volume, when I configure a cooldown period (e.g., "max 1 alert per device per 30 minutes"), then the agent suppresses repeat alerts for the same device-anomaly combination within that window.
- [ ] Given a field technician (P-008) is added as a notification recipient, when they receive an alert, then the message is mobile-readable with the most critical information in the first 50 characters of the subject/title.

## Notes

Notification routing rules by device group or tag (e.g., alerts for Building A go to Facilities team) are a should-have for a later refinement. PagerDuty integration requires an API key, not just a webhook.
