---
id: US-012
title: "User completes first-run experience and sees dashboard"
slug: "user-completes-first-run-experience"
personas: [P-001, P-007]
epic: "Auth & Onboarding"
priority: "must-have"
complexity: "M"
tags: [onboarding, dashboard, first-run, ux]
---

# US-012: User Completes First-Run Experience and Sees Dashboard

## User Story

**As a** MCP Tool Developer (P-001) or Solo AI Hobbyist (P-007),
**I want to** complete a guided first-run experience that ends with a personalized dashboard,
**So that** I understand the platform's capabilities and can immediately take productive action from the dashboard.

## Acceptance Criteria

- [ ] Given a newly verified account, when the user logs in for the first time, then the system launches a first-run wizard with steps: (1) welcome and platform overview, (2) create or join an organization, (3) configure first MCP server or skip, (4) create an API key or skip, (5) dashboard orientation.
- [ ] Given the first-run wizard, when the user completes or skips each step, then the system saves the user's progress so they can resume if they abandon mid-wizard.
- [ ] Given the user completes the first-run wizard, when they are shown the dashboard, then the dashboard displays: active MCP servers (or a prompt to create one), API keys created, recent tool invocations (or empty state with guidance), and quick-action cards for common tasks.
- [ ] Given an existing user who has already completed the first-run wizard, when they log in, then the system skips the wizard and goes directly to the personalized dashboard.
- [ ] Given the dashboard, when the user clicks a quick-action card (e.g., "Deploy new MCP server," "Create API key," "Browse registry"), then the system navigates to the corresponding workflow with context pre-filled from the user's organization settings.

## Notes

The first-run experience is the critical path to user activation. The dashboard serves as the persistent home after onboarding. Quick-action cards should adapt based on what the user has and has not set up yet. Related to US-001 (sign-up), US-003 (first MCP server), US-004 (API key).
