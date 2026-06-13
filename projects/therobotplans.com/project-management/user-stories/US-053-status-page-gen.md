---
id: US-053
title: "Generate status pages from monitoring data"
personas: [maya-chen]
domain: monitoring
priority: low
mvp_phase: "v1.0"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want to generate public or team-internal status pages from monitoring data so that I can communicate service health to users without maintaining a separate status page tool.

## Acceptance Criteria

- [ ] Status pages are auto-generated from monitoring data with per-service status (operational, degraded, outage) and uptime percentages
- [ ] Public pages are hosted at a configurable URL (e.g., status.myapp.com) with no authentication required; internal pages require login
- [ ] Active incidents appear on the status page with a human-readable summary — the agent drafts the summary from incident details, editable before publish
- [ ] Historical incidents are listed with a 90-day lookback showing resolution times and post-mortem links
- [ ] Status page appearance is customizable (logo, colors, grouped services) and updates within 60 seconds of a monitoring state change

## Notes

For a solo dev, this eliminates the "do I need Statuspage.io?" question. The agent-drafted incident summaries are key — Maya shouldn't have to context-switch from fixing an issue to writing a user-facing update. Consider a subscriber notification feature where users can opt in to email/webhook updates for specific services.
