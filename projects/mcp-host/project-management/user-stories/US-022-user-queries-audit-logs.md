---
id: US-022
title: "User queries audit logs by caller, user, tool, time range"
slug: "user-queries-audit-logs"
personas: [P-003, P-005]
epic: "Audit Trail"
priority: "must-have"
complexity: "M"
tags: [audit, querying, filtering, observability]
---

# US-022: User Queries Audit Logs by Caller, User, Tool, Time Range

## User Story

**As a** Security Engineer (P-003) or Engineering Manager (P-005),
**I want to** search and filter audit logs by caller identity, user identity, tool name, and time range,
**So that** I can quickly locate specific invocations for incident investigation, compliance review, or usage analysis.

## Acceptance Criteria

- [ ] Given the audit log query interface, when the user specifies a filter (e.g., caller ID = "claude-desktop-01", time range = last 7 days), then the system returns matching audit records sorted by timestamp (newest first) with pagination (default 50 per page).
- [ ] Given multiple filter criteria (e.g., caller ID, user email, tool name, time range, decision = denied), when the user applies all filters, then the system returns only records matching all criteria (AND logic across filters).
- [ ] Given a query result set, when the user clicks on a specific audit record, then the system displays the full record detail including the complete policy evaluation trace, redacted arguments, and the result payload.
- [ ] Given the audit log query interface, when the user saves a frequently used filter combination, then the system stores it as a named "saved query" accessible from a dropdown for quick re-use.
- [ ] Given a query that returns no results, when the user reviews the filter criteria, then the system suggests relaxing specific filters (e.g., "No results for tool 'gmail.send'. Try searching all email tools with pattern 'gmail.*'.").

## Notes

The query interface is part of the SafeMCP dashboard. Performance target: queries over 30 days of data should return first page within 2 seconds. Filter values should support autocomplete from known callers, users, and tool names. Related to US-021 (audit records), US-023 (export).
