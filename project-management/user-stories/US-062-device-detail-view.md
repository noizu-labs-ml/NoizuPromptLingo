---
id: US-062
title: "Device Detail View"
slug: "device-detail-view"
personas: [P-001, P-008]
epic: "Fleet & Device Management"
priority: "must-have"
complexity: "L"
tags: [device, detail, telemetry, health]
---

# US-062: Device Detail View

## User Story

**As a** Junior IoT Technician/Field Operator (P-008),
**I want to** open a single device's detail page and see all relevant status, telemetry, and history in one place,
**So that** I can quickly diagnose issues, understand recent agent activity, and take manual action when needed.

## Acceptance Criteria

- [ ] Given I open a Device Detail page, when it loads, then I see: device name, ID, type, firmware version, connection status, last seen timestamp, current health score, assigned agent(s), location, and tags.
- [ ] Given the device is connected, when I view the telemetry panel, then the most recent values for all reported telemetry keys are shown with their units and timestamp.
- [ ] Given I click on the "Actions" tab, when it loads, then I see the 10 most recent actions executed against this device with status and a link to the full execution detail.
- [ ] Given I click on the "Alerts" tab, when it loads, then I see active and resolved alerts for this device sorted by severity.
- [ ] Given I have sufficient permissions, when I click "Run Action", then I can manually trigger a playbook against this single device from the detail view.

## Notes

Telemetry history charts are expanded in US-063 (telemetry viewer). Device health history timeline is covered in US-064.
