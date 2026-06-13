---
id: US-084
title: "Audit Log Viewer"
slug: "audit-log-viewer"
personas: [P-005, P-004]
epic: "Security & Compliance"
priority: "must-have"
complexity: "M"
tags: [audit, security, compliance, logs]
---

# US-084: Audit Log Viewer

## User Story

**As an** IT Security Director (P-005),
**I want to** view a comprehensive audit log of all user actions and agent actions within the platform,
**So that** I can investigate security incidents, verify compliance, and maintain an authoritative record of system activity.

## Acceptance Criteria

- [ ] Given I navigate to the Audit Log, when the page loads, then I see a chronological list of events including actor (user or agent ID), action type, target resource, timestamp, and IP address for user actions
- [ ] Given the audit log is displayed, when I filter by actor, action type, date range, or resource, then the list updates immediately to show matching entries
- [ ] Given I click on a log entry, when the detail panel opens, then I see the full event payload including before/after values for any configuration changes
- [ ] Given the audit log contains many entries, when I export the filtered view, then a CSV file is generated containing all matching events within the selected date range
- [ ] Given logs are immutable, when any attempt is made to delete or modify log entries via the API, then the system returns a 403 error and the attempt itself is logged

## Notes

Audit logs must be retained for a minimum of 90 days (configurable up to 2 years). Relates to US-089 (compliance report generation) and US-085 (RBAC). Log export should support date-range spanning up to 31 days per export.
