---
id: US-073
title: "Notification and Alert Preferences"
slug: "notification-alert-preferences"
personas: [P-002, P-004]
epic: "Settings & Administration"
priority: "must-have"
complexity: "M"
tags: [notifications, alerts, preferences, email, slack]
---

# US-073: Notification and Alert Preferences

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** configure which events trigger notifications, what channels they use (email, Slack, PagerDuty, webhook), and which team members receive them,
**So that** the right people are alerted for the right events without alert fatigue from irrelevant notifications.

## Acceptance Criteria

- [ ] Given I open notification preferences, when I configure a notification rule, then I can select: event type (anomaly detected, action completed, action failed, approval required, device offline, agent error), severity threshold, target device group or segment, channel (email / Slack / PagerDuty / webhook), and recipient(s).
- [ ] Given I configure a Slack channel destination, when I save it, then I can send a test notification and verify it arrives in the specified channel before the rule is activated.
- [ ] Given multiple rules could match the same event, when the event fires, then the system deduplicates notifications: a single user receives at most one notification per event per channel per 5-minute window.
- [ ] Given I receive a notification, when I click the action link in it, then I am taken directly to the relevant approval queue entry, execution detail, or device detail in the IoTGo UI.
- [ ] Given I want to suppress notifications during a maintenance window, when I set a mute period (start/end datetime), then no notifications fire for the scoped device group during that window; the mute is logged.

## Notes

PagerDuty and webhook integrations are should-have; email and Slack are must-have for MVP. Deduplication window should be configurable (5 minutes default). Connects to US-055 (approval SLA escalation) and US-053 (rollback escalation).
