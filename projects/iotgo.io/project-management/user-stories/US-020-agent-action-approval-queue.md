---
id: US-020
title: "Review and Approve Queued Agent Actions"
slug: "agent-action-approval-queue"
personas: [P-001, P-002]
epic: "Agent Management"
priority: "must-have"
complexity: "L"
tags: [agents, autonomy, approval, queue, level-3, human-in-the-loop]
---

# US-020: Review and Approve Queued Agent Actions

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** review a queue of actions that an agent at Level 3 (Act with Approval) has proposed and approve or reject each one,
**So that** I maintain human control over consequential automated actions while still benefiting from AI-generated remediation suggestions.

## Acceptance Criteria

- [ ] Given an agent at Level 3 proposes an action, when the action is queued, then it appears in the Approval Queue with: agent name, target device(s), proposed action description, triggering anomaly, and an expiry time after which the action expires unexecuted.
- [ ] Given I open an action in the Approval Queue, when I review it, then I see the full agent reasoning that led to the proposal, the expected outcome, and any risk warnings the agent identified.
- [ ] Given I click "Approve," when the approval is confirmed, then the action is dispatched to the target device immediately and I receive a result notification (success/failure) within the action's expected completion time.
- [ ] Given I click "Reject," when I optionally provide a reason, then the action is discarded, the agent logs the rejection, and the agent learns to surface the rejection reason in future similar proposals (if ML feedback is enabled).
- [ ] Given multiple actions are queued, when I view the queue, then I can bulk-approve or bulk-reject actions filtered by agent or severity, with a single confirmation step for bulk operations.

## Notes

Action expiry time should be configurable per agent (default: 4 hours for non-critical, 30 minutes for critical). Expired actions should be visible in a separate "Expired" tab for audit purposes. Relates to US-013 (autonomy levels) and US-014 (reasoning log).
