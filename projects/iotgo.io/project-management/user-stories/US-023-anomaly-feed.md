---
id: US-023
title: "Live Anomaly Feed on Dashboard"
slug: "anomaly-feed"
personas: [P-001, P-003, P-008]
epic: "Core Dashboard"
priority: "must-have"
complexity: "M"
tags: [dashboard, anomalies, feed, real-time, alerts]
---

# US-023: Live Anomaly Feed on Dashboard

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** see a real-time feed of detected anomalies on my dashboard,
**So that** I can immediately identify emerging issues across my fleet without having to poll individual device pages.

## Acceptance Criteria

- [ ] Given I am on the dashboard, when an agent detects a new anomaly, then a new entry appears at the top of the anomaly feed within 10 seconds, showing: device name, anomaly type, severity badge, detecting agent, and time elapsed.
- [ ] Given the anomaly feed is visible, when I click on an anomaly entry, then I am taken to the anomaly detail page showing the full context, affected telemetry values, and the agent's reasoning.
- [ ] Given I want to reduce noise, when I apply a severity filter (Critical / Warning / Info), then the feed updates in real time to show only anomalies matching the selected severity.
- [ ] Given an anomaly is resolved (manually or by agent remediation), when the resolution occurs, then the entry in the feed is visually updated (e.g., strikethrough or green checkmark) rather than disappearing, so I can see resolution rate.
- [ ] Given the feed accumulates many entries, when I scroll to the bottom, then older entries are loaded on demand (infinite scroll) and the feed maintains smooth performance up to 1,000 visible entries.

## Notes

The anomaly feed is read-only on the dashboard; acknowledgment and remediation actions are on the anomaly detail page. Feed polling interval should fall back to 30-second polling if WebSocket is unavailable.
