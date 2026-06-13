---
id: US-024
title: "System redacts sensitive arguments in audit records per policy"
slug: "system-redacts-sensitive-arguments"
personas: [P-003, P-006]
epic: "Audit Trail"
priority: "must-have"
complexity: "M"
tags: [audit, redaction, privacy, compliance, security]
---

# US-024: System Redacts Sensitive Arguments in Audit Records Per Policy

## User Story

**As a** Security Engineer (P-003) or Enterprise IT Admin (P-006),
**I want the** system to automatically redact sensitive tool arguments (e.g., API keys, passwords, PII) in audit records based on configurable redaction policies,
**So that** audit logs are safe for broad access and compliance review without exposing sensitive data that was passed as tool arguments.

## Acceptance Criteria

- [ ] Given a tool invocation with arguments containing a field matching a redaction rule (e.g., `password`, `api_key`, `token`, `ssn`), when the audit record is written, then the matching fields are replaced with `[REDACTED:{type}]` (e.g., `[REDACTED:password]`) in the stored record.
- [ ] Given the redaction policy editor, when the user adds a redaction rule, then the rule specifies: argument name pattern (glob or JSON path), redaction type (full, partial, hash), and an optional regex for detecting sensitive values in free-text fields.
- [ ] Given a "partial" redaction type on an `email` argument, when the audit record is written, then the value is partially masked (e.g., `j***@example.com`) preserving enough context for analysis without exposing the full address.
- [ ] Given a "hash" redaction type on an `api_key` argument, when the audit record is written, then the value is replaced with its SHA-256 hash, enabling deduplication and correlation without revealing the original value.
- [ ] Given a Security Engineer with the `audit:unredacted` permission, when they view an audit record, then the system offers a "View unredacted" toggle that reveals the original arguments for incident investigation, with the access logged as a separate audit event.

## Notes

Redaction happens at write time in the audit store, not at read time -- redacted values are never stored in the clear in the primary audit table. The `audit:unredacted` permission is tightly controlled and typically limited to Security Engineers during active incident response. Redaction policies are defined at the organization level. Related to US-021, US-022, US-023.
