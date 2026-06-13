---
id: US-098
title: "View eval dashboard with quality trend charts"
personas: [sarah-kim]
domain: agent-eval
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want to view an eval dashboard with trend charts showing agent quality scores over time by role and task type so that I can monitor team agent performance at a glance and catch regressions early.

## Acceptance Criteria

- [ ] A dashboard displays time-series charts of aggregate eval scores (human ratings + automated rubric scores) with daily, weekly, and monthly granularity
- [ ] Charts can be filtered and grouped by: agent role, individual agent instance, task type, project, and prompt version
- [ ] Regression detection highlights periods where scores dropped significantly, with links to the prompt versions and config changes active during that period
- [ ] A summary card per agent shows: current score trend (improving/stable/declining), total tasks evaluated, human rating count, and top failure modes
- [ ] The dashboard loads within 3 seconds for teams with up to 10 agents and 10,000 evaluated tasks

## Notes

The eval dashboard is where the prompt-archival and agent-eval domains converge into actionable insight. The regression detection feature is the highest-value element — it answers "which change broke things?" by correlating score drops with prompt or config changes on the same timeline. For Sarah's team lead perspective, the per-agent summary cards serve as a health check during standup: a quick scan reveals which agents need attention. Consider a "team health" aggregate score that rolls up individual agent scores weighted by task volume. The dashboard should degrade gracefully when data is sparse — show confidence intervals rather than precise lines when sample sizes are small.
