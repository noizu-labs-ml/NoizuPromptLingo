---
id: US-045
title: "View environment status dashboard"
personas: [lin-zhao]
domain: cicd
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want to view an environment status dashboard showing what's deployed where so that I have a single pane of glass for deployment state across all environments.

## Acceptance Criteria

- [ ] Dashboard displays all configured environments (dev, staging, production, etc.) with the currently deployed version/SHA for each service
- [ ] Version drift between environments is visually highlighted (e.g., staging is 3 commits ahead of production)
- [ ] Each environment entry shows last deploy time, deployer (human or agent), and deploy health status
- [ ] Filtering by project or service narrows the view; a global view shows the full portfolio
- [ ] Environment data is queryable by agents — e.g., "what version of auth-service is in production?" returns a structured answer

## Notes

This dashboard is the deployment counterpart to the uptime dashboard (US-048). Data is pulled from the same CI/CD provider adapters. For multi-project portfolios (James's agency use case), the dashboard should support project-scoped views. Consider a diff view that shows exactly which items/commits separate two environments.
