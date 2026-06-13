---
id: US-021
title: "Core Overview Dashboard"
slug: "overview-dashboard"
personas: [P-001, P-002, P-003]
epic: "Core Dashboard"
priority: "must-have"
complexity: "L"
tags: [dashboard, overview, fleet, agents, summary]
---

# US-021: Core Overview Dashboard

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** see a single-screen overview of my fleet's operational status, active agents, and recent events when I log in,
**So that** I can assess the health of my operations at a glance without navigating multiple pages.

## Acceptance Criteria

- [ ] Given I log in and am taken to the dashboard, when the page loads, then I see summary tiles for: total devices, devices online, devices offline, active agents, open anomalies, and actions taken in the last 24 hours.
- [ ] Given the dashboard loads, when I view the summary tiles, then each tile shows the current value alongside a delta indicator (up/down arrow with percentage change vs. prior 24 hours).
- [ ] Given I click any summary tile, when I am navigated away, then I land on the corresponding detail page pre-filtered to match the tile's context (e.g., clicking "Offline Devices" shows the device list filtered to offline).
- [ ] Given the dashboard is open, when any metric changes by more than 10% within the current session, then the affected tile updates in real time without a full page reload.
- [ ] Given I am on mobile (P-008 field tech), when I view the dashboard, then the summary tiles stack vertically in a readable single-column layout without horizontal scrolling.

## Notes

Dashboard layout should be role-aware: Operators see actionable items prominently; Viewers see read-only status. Dashboard widget customization (reordering, hiding tiles) is a could-have for a later sprint.
