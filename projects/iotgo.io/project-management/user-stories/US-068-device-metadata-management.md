---
id: US-068
title: "Device Metadata Management"
slug: "device-metadata-management"
personas: [P-001, P-003]
epic: "Fleet & Device Management"
priority: "should-have"
complexity: "S"
tags: [metadata, tags, device, customization]
---

# US-068: Device Metadata Management

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** add, edit, and remove custom metadata fields and tags on devices individually or in bulk,
**So that** I can enrich the device inventory with operational context (owner, SLA tier, install date, physical location notes) that is not available from the IoT platform itself.

## Acceptance Criteria

- [ ] Given I edit a device's metadata, when I add a custom key-value pair, then it is saved immediately and visible in the device detail view and searchable in the device explorer.
- [ ] Given I want to apply the same metadata to multiple devices, when I select devices in the explorer and choose "Edit Metadata", then I can add or remove tags and set key-value fields on all selected devices in one operation.
- [ ] Given I define organization-level metadata schema (optional), when I add metadata to a device, then I can choose from predefined keys with type validation (string, number, date, enum) or add free-form keys.
- [ ] Given a metadata key is used in a segment rule (US-065), when I attempt to delete that key from a device, then I am warned that the device may leave the segment and must confirm.
- [ ] Given I import devices via CSV, when the CSV includes metadata columns, then those values are applied to the matching devices on import.

## Notes

Metadata schema definition is optional (could-have for MVP). Bulk metadata operations are important for large fleets — prioritize performance for batches of 500+ devices.
