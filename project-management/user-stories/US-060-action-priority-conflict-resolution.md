---
id: US-060
title: "Action Priority and Conflict Resolution"
slug: "action-priority-conflict-resolution"
personas: [P-004, P-001]
epic: "Action Execution & Remediation"
priority: "should-have"
complexity: "M"
tags: [priority, conflict, queue, orchestration]
---

# US-060: Action Priority and Conflict Resolution

## User Story

**As a** DevOps/SRE Lead (P-004),
**I want to** assign priorities to playbook actions and have the system detect and resolve conflicts when multiple actions target the same device simultaneously,
**So that** critical remediations are not delayed by lower-priority maintenance tasks, and devices are never placed in an undefined state by concurrent conflicting changes.

## Acceptance Criteria

- [ ] Given multiple actions are queued for the same device, when I view the action queue, then actions are ordered by priority (critical > high > normal > low) and I can see if any actions are waiting due to a conflict.
- [ ] Given two actions target the same device and modify the same configuration key, when the conflict is detected, then the lower-priority action is automatically held until the higher-priority action completes, and I am notified of the hold.
- [ ] Given I assign a "critical" priority to an action, when it is queued, then it preempts any currently executing lower-priority action on the same device (with the preempted action resuming after the critical action completes).
- [ ] Given an action conflict cannot be automatically resolved (e.g., same priority level), when it is detected, then both actions are paused and a conflict resolution prompt is surfaced to the user.
- [ ] Given I resolve a conflict by selecting which action proceeds first, when the decision is saved, then it is recorded in the audit log with the resolver's identity and reasoning.

## Notes

Priority levels map to playbook YAML metadata. Preemption behavior is gated by autonomy level (US-075); at lower autonomy levels preemption requires approval.
