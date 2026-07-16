---
id: US-063
title: "Explain a PBAC Policy Denial"
slug: "explain-a-pbac-policy-denial"
personas: [P-006]
epic: "Admin & Platform Operations"
priority: "should-have"
complexity: "S"
tags: [admin, pbac, policy-explain]
---

# US-063: Explain a PBAC Policy Denial

## User Story

**As a** Platform Administrator, Ilya Petrov (P-006),
**I want to** see an explanation of why a PBAC policy check denied access (`/policies/explain`),
**So that** I can diagnose misconfigured policies without guessing which rule caused the denial.

## Acceptance Criteria

- [ ] Given Ilya has a denied result from a policy check (US-062), when he requests an explanation for that same actor/action/resource combination, then the system returns the specific policy rule(s) that caused the deny.
- [ ] Given multiple policies could plausibly apply to the combination, when the explanation is generated, then it distinguishes the policy that actually decided the outcome from ones that were evaluated but not decisive.
- [ ] Given the result would have been "allow" instead of "deny," when Ilya requests an explanation, then the explain endpoint still returns the deciding rule rather than only explaining denials.

## Notes

Pairs directly with US-062; the explanation must never contradict the decision returned by check for the same inputs.
