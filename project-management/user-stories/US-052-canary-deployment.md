---
id: US-052
title: "Canary Deployment for Playbook Actions"
slug: "canary-deployment"
personas: [P-001, P-007]
epic: "Action Execution & Remediation"
priority: "must-have"
complexity: "L"
tags: [canary, deployment, safety, rollout]
---

# US-052: Canary Deployment for Playbook Actions

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** roll out a playbook action to a small canary subset of devices before the full fleet,
**So that** I can validate the action's effect in production without risking a fleet-wide outage.

## Acceptance Criteria

- [ ] Given I am configuring a playbook action, when I enable canary mode, then I can specify a canary size as either a percentage (1–20%) or a fixed device count.
- [ ] Given a canary rollout is in progress, when the canary phase completes, then the system displays a health comparison (pre/post metrics) for canary devices alongside a "Proceed" and "Abort" prompt.
- [ ] Given I click "Proceed", when the full rollout begins, then the system applies the action to remaining devices in configurable batch sizes with a configurable inter-batch delay.
- [ ] Given canary devices report anomalous health after action execution, when the automated health check threshold is breached, then the system automatically halts the rollout and notifies me before proceeding to the full fleet.
- [ ] Given any stage of canary rollout, when I choose to abort, then no further devices are targeted and already-modified canary devices are flagged for optional rollback.

## Notes

Relies on fleet segmentation (US-065) to select canary subsets by tag or group. Connects to US-053 (rollback) for the abort path.
