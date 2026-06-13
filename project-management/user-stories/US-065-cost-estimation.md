---
id: US-065
title: "Estimate generation costs before running"
slug: cost-estimation
personas: [P-003, P-006]
epic: "Installation & Configuration"
priority: could-have
complexity: medium
tags: [cost, estimation, planning, budget]
---

# US-065: Estimate generation costs before running

## User Story

**As a** design team lead tracking budget
**I want to** see estimated API costs before generating
**So that** I can approve or adjust the generation plan

## Acceptance Criteria

- **Given** a `--estimate` flag
  **When** the plan is shown
  **Then** estimated costs per prompt and total are displayed based on provider pricing

## Notes
Planned feature. Requires maintaining a pricing table per provider/model. Rough estimates only.
