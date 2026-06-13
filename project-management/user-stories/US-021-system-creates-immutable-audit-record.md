---
id: US-021
title: "System creates immutable audit record for every tool invocation"
slug: "system-creates-immutable-audit-record"
personas: [P-003, P-005]
epic: "Audit Trail"
priority: "must-have"
complexity: "L"
tags: [audit, immutability, compliance, core]
---

# US-021: System Creates Immutable Audit Record for Every Tool Invocation

## User Story

**As a** Security Engineer (P-003) or Engineering Manager (P-005),
**I want the** system to create an immutable, append-only audit record for every MCP tool invocation,
**So that** there is a tamper-proof history of all actions for compliance reporting, incident investigation, and forensic analysis.

## Acceptance Criteria

- [ ] Given any MCP tool invocation (allowed or denied), when the request completes processing, then the system writes an audit record to the append-only audit store containing: timestamp, request_id, caller (id, name, ip), user (id, email, org), tool (server, name, version), arguments (redacted per policy), policy (decision, rules_evaluated, matched_rule), and result (status, duration_ms, error if any).
- [ ] Given an audit record that has been written, when any user or system process attempts to modify or delete it, then the operation is rejected and the attempt is logged as a security event.
- [ ] Given the audit store, when the system writes a batch of audit records, then each record includes a cryptographic hash chained to the previous record (hash chain), enabling tamper detection for the entire sequence.
- [ ] Given a high-throughput period (e.g., 10,000 invocations per second), when audit records are generated, then the system writes them asynchronously within 5 seconds of invocation completion without blocking the request path.
- [ ] Given the audit store reaches a configurable retention threshold, when old records are archived, then the system moves them to cold storage (S3 or equivalent) while preserving the hash chain integrity for the remaining records.

## Notes

The audit record schema is defined in the README architecture section. Immutability is enforced at the storage layer (append-only PostgreSQL table with row-level security preventing updates/deletes). The hash chain provides cryptographic proof of completeness. This is the foundation for US-022 (querying), US-023 (export), US-024 (redaction), and US-025 (anomaly detection). Related to US-007, US-008, US-019.
