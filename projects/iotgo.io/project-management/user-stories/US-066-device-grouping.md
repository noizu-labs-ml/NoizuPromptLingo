---
id: US-066
title: "Device Grouping"
slug: "device-grouping"
personas: [P-003, P-008]
epic: "Fleet & Device Management"
priority: "should-have"
complexity: "S"
tags: [groups, organization, device, fleet]
---

# US-066: Device Grouping

## User Story

**As a** Smart Building Facility Manager (P-003),
**I want to** create static device groups and assign devices to them manually,
**So that** I can organize devices by operational responsibility (e.g., "HVAC Zone A", "Elevator Bank 2") independent of auto-computed segments.

## Acceptance Criteria

- [ ] Given I create a device group, when I name and save it, then I can immediately assign devices to it by selecting from the full device list or by searching by name or ID.
- [ ] Given a device is assigned to a group, when I view the device's detail page, then its group memberships are listed and I can remove it from a group directly from that view.
- [ ] Given I view a group, when it loads, then I see the member count, member devices list, and any agents or playbooks currently scoped to this group.
- [ ] Given I delete a group, when I confirm the deletion, then no devices are deleted — only the group association is removed, and playbooks referencing the group are flagged as needing re-targeting.
- [ ] Given a device is in multiple groups, when I view the device, then all group memberships are listed.

## Notes

Groups are static (manually managed) while segments (US-065) are dynamic (rule-based). Both can be used as targeting criteria in playbooks. Groups are simpler and appropriate for smaller, stable organizational units.
