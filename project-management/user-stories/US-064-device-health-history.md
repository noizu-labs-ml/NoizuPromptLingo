---
id: US-064
title: "Device Health History"
slug: "device-health-history"
personas: [P-002, P-003]
epic: "Fleet & Device Management"
priority: "should-have"
complexity: "M"
tags: [health, history, timeline, device]
---

# US-064: Device Health History

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** view a chronological health timeline for any device showing health score changes, anomaly events, and agent interventions,
**So that** I can understand the reliability history of a device and make informed decisions about repair, replacement, or policy changes.

## Acceptance Criteria

- [ ] Given I open a device's health history, when it loads, then I see a timeline chart of the device's health score over the past 30 days (default) with configurable range.
- [ ] Given the timeline is displayed, when I hover over a health score change, then a tooltip shows the timestamp, the score change, the triggering anomaly (if any), and the agent action taken.
- [ ] Given an agent action was executed during the time range, when I click its marker on the timeline, then a summary panel shows action type, outcome, and a link to the full audit entry.
- [ ] Given I want to export device health history, when I click "Export", then I can download a CSV of health score readings with timestamps and associated event labels.
- [ ] Given the device has been offline for extended periods, when those periods appear on the timeline, then they are visually distinct (e.g., grey shading) and labeled "Offline".

## Notes

Health score computation methodology should be documented in a tooltip or link. Connects to US-062 (device detail) and US-056 (audit trail).
