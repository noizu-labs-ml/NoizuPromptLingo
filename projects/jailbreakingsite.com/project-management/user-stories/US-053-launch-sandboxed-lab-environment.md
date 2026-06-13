---
id: US-053
title: "Launch a Sandboxed Lab Environment"
slug: "launch-sandboxed-lab-environment"
personas: [P-008, P-001, P-003]
epic: "Academy — Labs"
priority: "must-have"
complexity: "XL"
tags: [academy, labs, sandbox, environment, infrastructure]
---

# US-053: Launch a Sandboxed Lab Environment

## User Story

**As an** AI red team lead (P-001),
**I want to** launch a sandboxed lab environment that provides a live LLM interface, challenge context, and submission panel in a single browser session,
**So that** I can work through attack or defense challenges against a real model without needing local setup or risking cross-contamination between sessions.

## Acceptance Criteria

- [ ] Given I click "Launch Lab" on a lab detail page, when the environment provisions, then within 30 seconds I see a three-panel workspace: mission brief (left), interactive LLM chat interface (center), submission/flag panel (right)
- [ ] Given the lab environment is active, when I interact with the LLM interface, then requests are routed to a sandboxed model instance scoped to this session with the lab's system prompt and guardrails pre-configured
- [ ] Given my lab session is active, when I navigate away or close the tab, then my session state (chat history, attempts) is preserved for at least 24 hours and I can resume
- [ ] Given a session exceeds its time limit (configurable per lab), when the limit is reached, then I receive a warning 5 minutes prior and the session closes gracefully with my progress saved
- [ ] Given the sandbox environment, when I submit a successful jailbreak or solution, then the submission panel accepts my flag/output and queues it for scoring
- [ ] Given infrastructure constraints, when lab capacity is reached, then I am placed in a visible queue with estimated wait time rather than receiving a silent failure

## Notes

This is the most infrastructure-intensive story in the Academy epic — requires per-session LLM sandbox isolation, session persistence, and queue management. Each lab type (attack vs. defense) will have a different workspace layout; this story targets the attack lab baseline. Sandbox LLM costs must be rate-limited per user tier.
