---
id: US-083
title: "Fleet Optimization Recommendations"
slug: "fleet-optimization-recommendations"
personas: [P-001, P-002]
epic: "Insights & Reporting"
priority: "could-have"
complexity: "L"
tags: [recommendations, optimization, fleet, ai-insights]
---

# US-083: Fleet Optimization Recommendations

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** receive AI-generated recommendations for improving fleet performance and agent configuration based on observed patterns,
**So that** I can proactively address inefficiencies without manually analyzing all telemetry data.

## Acceptance Criteria

- [ ] Given sufficient historical data exists (minimum 14 days), when I open the Recommendations panel, then I see a prioritized list of actionable suggestions (e.g., "Enable threshold agent on Fleet B — 12 similar anomalies in 7 days went undetected")
- [ ] Given a recommendation is displayed, when I click Apply, then the system opens the relevant configuration dialog pre-populated with the recommended values for review before saving
- [ ] Given a recommendation is not applicable, when I click Dismiss and provide a reason, then the recommendation is hidden and the system uses that feedback to improve future suggestions
- [ ] Given recommendations are generated, when each recommendation is shown, then it includes an estimated impact score and the data evidence supporting it

## Notes

Recommendations are advisory only and require explicit user confirmation before any changes are applied. Relates to US-079 (agent performance comparison) and US-080 (trend analysis). This feature requires the ML inference pipeline to be active.
