---
id: US-005
title: "Onboarding Wizard"
slug: "onboarding-wizard"
personas: [P-001, P-004]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "L"
tags: [onboarding, wizard, blog-submission, niches, competition]
---

# US-005: Onboarding Wizard

## User Story

**As a** new user (P-004),
**I want to** be guided through a step-by-step onboarding wizard after registration,
**So that** I can submit my blog, choose my niches, and understand how to compete before reaching my dashboard.

## Acceptance Criteria

- [ ] Given I have just verified my email (or completed OAuth), when I land on the onboarding wizard, then I see a 4-step progress indicator: (1) Add Blog, (2) Choose Niches, (3) Your First Competition, (4) Profile Setup
- [ ] Given I am on Step 1, when I enter a valid blog URL and click "Continue", then the system validates the URL is reachable and moves me to Step 2 (triggering background indexing per US-011)
- [ ] Given I am on Step 2, when I see a list of niches (lifestyle, tech, food, travel, finance, health, parenting, gaming, etc.), then I can select 1–5 niches and my selections are saved when I click "Continue"
- [ ] Given I am on Step 3, when the system displays a recommended competition based on my niches, then I can click "Join Competition" to enroll immediately or "Skip for now" to continue
- [ ] Given I have completed all 4 steps, when I click "Go to Dashboard", then I land on my dashboard with a dismissible "You're all set!" banner and no further wizard prompts
- [ ] Given I close the browser mid-wizard, when I return and log in, then I resume at the last incomplete step (progress is persisted)

## Notes

Wizard should be skippable in full from Step 1 via a "Skip setup" link, dropping the user directly on the dashboard. Niche taxonomy should be defined and managed by platform admins. Related: US-006 (profile setup), US-011 (blog submission), US-009 (terms acceptance).
