---
id: US-075
title: "Autonomy Policy Configuration"
slug: "autonomy-policy-configuration"
personas: [P-005, P-001]
epic: "Settings & Administration"
priority: "must-have"
complexity: "XL"
tags: [autonomy, policy, governance, safety, admin]
---

# US-075: Autonomy Policy Configuration

## User Story

**As an** IT Security Director (P-005),
**I want to** define and enforce autonomy policies that control how much independent authority agents have to execute actions across different device groups and action categories,
**So that** I can calibrate AI autonomy to organizational risk tolerance — fully autonomous for low-risk routine tasks, human-gated for consequential or irreversible changes.

## Acceptance Criteria

- [ ] Given I open autonomy policy settings, when I configure a policy, then I can set the autonomy level (0=monitor-only, 1=recommend+manual-trigger, 2=auto-execute+notify, 3=auto-execute+log, 4=fully-autonomous) per combination of device group and action category (configuration change, firmware update, restart, network change, data export).
- [ ] Given an autonomy level is set to 1 or 2, when an agent proposes an action, then it appears in the Approval Queue (US-055) and cannot execute without human confirmation.
- [ ] Given an autonomy level is set to 3 or 4, when an agent executes an action, then the action is logged in the audit trail (US-056) and a notification is sent per preferences (US-073) but no approval gate is shown.
- [ ] Given I configure a policy, when I save it, then I can preview which currently pending and recurring actions would be affected by the new policy before it takes effect.
- [ ] Given an agent attempts an action outside its assigned autonomy level, when the attempt is made, then the action is blocked, logged as a policy violation, and escalated as a notification.
- [ ] Given a policy change is saved, when I view the policy history, then I see a timestamped log of all previous policy configurations with the user who made each change.

## Notes

This is the governance backbone of the entire platform — every action execution path checks autonomy policy. Level 4 (fully autonomous) should require explicit org-admin confirmation and is disabled by default. Connects to US-054 (safety limits), US-055 (approval queue), US-056 (audit trail), and US-060 (priority/conflict resolution).
