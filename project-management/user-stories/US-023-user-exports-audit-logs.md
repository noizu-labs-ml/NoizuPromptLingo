---
id: US-023
title: "User exports audit logs for compliance reporting"
slug: "user-exports-audit-logs"
personas: [P-003, P-006]
epic: "Audit Trail"
priority: "should-have"
complexity: "M"
tags: [audit, export, compliance, reporting]
---

# US-023: User Exports Audit Logs for Compliance Reporting

## User Story

**As a** Security Engineer (P-003) or Enterprise IT Admin (P-006),
**I want to** export filtered audit logs in standard formats (JSON, CSV) for external compliance reporting and archival,
**So that** I can provide evidence of access controls and usage patterns to auditors, regulators, and internal compliance teams.

## Acceptance Criteria

- [ ] Given the audit log query interface with active filters, when the user clicks "Export," then the system presents format options (JSON, CSV), date range confirmation, and an estimate of the export size and record count.
- [ ] Given a confirmed export request, when the system processes it, then the export is generated as a background job and the user receives a notification (email and dashboard) with a download link when complete.
- [ ] Given an export in JSON format, when the user downloads it, then each audit record is a complete JSON object matching the audit record schema (timestamp, caller, user, tool, args, policy, result) with redacted arguments as stored.
- [ ] Given an export in CSV format, when the user downloads it, then the CSV contains flattened columns for all top-level fields, with nested objects (caller, user, policy) serialized as JSON strings in their respective columns.
- [ ] Given an export containing more than 100,000 records, when the system generates it, then the export is split into multiple files (max 100,000 records each) and delivered as a ZIP archive with a manifest file listing all included files and the total record count.

## Notes

Exports respect the same argument redaction policies applied to in-app audit viewing (US-024). Export files are retained for 7 days and then automatically deleted. All export actions are themselves logged as audit events (who exported what, when, which filters). Related to US-021, US-022, US-024.
