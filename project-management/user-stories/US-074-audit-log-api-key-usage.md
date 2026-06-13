---
id: US-074
title: "Audit log of all API key usage"
slug: "audit-log-api-key-usage"
personas: [P-004, P-005, P-007]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "M"
tags: [admin, audit-log, api-keys, compliance, security]
---

# US-074: Audit Log of All API Key Usage

## User Story

**As a** Enterprise Architect (P-005),
**I want to** access a searchable audit log of all API key activity including generation requests, key creation, and revocation events,
**So that** I can investigate incidents, verify compliance, and trace unauthorized usage.

## Acceptance Criteria

- [ ] Given the admin audit log page, when loaded, then all API events are listed with: timestamp, key ID (masked), event type, user ID, IP address, and result (success/failure)
- [ ] Given the audit log, when I filter by key ID, user ID, event type, or date range, then the log is scoped to matching entries
- [ ] Given an audit log entry, when I expand it, then the full request metadata is shown (endpoint, parameters, response code) excluding sensitive field values
- [ ] Given audit log data, when I click "Export", then a CSV or JSON export of the current filtered view is downloaded

## Notes

Audit log entries must be immutable — no admin action can delete or modify them. Retention policy (e.g., 90 days) should be configurable in system settings. Log storage should be append-only, ideally written to a separate table or log sink. Connects to US-066 (key management), US-073 (moderation actions), and US-075 (force-revoke).
