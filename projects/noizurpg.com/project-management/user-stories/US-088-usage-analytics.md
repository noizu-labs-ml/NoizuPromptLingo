---
id: US-088
title: "Usage Analytics Dashboard"
slug: "usage-analytics"
personas: [P-006]
epic: "Cloud & Commercial Services"
priority: "could-have"
complexity: "L"
tags: [analytics, dashboard, cloud, monitoring, studio]
---

# US-088: Usage Analytics Dashboard

## User Story

**As a** game studio lead (P-006),
**I want to** view a dashboard showing LLM call volume, token consumption, cost estimates, component usage breakdown, and error rates across my deployed games,
**So that** I can make informed decisions about model selection, optimization priorities, and infrastructure spend.

## Acceptance Criteria

- [ ] Given a studio account with at least one deployed game, when I navigate to the Analytics dashboard, then I see daily/weekly/monthly views of: total LLM calls, total tokens consumed, estimated cost (by provider), and p95 latency
- [ ] Given the analytics dashboard, when I select a specific component (e.g., NarrativeEngine, DialogueManager), then the metrics are filtered to show only calls originating from that component
- [ ] Given a time range with at least one provider error, when I view the Errors panel, then I see error rate by provider, error type distribution, and a sample of the prompts that triggered errors (truncated for privacy)
- [ ] Given the analytics dashboard, when I click "Export CSV", then a CSV file is downloaded containing the raw event data for the selected date range and filters
- [ ] Given a game that exceeds a configurable cost threshold in a 24-hour window, when the threshold is breached, then an alert email is sent to the studio admin email on file

## Notes

Requires an event collection pipeline in the framework's provider layer (telemetry hooks). This is tagged `could-have` because the core framework is valuable without it, but it becomes important for studios at scale. Complements the Managed Memory dashboard (US-084).
