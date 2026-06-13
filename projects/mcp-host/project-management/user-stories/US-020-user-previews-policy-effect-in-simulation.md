---
id: US-020
title: "User previews policy effect in simulation mode before deploying"
slug: "user-previews-policy-effect-in-simulation"
personas: [P-003, P-004]
epic: "Policy Engine"
priority: "should-have"
complexity: "L"
tags: [policy, simulation, dry-run, safemcp, testing]
---

# US-020: User Previews Policy Effect in Simulation Mode Before Deploying

## User Story

**As a** Security Engineer (P-003) or AI/ML Engineer (P-004),
**I want to** simulate the effect of a proposed policy change against recent request history before activating it,
**So that** I can verify the policy behaves as expected and avoid accidentally blocking legitimate traffic or allowing unintended access.

## Acceptance Criteria

- [ ] Given a draft policy in the policy editor, when the user clicks "Simulate," then the system replays the last N hours of actual requests (configurable, default 24 hours) through the draft policy and reports how many requests would have been allowed vs. denied compared to the current active policy.
- [ ] Given a simulation result, when the user views the details, then the system displays a diff view: requests that would change from allow-to-deny (potential breakage), deny-to-allow (potential security risk), and unchanged, with each entry showing the full request context and evaluation trace.
- [ ] Given a simulation that shows a high-impact change (e.g., more than 10% of requests would be newly denied), when the user views the summary, then the system displays a prominent warning with the count of affected callers and tools.
- [ ] Given a simulation result, when the user clicks on a specific request in the diff, then the system shows the full policy evaluation trace for that request under both the current and proposed policies, side by side.
- [ ] Given a simulation that the user is satisfied with, when they click "Deploy this policy," then the system activates the policy, logs the change in the audit trail, and monitors the first 100 requests under the new policy for any unexpected denials (with an option to auto-rollback if the denial rate exceeds a threshold).

## Notes

Simulation mode is a SafeMCP feature and a key differentiator. It uses real production traffic replayed through the proposed policy -- not synthetic test data. The simulation must not affect live traffic; it is a read-only evaluation against historical request data stored in the audit trail. Related to US-008, US-019 (policy logs), US-021 (audit records).
