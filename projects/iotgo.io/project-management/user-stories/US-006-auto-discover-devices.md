---
id: US-006
title: "Auto-Discover and Inventory Devices"
slug: "auto-discover-devices"
personas: [P-001, P-003]
epic: "Onboarding & Fleet Connection"
priority: "must-have"
complexity: "L"
tags: [onboarding, discovery, fleet, inventory, devices]
---

# US-006: Auto-Discover and Inventory Devices

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** IoTGo to automatically discover and inventory all devices from my connected sources,
**So that** I have a complete, queryable device registry without manually registering each device.

## Acceptance Criteria

- [ ] Given a connected data source, when IoTGo runs discovery, then all devices actively publishing telemetry within the past 24 hours are added to the device inventory with name, source, first-seen, and last-seen timestamps.
- [ ] Given device discovery completes, when I view the device list, then I can filter by source, device type (if inferrable), tag, and online/offline status.
- [ ] Given a device publishes telemetry with a new topic or device ID not previously seen, when the message arrives, then the device is automatically added to inventory within 30 seconds.
- [ ] Given I view a discovered device's detail page, when I inspect its telemetry schema, then I see a summary of observed fields, data types, and value ranges from the last 100 messages.
- [ ] Given discovery yields more than 1,000 new devices in a single run, when the job completes, then I receive a summary notification showing count, breakdown by type, and any devices that failed schema inference.

## Notes

Schema inference is best-effort; manual overrides are needed for ambiguous payloads (addressed in a later story). Device grouping and tagging covered in a future epic.
