---
id: US-049
title: "Auto-create incidents from monitoring alerts"
personas: [maya-chen]
domain: monitoring
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want incidents to be automatically created from monitoring alerts with context enrichment so that I can jump straight into resolution instead of manually creating tickets from alert emails.

## Acceptance Criteria

- [ ] When a monitoring alert fires, an incident item is auto-created with severity, affected service, alert trigger details, and a link to the monitoring dashboard
- [ ] The agent enriches the incident with context: recent deploys to the affected service, related open items, and historical incidents for the same service
- [ ] Duplicate alerts within a configurable window (default 5 minutes) are grouped into the same incident rather than creating separate items
- [ ] Incident items appear in the "Today" view with priority override — critical incidents surface above all other work
- [ ] When the alert resolves, the incident item is auto-annotated with resolution time and the incident can be closed or kept open for follow-up

## Notes

This is the bridge between monitoring (US-048) and the work management system. In the scale-free model, an incident is just an item with an "incident" type that can be promoted to a post-mortem, linked to deploy items, or decomposed into fix tasks. Alert deduplication should be smart — same service + same check + within window = same incident, but different failure modes on the same service should create separate incidents.
