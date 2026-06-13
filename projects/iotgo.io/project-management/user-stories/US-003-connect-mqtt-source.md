---
id: US-003
title: "Connect MQTT Broker as Data Source"
slug: "connect-mqtt-source"
personas: [P-001, P-007]
epic: "Onboarding & Fleet Connection"
priority: "must-have"
complexity: "M"
tags: [onboarding, mqtt, integration, data-source]
---

# US-003: Connect MQTT Broker as Data Source

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** connect my existing MQTT broker to IoTGo by providing connection credentials,
**So that** the platform can ingest telemetry from my device fleet without replacing my current infrastructure.

## Acceptance Criteria

- [ ] Given I am on the "Connect Source" step, when I select "MQTT Broker," then I am presented with fields for broker host, port, protocol (MQTT/MQTTS), client ID, username, password, and topic filter patterns.
- [ ] Given I submit valid MQTT credentials, when IoTGo tests the connection, then a success indicator appears showing "Connected" along with a live message count per second.
- [ ] Given the MQTT connection test fails, when the system reports the error, then the error message distinguishes between authentication failure, unreachable host, and TLS certificate issues.
- [ ] Given a successfully connected MQTT source, when I return to the Sources page, then the broker appears in a sources list with status, message rate, and last-seen timestamp.

## Notes

Supports MQTT v3.1.1 and v5. TLS certificate upload (CA cert, client cert/key) must be supported for mutual TLS deployments. See US-004 and US-005 for cloud IoT source connections.
