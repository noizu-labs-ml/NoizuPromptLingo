---
id: US-093
title: "MQTT Source Management"
slug: "mqtt-source-management"
personas: [P-001, P-008]
epic: "Integration & API"
priority: "must-have"
complexity: "M"
tags: [mqtt, sources, integration, iot]
---

# US-093: MQTT Source Management

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** add, configure, and monitor MQTT broker connections as telemetry sources,
**So that** IoTGo agents can subscribe to device topics and process live telemetry without requiring a cloud platform intermediary.

## Acceptance Criteria

- [ ] Given I navigate to Sources > MQTT, when I click Add Source, then I can provide broker host, port, client ID, topic filter(s), authentication (none, username/password, client certificate), and a display name
- [ ] Given an MQTT source is saved, when IoTGo connects to the broker, then a green status indicator and last-message timestamp appear on the source card within 30 seconds
- [ ] Given connection fails, when I view the source card, then a red indicator and human-readable error message (e.g., "Authentication failed", "Host unreachable") are displayed
- [ ] Given a source is active, when I click Test Connection, then IoTGo attempts a fresh connection and reports success or failure with response time
- [ ] Given an MQTT source receives messages, when I click View Messages, then a live stream of the most recent 50 messages with topic, payload preview, and timestamp is shown

## Notes

MQTT v3.1.1 and v5.0 must both be supported. TLS/SSL connections are required for any broker on a public IP. Relates to US-003 (connect MQTT source) and US-091 (REST API).
