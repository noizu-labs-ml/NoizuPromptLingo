---
id: US-095
title: "skill-manage context budget report"
slug: skill-manage-context-budget-report
personas: [P-008]
epic: "skill-manage (audit)"
priority: must-have
complexity: medium
tags: [skill-manage, context-budget]
---

# US-095: skill-manage Context Budget Report

## User Story

**As a** multi-provider agent tinkerer
**I want to** run `skill-manage context --provider all --json` and see how much of each provider's context budget is consumed by enabled skills/agents
**So that** I can check budget headroom before enabling another skill and avoid bloating any one provider's metadata

## Acceptance Criteria

- **Given** Yusuf has several skills/agents enabled across providers
  **When** he runs `skill-manage context --provider all --json`
  **Then** the output is valid JSON reporting per-provider context/metadata budget consumed by currently enabled skills/agents

- **Given** a single provider is specified
  **When** he runs `skill-manage context --provider claude --json`
  **Then** only Claude's budget usage is reported

- **Given** an enabled skill's metadata exceeds a configurable budget threshold
  **When** the report runs
  **Then** that skill is flagged in the output (e.g. `"over_budget": true`)

## Notes
Matches Yusuf's stated habit of checking context-budget reports before enabling skills, to avoid bloating any one provider's metadata budget.
