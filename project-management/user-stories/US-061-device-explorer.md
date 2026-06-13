---
id: US-061
title: "Device Explorer"
slug: "device-explorer"
personas: [P-001, P-008]
epic: "Fleet & Device Management"
priority: "must-have"
complexity: "M"
tags: [device, explorer, list, fleet]
---

# US-061: Device Explorer

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** browse all connected devices in a paginated, sortable, filterable table,
**So that** I can quickly locate devices, assess fleet-wide status at a glance, and navigate to individual device details.

## Acceptance Criteria

- [ ] Given I navigate to the Device Explorer, when the page loads, then I see a table of all devices with columns: device name, device type, location, connection status, last seen, current health score, and assigned agent.
- [ ] Given the fleet contains more than 100 devices, when I scroll or paginate, then additional devices load without full-page refresh, and the total count is displayed.
- [ ] Given I sort by any column, when the sort is applied, then the table re-orders accordingly and the sort state persists across navigation within the session.
- [ ] Given I apply a status filter (e.g., "offline", "degraded"), when the filter is active, then only matching devices are shown and a clear indication of the active filter is displayed.
- [ ] Given a device row, when I click it, then I am taken to the Device Detail view (US-062) for that device.

## Notes

Filtering and search are expanded in US-067 (device search and filter). Column visibility preferences should persist per user.
