---
id: US-062
title: "Check a PBAC Policy Decision with the Simulator"
slug: "run-pbac-policy-simulator-check"
personas: [P-006]
epic: "Admin & Platform Operations"
priority: "should-have"
complexity: "M"
tags: [admin, pbac, policy-simulator]
---

# US-062: Check a PBAC Policy Decision with the Simulator

## User Story

**As a** Platform Administrator, Ilya Petrov (P-006),
**I want to** run a PBAC v2 policy simulator check (`/policies/check`) for a given actor/action/resource combination,
**So that** I can verify access-control behavior before or after a policy change without needing to reproduce it with a live user.

## Acceptance Criteria

- [ ] Given Ilya is on the policy simulator page, when he specifies an actor (user or role), an action, and a resource and runs the check, then the simulator returns a clear allow/deny decision.
- [ ] Given Ilya runs a simulated check against a hypothetical/unsaved policy change, when the simulator evaluates it, then the decision reflects the hypothetical policy rather than only the currently live one.
- [ ] Given Ilya runs a check for an actor/action/resource combination with no matching policy at all, when the simulator evaluates it, then it returns an explicit "no matching policy" / default-deny result rather than erroring.

## Notes

Decision-only; the "why" behind the decision is covered by the explain endpoint in US-063.
