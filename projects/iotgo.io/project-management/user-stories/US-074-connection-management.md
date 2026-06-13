---
id: US-074
title: "Connection Management (MQTT and Cloud Sources)"
slug: "connection-management"
personas: [P-001, P-004]
epic: "Settings & Administration"
priority: "must-have"
complexity: "L"
tags: [connections, MQTT, AWS-IoT, Azure, integration, admin]
---

# US-074: Connection Management (MQTT and Cloud Sources)

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** configure and manage connections to IoT data sources (AWS IoT Core, Azure IoT Hub, ThingsBoard, raw MQTT brokers) from the Settings panel,
**So that** IoTGo agents can receive telemetry from existing infrastructure without requiring code changes to the source systems.

## Acceptance Criteria

- [ ] Given I add a new connection, when I select the connection type, then I see a type-specific configuration form (e.g., AWS IoT: endpoint URL, certificate, private key; MQTT: broker host, port, TLS options, credentials).
- [ ] Given I save a connection configuration, when it is stored, then credentials are encrypted at rest and never returned in plaintext via the API; I can update credentials but not retrieve them.
- [ ] Given a connection is configured, when I click "Test Connection", then the system attempts to connect and subscribe to a test topic, returning a success or failure result with an error message if applicable, within 10 seconds.
- [ ] Given a connection is active, when I view the connections list, then I see each connection's status (connected / disconnected / error), last successful message timestamp, and message throughput (messages/sec).
- [ ] Given a connection goes into an error state, when the error persists for more than 5 minutes, then an alert is raised and notifications are sent per US-073 preferences.

## Notes

Credential storage must comply with org-level security policy; consider Infisical or equivalent secrets manager for production. ThingsBoard connection uses its MQTT or REST API. Connects to US-002 (onboarding wizard) which walks through first connection setup.
