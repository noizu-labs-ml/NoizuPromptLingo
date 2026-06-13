---
id: US-053
title: "Rollback on Action Failure"
slug: "rollback-on-failure"
personas: [P-007, P-004]
epic: "Action Execution & Remediation"
priority: "must-have"
complexity: "M"
tags: [rollback, failure, remediation, safety]
---

# US-053: Rollback on Action Failure

## User Story

**As a** DevOps/SRE Lead (P-004),
**I want to** automatically or manually trigger a rollback when a playbook action fails or produces degraded device health,
**So that** I can restore devices to a known-good state without manual intervention on each affected device.

## Acceptance Criteria

- [ ] Given a playbook defines a rollback procedure, when an action step fails, then the system automatically executes the rollback steps and marks the execution as "Rolled Back" in the audit log.
- [ ] Given an action completed but device health degraded within a configurable window (default 10 minutes), when the health threshold is breached, then the system triggers the rollback procedure and surfaces an alert.
- [ ] Given a rollback is in progress, when I view the execution detail, then I see rollback step status in real time, distinct from the original action steps.
- [ ] Given I want to manually trigger rollback on a completed action, when I click "Rollback" in the action history view, then I am prompted to confirm and the rollback executes immediately.
- [ ] Given a rollback also fails, when all retry attempts are exhausted, then the device is flagged "Needs Manual Intervention" and an escalation notification is sent.

## Notes

Rollback definitions live inside playbook YAML (see US-026). Escalation connects to US-073 (notification preferences).
