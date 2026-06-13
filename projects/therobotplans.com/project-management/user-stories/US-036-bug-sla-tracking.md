---
id: US-036
title: "Bug SLA compliance tracking"
personas: [james-oduya]
domain: bugs
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **James Oduya (Agency Owner)**, I want to track SLA compliance for bug resolution with aging indicators and alerts so that I can meet contractual obligations and demonstrate reliability to clients.

## Acceptance Criteria

- [ ] SLA policies are configurable per project or per client, defining target resolution times by severity level (e.g., critical: 4 hours, high: 24 hours, medium: 3 business days, low: 2 weeks)
- [ ] Each bug displays an SLA countdown timer showing time remaining, with visual escalation as the deadline approaches (green -> yellow at 50% -> red at 80% -> breached)
- [ ] SLA breach alerts notify the project lead and optionally the client contact, with configurable escalation chains (e.g., after 1 hour of breach, escalate to James directly)
- [ ] An SLA compliance dashboard shows per-project and per-client metrics: compliance rate, average resolution time by severity, breached bugs this period, and trend over time
- [ ] SLA clock pauses when a bug is in "waiting on client" or "blocked-external" status, with audit log of all clock pauses and resumes

## Notes

SLA tracking is table stakes for agency work. The implementation must handle business hours vs. calendar hours, timezone differences between agency and client, and holidays. Clock-pause logic is critical to avoid false breaches when waiting on external input. The SLA dashboard should be exportable for inclusion in client reports (US-032). Consider SLA prediction: "at current pace, this bug will breach SLA in 2 hours."
