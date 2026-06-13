---
id: US-014
title: "View Agent Reasoning Log"
slug: "view-agent-reasoning-log"
personas: [P-001, P-006]
epic: "Agent Management"
priority: "must-have"
complexity: "M"
tags: [agents, explainability, audit, reasoning, transparency]
---

# US-014: View Agent Reasoning Log

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** inspect a detailed reasoning log for every decision an agent makes,
**So that** I can understand why the agent flagged an anomaly or executed an action, and build trust in its judgment.

## Acceptance Criteria

- [ ] Given I open an agent's detail page, when I click the "Reasoning Log" tab, then I see a chronological list of agent decisions with timestamps, affected devices, triggering telemetry values, and a plain-language explanation.
- [ ] Given I click on a single log entry, when the detail panel opens, then I see: the raw telemetry input, the rules or model outputs that triggered the decision, the action taken or recommended, and the confidence score if applicable.
- [ ] Given an agent took an autonomous action (Level 3 or 4), when I view that log entry, then the action result (success, failure, partial) and any device response data are included.
- [ ] Given I want to investigate a specific device, when I filter the reasoning log by device name, then only entries involving that device are shown.
- [ ] Given the reasoning log grows large, when I scroll the list, then entries load incrementally (virtual scroll or pagination) without degrading page performance for logs exceeding 10,000 entries.

## Notes

The reasoning log is central to the explainability value proposition and is critical for P-006 (Data Scientist) tuning anomaly detection. Log entries should be exportable to JSON/CSV for offline analysis.
