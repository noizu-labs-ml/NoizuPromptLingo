---
id: US-054
title: "Parallel Execution with Safety Limits"
slug: "parallel-execution-safety-limits"
personas: [P-001, P-004]
epic: "Action Execution & Remediation"
priority: "must-have"
complexity: "M"
tags: [parallel, concurrency, safety, fleet]
---

# US-054: Parallel Execution with Safety Limits

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** configure maximum parallelism and minimum healthy-device thresholds for fleet-wide action execution,
**So that** a runaway remediation cannot simultaneously take down more devices than the fleet can tolerate.

## Acceptance Criteria

- [ ] Given I am creating or editing a playbook, when I set execution limits, then I can specify a max concurrent devices (absolute or % of fleet) and a minimum healthy fleet percentage required to continue.
- [ ] Given an action is executing in parallel, when the number of devices in a failed/degraded state reaches the minimum healthy threshold, then execution pauses immediately and an alert is raised.
- [ ] Given execution is paused due to a safety limit, when I review the state in the UI, then I see which devices are healthy vs. degraded and I can choose to resume, abort, or rollback.
- [ ] Given a playbook has no explicit limits set, when it is executed, then the system defaults to a max of 10% concurrent devices and halts if more than 20% of targeted devices fail.
- [ ] Given a fleet has fewer than 10 devices, when safety limits are evaluated, then the system uses absolute counts (not percentages) to avoid rounding to zero.

## Notes

Safety limits are per-playbook but can be overridden at execution time by users with sufficient autonomy level. Connects to US-075 (autonomy policy configuration).
