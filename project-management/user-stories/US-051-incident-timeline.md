---
id: US-051
title: "View reconstructed incident timeline with correlated events"
personas: [lin-zhao]
domain: monitoring
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want to view a reconstructed incident timeline with correlated events across services so that I can understand the full blast radius and causal chain during and after an incident.

## Acceptance Criteria

- [ ] Incident detail view includes a chronological timeline aggregating: alerts fired, deploys executed, status changes, manual actions taken, and agent interventions
- [ ] Events from multiple services are correlated on a single timeline with service-colored lanes for visual separation
- [ ] Each event on the timeline is clickable, expanding to show details (log excerpt, deploy diff, alert threshold crossed)
- [ ] The agent can auto-annotate the timeline with likely causation arrows (e.g., "deploy at 14:02 likely caused alert at 14:05") based on temporal proximity and service dependencies
- [ ] Timeline is exportable as Markdown for inclusion in post-incident reviews (US-055)

## Notes

The timeline reconstruction is the AI-native differentiator — instead of manually piecing together what happened from five different tools, the platform assembles it automatically. Service dependency mapping (if available) should influence correlation confidence. For Lin Zhao's governance needs, every event on the timeline must link back to its source data for auditability.
