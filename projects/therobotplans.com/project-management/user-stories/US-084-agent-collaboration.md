---
id: US-084
title: "Define collaboration protocols between agents"
personas: [lin-zhao]
domain: agents
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want to define collaboration protocols between agents — such as handoff chains, review gates, and escalation paths — so that multi-agent workflows execute reliably with clear accountability at each step.

## Acceptance Criteria

- [ ] A visual protocol builder allows defining agent-to-agent handoff chains (e.g., Coder -> Reviewer -> Human Approver -> Deployer)
- [ ] Each handoff step specifies: trigger condition, data passed, timeout, and fallback action if the receiving agent is unavailable
- [ ] Escalation rules support conditional routing (e.g., "if Reviewer confidence < 70%, escalate to human instead of auto-approving")
- [ ] Protocol execution is logged as an auditable trace showing each step's input, output, agent, and decision rationale
- [ ] Protocols can be versioned, cloned, and A/B tested against each other

## Notes

Agent collaboration is what turns individual agents into a virtual team. The protocol model should be declarative — users define the workflow graph, not imperative code. This aligns with the scale-free philosophy: a two-step handoff and a ten-step pipeline use the same protocol primitives. Dead-letter handling matters: if an agent crashes mid-protocol, the platform must not silently drop the task. Consider integration with the eval domain so protocol performance can be measured end-to-end, not just per-agent.
