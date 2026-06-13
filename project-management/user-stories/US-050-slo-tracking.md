---
id: US-050
title: "Track SLO compliance with burn rate alerts"
personas: [lin-zhao]
domain: monitoring
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want to track SLO compliance with burn rate visualization and budget alerts so that I can manage reliability as a measurable objective rather than reacting to individual outages.

## Acceptance Criteria

- [ ] SLOs are defined per service with target (e.g., 99.9% availability, p99 latency < 200ms), measurement window (rolling 30d), and error budget
- [ ] A dashboard shows current SLO status, remaining error budget as a percentage, and burn rate trend line
- [ ] Alerts fire when burn rate exceeds configurable thresholds (e.g., 2x normal burn triggers warning, 10x triggers critical) and auto-create items via US-049
- [ ] Historical SLO compliance is tracked and exportable for reporting — useful for stakeholder updates and agent ROI metrics
- [ ] Agent can query SLO status ("are we within budget for auth-service this month?") and factor SLO health into deploy approval decisions (US-047)

## Notes

SLO tracking bridges monitoring and project management — when error budget is low, the platform should surface this in sprint planning and the agent should recommend prioritizing reliability work. This is a key metric for Lin Zhao's governance requirements. Consider supporting composite SLOs (e.g., "user-facing journey" spanning multiple services).
