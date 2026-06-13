---
id: US-051
title: "Execute Playbook Action"
slug: "execute-playbook-action"
personas: [P-007, P-001]
epic: "Action Execution & Remediation"
priority: "must-have"
complexity: "L"
tags: [playbook, execution, remediation, agent]
---

# US-051: Execute Playbook Action

## User Story

**As a** Playbook Author/Automation Engineer (P-007),
**I want to** trigger a playbook action against one or more devices and observe its execution in real time,
**So that** I can confirm remediation steps are applied correctly and trace any failures back to specific steps.

## Acceptance Criteria

- [ ] Given an agent has identified a condition matching a playbook trigger, when the action is queued, then the UI shows the action in a "Pending" state with the triggering condition and targeted devices listed.
- [ ] Given an action is executing, when I open the execution detail panel, then I see each playbook step with status (pending / running / success / failed), elapsed time, and stdout/stderr output streamed in real time.
- [ ] Given a step fails, when execution halts, then the remaining steps are marked "skipped", a failure summary is displayed, and a rollback option is surfaced if the playbook defines one.
- [ ] Given execution completes successfully, when I view the result, then a completion timestamp, affected device count, and per-device result summary are shown.
- [ ] Given any execution, when I inspect the detail view, then I can download a full execution log as a JSON or plain-text file.

## Notes

Foundation story for the entire remediation workflow; US-052 (canary deployment) and US-053 (rollback) build on this. Execution logs feed US-056 (audit trail with reasoning chain).
