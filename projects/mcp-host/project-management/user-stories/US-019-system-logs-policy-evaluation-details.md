---
id: US-019
title: "System logs policy evaluation details for each request"
slug: "system-logs-policy-evaluation-details"
personas: [P-003, P-005]
epic: "Policy Engine"
priority: "must-have"
complexity: "M"
tags: [policy, audit, logging, observability]
---

# US-019: System Logs Policy Evaluation Details for Each Request

## User Story

**As a** Security Engineer (P-003) or Engineering Manager (P-005),
**I want the** system to log detailed policy evaluation information for every MCP request, including which scopes were evaluated, which rules matched, and the final decision,
**So that** I can audit access decisions, troubleshoot unexpected denials, and demonstrate compliance to regulators.

## Acceptance Criteria

- [ ] Given any MCP tool invocation, when the Policy Engine completes evaluation, then the system writes a policy evaluation log entry containing: request ID, timestamp, caller ID, user ID, tool name, arguments (redacted per policy), each scope level evaluated, the rule matched at each level, and the final decision (allow/deny).
- [ ] Given a denied request, when the policy evaluation log is written, then the log entry includes the specific scope level and rule that caused the denial, the evaluated principal (caller or user), and the denial reason code.
- [ ] Given the audit log query interface, when a Security Engineer searches for denials by a specific caller in the last 24 hours, then the system returns all matching evaluation log entries with the full evaluation trace.
- [ ] Given the policy evaluation logs, when the system detects an unusual pattern (e.g., a caller denied at the same scope 100 times in one hour), then the system flags the pattern in the Security Engineer's dashboard as an anomaly indicator.
- [ ] Given a policy change, when the new policy is activated, then the system logs a "policy_updated" audit event recording: who changed the policy, which scope was affected, the previous policy version hash, and the new policy version hash.

## Notes

Policy evaluation logs are a subset of the full audit trail (US-021) but focus specifically on the decision-making process. They are critical for debugging "why was this denied?" questions. Log entries are immutable and append-only. Related to US-008, US-021 (audit records), US-022 (querying).
