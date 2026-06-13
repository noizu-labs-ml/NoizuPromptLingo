---
id: US-052
title: "Integrate on-call schedule for incident routing"
personas: [sarah-kim]
domain: monitoring
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want on-call schedules integrated so that incidents automatically route to the current on-call person so that my team gets timely notifications without manual triage.

## Acceptance Criteria

- [ ] On-call schedules are importable from PagerDuty, OpsGenie, or defined natively within Plans with rotation rules (daily, weekly, custom)
- [ ] When an incident is created (US-049), it is auto-assigned to the current on-call person with an escalation path if unacknowledged within a configurable timeout
- [ ] The on-call roster is visible in the team dashboard showing who is currently on-call, next rotation, and swap history
- [ ] On-call members can swap shifts within Plans, with the swap recorded and the schedule updated in real-time
- [ ] The PM agent factors on-call load into workload balancing — an engineer on-call this week may have reduced sprint capacity

## Notes

For small teams like Sarah's, on-call is often informal. The platform should support lightweight on-call (just a rotation list) without requiring a full PagerDuty integration. Escalation should work even if the primary on-call is an agent — e.g., the monitor agent handles L1 triage and escalates to a human for L2. On-call history contributes to team health metrics.
