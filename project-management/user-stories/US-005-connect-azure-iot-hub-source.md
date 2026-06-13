---
id: US-005
title: "Connect Azure IoT Hub as Data Source"
slug: "connect-azure-iot-hub-source"
personas: [P-001, P-004]
epic: "Onboarding & Fleet Connection"
priority: "should-have"
complexity: "M"
tags: [onboarding, azure, integration, data-source, cloud]
---

# US-005: Connect Azure IoT Hub as Data Source

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** connect my Azure IoT Hub to IoTGo using a service principal or connection string,
**So that** I can manage Azure-hosted device fleets alongside other sources in a single pane of glass.

## Acceptance Criteria

- [ ] Given I select "Azure IoT Hub" as the source type, when the form renders, then I can provide either an IoT Hub connection string (shared access policy) or an Azure service principal (tenant ID, client ID, client secret, subscription ID, hub name).
- [ ] Given valid credentials are submitted, when the system connects, then it lists all discovered IoT Hub instances accessible to the credentials and allows me to select which to monitor.
- [ ] Given a connected Azure IoT Hub, when the platform syncs device registry, then device twin properties and tags are imported and exposed as filterable metadata in the device list.
- [ ] Given I have both AWS IoT and Azure IoT Hub connected, when I view the fleet overview, then devices from both sources appear in a unified list with a "source" badge distinguishing their origin.

## Notes

Azure Event Hub routing for high-throughput telemetry ingestion should be a follow-on capability. ThingsBoard connection is a separate integration not covered in this batch.
