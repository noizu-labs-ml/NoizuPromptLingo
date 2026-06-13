---
id: US-094
title: "Cloud Platform Connectors (AWS/Azure)"
slug: "cloud-platform-connectors"
personas: [P-001, P-004]
epic: "Integration & API"
priority: "should-have"
complexity: "XL"
tags: [aws, azure, cloud, integration, iot-hub]
---

# US-094: Cloud Platform Connectors (AWS/Azure)

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** connect IoTGo to AWS IoT Core and Azure IoT Hub as managed data sources using cloud credentials,
**So that** agents can consume device telemetry and shadow state from existing cloud-managed fleets without duplicating infrastructure.

## Acceptance Criteria

- [ ] Given I navigate to Sources > Cloud Connectors, when I select AWS IoT Core, then I can provide an IAM role ARN (for cross-account assume-role) or access key credentials and specify the AWS region and topic rules to bridge
- [ ] Given I select Azure IoT Hub, when I provide the IoT Hub connection string or a service principal with IoT Hub Reader role, then IoTGo establishes an Event Hub consumer and begins ingesting device-to-cloud messages
- [ ] Given a cloud connector is active, when I view the connector card, then I see messages-per-second ingestion rate, last message timestamp, and the number of recognized device IDs from that source
- [ ] Given cloud credentials are near expiration (IAM role session or SAS token), when the TTL drops below 1 hour, then the system automatically refreshes credentials and logs the refresh event
- [ ] Given a connector is paused, when I click Resume, then ingestion restarts from the current stream position (not replaying historical messages)

## Notes

AWS connector should support both IoT rule actions (SNS/SQS bridge) and direct MQTT-over-WebSocket for real-time data. Azure connector uses the built-in Event Hub compatible endpoint. Relates to US-093 (MQTT source management). GCP IoT is deferred.
