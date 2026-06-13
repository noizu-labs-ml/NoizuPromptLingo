---
id: US-070
title: "Bulk Device Operations"
slug: "bulk-device-operations"
personas: [P-001, P-007]
epic: "Fleet & Device Management"
priority: "should-have"
complexity: "M"
tags: [bulk, operations, fleet, efficiency]
---

# US-070: Bulk Device Operations

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** select multiple devices in the explorer and perform bulk operations such as assign agent, update metadata, add to group, or trigger a playbook,
**So that** I can manage large fleets efficiently without repeating the same action on each device individually.

## Acceptance Criteria

- [ ] Given I select multiple devices using checkboxes in the Device Explorer, when I open the "Bulk Actions" menu, then I see options for: assign/reassign agent, add to group, remove from group, add tag, remove tag, trigger playbook, and export.
- [ ] Given I trigger a bulk playbook execution, when I confirm, then the action is dispatched respecting the same safety limits (US-054) and approval gates (US-055) as any other action.
- [ ] Given a bulk operation affects more than 100 devices, when I initiate it, then the system shows a confirmation prompt with the exact device count and impact summary before proceeding.
- [ ] Given a bulk operation partially fails (some devices succeed, others fail), when the operation completes, then I see a results summary broken down by success/failure with a list of failed devices and reasons.
- [ ] Given I want to select all devices matching the current filter, when I use "Select All", then all devices matching the current filter are selected (not just the visible page), and the selection count reflects the full filtered set.

## Notes

Select All across pages requires careful UX to avoid inadvertent mass operations. Connects to US-065 (segmentation), US-066 (grouping), and US-068 (metadata).
