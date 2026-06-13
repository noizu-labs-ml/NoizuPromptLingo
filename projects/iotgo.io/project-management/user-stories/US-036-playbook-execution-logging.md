---
id: US-036
title: "Playbook Execution Logging"
slug: "playbook-execution-logging"
personas: [P-004, P-005, P-007, P-008]
epic: "Playbook System"
priority: "must-have"
complexity: "M"
tags: [playbook, logging, audit, execution, observability]
---

# US-036: Playbook Execution Logging

## User Story

**As a** DevOps/SRE Lead (P-004),
**I want to** view detailed logs for every playbook execution including each condition evaluation and action outcome,
**So that** I can diagnose unexpected behavior, demonstrate compliance, and continuously improve playbook logic.

## Acceptance Criteria

- [ ] Given a playbook executes, when I open its execution log, then I see a timestamped entry for every step: trigger event, condition evaluation (true/false with values), action dispatch, action result, and total duration
- [ ] Given I filter execution logs by playbook, device, time range, or outcome (success/failure/partial), then results update immediately and are exportable as CSV or JSON
- [ ] Given a playbook execution fails at a specific step, when I view the log, then the failing step is visually highlighted with the error message, stack trace (if applicable), and the state of the device at time of failure
- [ ] Given P-005 audits the system, when they query execution logs, then every executed action is traceable to the playbook version, the triggering telemetry event, and the identity of the agent that executed it
- [ ] Given execution logs older than the configured retention period, when the retention window passes, then they are archived to cold storage and remain queryable with a latency notice

## Notes

Log retention policy should be configurable per workspace (default 90 days hot, 2 years cold). This log is foundational to US-035 (rollback) and US-033 (approval audit). Security director (P-005) must be able to export logs for compliance reporting.
