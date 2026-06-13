---
id: US-025
title: "Multi-project portfolio dashboard"
personas: [james-oduya]
domain: projects
priority: high
mvp_phase: "v0.2"
---

## User Story

As a **James Oduya (Agency Owner)**, I want to view all my active projects in a portfolio dashboard with health indicators so that I can spot at-risk projects before they become emergencies.

## Acceptance Criteria

- [ ] Dashboard displays all active projects as cards or rows showing: project name, client, methodology, current sprint/phase, overall health indicator (green/yellow/red), and key metrics (velocity trend, open bugs, items completed this period)
- [ ] Health indicator is computed from configurable signals: sprint burndown trajectory, overdue items, blocked items count, SLA compliance, and agent-generated risk flags
- [ ] Clicking a project drills into that project's detail view while maintaining the portfolio context (breadcrumb navigation back to portfolio)
- [ ] Portfolio supports filtering by client, methodology, health status, and team member; sort by health (worst-first), deadline, or alphabetical
- [ ] A portfolio-level summary bar shows aggregate stats: total active projects, projects at risk, team utilization across all projects

## Notes

James manages 5-10 client projects simultaneously. The dashboard must load fast and communicate status at a glance — he checks it multiple times daily. Health computation should be transparent: clicking the health indicator shows the contributing factors and their weights. Consider a "portfolio standup" agent feature that generates a morning briefing across all projects.
