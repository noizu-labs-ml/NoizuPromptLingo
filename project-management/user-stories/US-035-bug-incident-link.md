---
id: US-035
title: "Link bugs to monitoring incidents"
personas: [maya-chen]
domain: bugs
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Maya Chen (Solo Dev)**, I want to link a bug to a monitoring incident so that I can establish cause-effect relationships between observed issues and their root causes.

## Acceptance Criteria

- [ ] Bug detail view includes an "Incidents" section where monitoring incidents can be linked via search (by incident ID, time range, or service name) or auto-suggested by the enrichment agent
- [ ] Linked incidents display inline: incident title, severity, timeline, affected services, and current status — pulled in real-time from the monitoring source via MCP
- [ ] When an incident resolves, linked bugs are flagged for verification ("incident resolved — confirm bug is fixed")
- [ ] When a bug is resolved, linked incidents gain a reference to the fix for future postmortems
- [ ] Incident-to-bug links are bidirectional and visible from both the bug view and any incident timeline integration

## Notes

Maya monitors her solo projects with lightweight observability tools. The link between "the alert that fired" and "the bug I filed" is often lost in context-switching. This feature closes that loop. MCP integrations with SigNoz, Datadog, PagerDuty, or similar are the implementation path. The monitor agent (from Maya's persona needs) should be able to auto-create bugs from incidents with the link pre-established.
