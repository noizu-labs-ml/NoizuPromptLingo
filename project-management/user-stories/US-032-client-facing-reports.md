---
id: US-032
title: "Auto-generate client-facing project status reports"
personas: [james-oduya]
domain: projects
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **James Oduya (Agency Owner)**, I want to auto-generate polished client-facing project status reports from live project data so that I spend minutes reviewing reports instead of hours assembling them.

## Acceptance Criteria

- [ ] Report agent generates a structured status report including: executive summary, progress against milestones, completed items this period, upcoming deliverables, risks and blockers, and key metrics (velocity, burndown, or timeline adherence depending on methodology)
- [ ] Reports are generated from a configurable template that can be customized per client (logo, sections, tone, level of detail)
- [ ] Generated report is presented in draft mode for James to review, edit, and approve before sharing — agent suggestions are clearly marked as editable
- [ ] Approved reports can be exported as PDF, emailed directly to client contacts, or published to a client-facing read-only portal
- [ ] Report history is maintained per project with period-over-period comparison highlighting what changed since the last report

## Notes

Report quality is a direct reflection on the agency. The agent should write in professional, client-appropriate language — no internal jargon, no raw ticket IDs. Metrics should be presented with context ("velocity increased 15% this sprint" not just "velocity: 23"). Consider a "report preview" that shows how it will look to the client before sending. Integration with the Gantt view (US-029) for visual timeline inclusion would be valuable.
