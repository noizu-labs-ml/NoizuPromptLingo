---
id: US-016
title: "Pause and Resume an Agent"
slug: "pause-resume-agent"
personas: [P-001, P-007]
epic: "Agent Management"
priority: "must-have"
complexity: "S"
tags: [agents, lifecycle, pause, resume, maintenance]
---

# US-016: Pause and Resume an Agent

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** pause an agent during planned maintenance windows and resume it when maintenance completes,
**So that** the agent does not generate false alerts or execute remediation actions against devices undergoing intentional downtime.

## Acceptance Criteria

- [ ] Given I am on an agent's detail page, when I click "Pause Agent," then a modal asks for an optional reason and an optional auto-resume time, and confirms the pause action.
- [ ] Given an agent is paused, when telemetry arrives from its monitored devices, then the agent ingests and buffers data but does not generate anomaly alerts or execute playbook actions.
- [ ] Given an agent is paused, when I view the agents list, then the agent is visually distinguished (e.g., yellow "Paused" badge) and the pause reason and duration are shown on hover.
- [ ] Given an auto-resume time was set, when that time is reached, then the agent automatically resumes and logs the auto-resume event with the original pause reason.
- [ ] Given I click "Resume Agent" on a paused agent, when I confirm, then the agent returns to its prior active state within 10 seconds and processes any anomalies detected in buffered data during the pause.

## Notes

Buffered anomaly processing on resume should be configurable — some operators may prefer to discard buffered data from maintenance windows. This story intentionally does not address agent deletion, which is a separate destructive action.
