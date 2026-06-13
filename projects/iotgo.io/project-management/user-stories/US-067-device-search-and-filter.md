---
id: US-067
title: "Device Search and Filter"
slug: "device-search-and-filter"
personas: [P-008, P-001]
epic: "Fleet & Device Management"
priority: "must-have"
complexity: "S"
tags: [search, filter, device, explorer]
---

# US-067: Device Search and Filter

## User Story

**As a** Junior IoT Technician/Field Operator (P-008),
**I want to** quickly search for a device by name, ID, or tag and apply multi-faceted filters to narrow down large device lists,
**So that** I can locate the specific device I am troubleshooting without scrolling through hundreds of entries.

## Acceptance Criteria

- [ ] Given I type in the search box, when I have entered at least 2 characters, then results matching device name, device ID, or any tag value are shown within 300ms.
- [ ] Given I want to filter by multiple criteria, when I open the filter panel, then I can combine filters for: connection status, health score range, device type, location, group, segment, last seen range, and firmware version.
- [ ] Given I apply filters, when results are shown, then the active filter count is displayed on the filter button and each active filter is shown as a dismissible chip.
- [ ] Given I clear all filters, when the clear action fires, then the full unfiltered device list is restored and the search box is also cleared.
- [ ] Given I save a filter combination as a named "saved view", when I return to the Device Explorer in a future session, then my saved views are available in a dropdown for one-click recall.

## Notes

Saved views are per-user and stored server-side. Search and filter state feeds the Device Explorer (US-061) and should be shareable via URL parameters for team collaboration.
