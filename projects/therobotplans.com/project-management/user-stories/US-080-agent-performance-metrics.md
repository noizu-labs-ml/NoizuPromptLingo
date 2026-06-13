---
id: US-080
title: "Track agent performance metrics and ROI"
personas: [lin-zhao]
domain: agents
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want to track agent performance metrics including tasks completed, accuracy, time-to-completion, and cost so that I can measure agent ROI and make data-driven decisions about agent configuration and investment.

## Acceptance Criteria

- [ ] Metrics tracked per agent: tasks completed, error rate, average time-to-completion, token/API cost, and human override rate
- [ ] Dashboard shows metrics over configurable time ranges with trend indicators (improving/declining/stable)
- [ ] Cost attribution: each agent action's compute cost is tracked and aggregable by agent, project, and time period
- [ ] ROI calculation: estimated time saved (based on historical human baselines) vs. agent cost
- [ ] Alerts configurable for metric thresholds (e.g., error rate > 10%, cost exceeds budget)

## Notes

Lin is the persona who will decide whether to expand or constrain agent usage based on hard data. The ROI metric is the headline number for executive buy-in. Human override rate is a proxy for agent accuracy/trust: high override rate means the agent is not calibrated. Consider benchmarking against "what if no agents" baseline calculated from pre-agent workflow data. This pairs with US-078 (audit log) as the data source.
