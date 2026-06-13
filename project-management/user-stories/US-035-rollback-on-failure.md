---
id: US-035
title: "Rollback on Playbook Failure"
slug: "rollback-on-failure"
personas: [P-004, P-007, P-002]
epic: "Playbook System"
priority: "must-have"
complexity: "L"
tags: [playbook, rollback, failure-handling, safety, remediation]
---

# US-035: Rollback on Playbook Failure

## User Story

**As a** DevOps/SRE Lead (P-004),
**I want to** define rollback actions that execute automatically when a playbook's primary actions fail or produce unexpected outcomes,
**So that** devices are restored to a known-good state without requiring manual intervention after a failed automation.

## Acceptance Criteria

- [ ] Given I author a playbook, when I configure an action node, then I can attach a rollback action that executes if the primary action fails or times out
- [ ] Given a playbook execution encounters a failure, when the rollback action is triggered, then the execution log records the failure reason, rollback initiation, and rollback outcome as separate events
- [ ] Given a rollback action is defined as "restore prior configuration", when it executes, then the system reverts the device's configuration to the snapshot captured immediately before the playbook ran
- [ ] Given a rollback itself fails, when this occurs, then the system escalates to the configured escalation contact (per action library US-030) and marks the device as requiring manual intervention
- [ ] Given a playbook has a global rollback policy set, when any step fails and no step-level rollback is defined, then the global policy applies as a fallback

## Notes

Configuration snapshots for rollback should be taken at execution start. This story depends on the action library (US-030) for the escalation path and on the execution logging (US-036) for audit trail.
