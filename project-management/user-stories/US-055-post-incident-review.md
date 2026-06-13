---
id: US-055
title: "Generate pre-filled post-incident review template"
personas: [sarah-kim]
domain: monitoring
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want post-incident review templates pre-filled with timeline, actions taken, and affected items so that my team can run effective retros without spending hours reconstructing what happened.

## Acceptance Criteria

- [ ] On incident closure, a "Generate Review" action creates a structured document pre-filled with: incident timeline (from US-051), actions taken (from activity log), affected items, duration, severity, and impacted services
- [ ] The template includes editable sections for: root cause analysis, contributing factors, what went well, what needs improvement, and action items
- [ ] Action items created during the review are automatically linked back to the incident and added to the team's backlog as trackable items
- [ ] The agent drafts a "5 Whys" analysis based on the timeline and correlated events, presented as a starting point for team discussion
- [ ] Completed reviews are stored in the wiki/docs system (US-056) and linked to the incident item, searchable for future reference

## Notes

Post-incident reviews are one of those things every team knows they should do but often skip because of the effort involved. By pre-filling 80% of the content, the platform makes it frictionless. The agent-drafted "5 Whys" should be clearly labeled as a suggestion, not a conclusion — the team owns the analysis. Consider a "blameless" mode that automatically removes personal attributions from the generated content.
