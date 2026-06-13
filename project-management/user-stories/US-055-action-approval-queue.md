---
id: US-055
title: "Action Approval Queue"
slug: "action-approval-queue"
personas: [P-002, P-005]
epic: "Action Execution & Remediation"
priority: "must-have"
complexity: "M"
tags: [approval, queue, governance, autonomy]
---

# US-055: Action Approval Queue

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** review and approve or reject pending agent actions before they execute on critical devices,
**So that** my team retains human oversight over consequential changes even as agents operate autonomously on lower-priority tasks.

## Acceptance Criteria

- [ ] Given an agent proposes an action on a device or group configured to require human approval (autonomy level 1 or 2), when the action is queued, then it appears in the Approval Queue with: proposed action, affected devices, triggering anomaly, and agent confidence score.
- [ ] Given I am reviewing a pending action, when I click "Approve", then execution begins immediately and the action transitions to "Running" state.
- [ ] Given I am reviewing a pending action, when I click "Reject" and provide a reason, then the action is cancelled, the agent logs the rejection, and the reason is stored in the audit trail.
- [ ] Given an action has been waiting for approval longer than the configured SLA (default 30 minutes), when the deadline passes, then the system escalates via notification and optionally auto-rejects.
- [ ] Given I have the Operations Manager role, when I open the queue, then I see only actions scoped to device groups I am authorized to manage.

## Notes

Approval SLA and auto-reject behavior are configurable in US-075 (autonomy policy configuration). Audit trail integration covered in US-056.
