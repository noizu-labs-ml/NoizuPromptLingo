---
id: US-047
title: "Anomaly Notification Preferences"
slug: "anomaly-notification-preferences"
personas: [P-002, P-004, P-008, P-003]
epic: "Anomaly Detection"
priority: "must-have"
complexity: "M"
tags: [anomaly-detection, notifications, alerts, preferences, routing]
---

# US-047: Anomaly Notification Preferences

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** configure which anomaly severity levels and device groups trigger notifications to which channels and recipients,
**So that** the right people are alerted through the right channel without burying teams in noise from low-severity events.

## Acceptance Criteria

- [ ] Given I open notification settings, when I configure anomaly notifications, then I can create rules with: severity filter (Critical/Warning/Informational), device group filter, destination channel (email, SMS, Slack, PagerDuty, webhook), and recipient list
- [ ] Given a notification rule is configured, when a matching anomaly is generated, then the notification is delivered within 60 seconds with: device ID, metric name, anomaly score, severity, and a deep link to the investigation view
- [ ] Given I configure a notification rule with a digest mode, when I enable it, then instead of per-anomaly notifications, a summary is delivered at a configured interval (e.g., every 30 minutes) listing all anomalies in that window
- [ ] Given an anomaly is resolved or marked as false positive, when the resolution occurs, then a resolution notification is sent to the same recipients that received the original alert (if configured)
- [ ] Given I am a user, when I configure personal notification preferences, then my preferences override workspace defaults for my own notification channels without affecting others

## Notes

Digest mode is essential for P-008 who may receive many low-severity alerts during normal operations. Channel integrations should reuse the integration vault from the action library (US-030) for credential management.
