---
id: US-015
title: "First-run onboarding wizard showing capabilities"
slug: "first-run-onboarding-wizard"
personas: [P-001, P-002, P-004]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "M"
tags: [onboarding, wizard, ux, first-run, education]
---

# US-015: First-run onboarding wizard showing capabilities

## User Story

**As a** startup founder (P-004),
**I want to** be guided through a step-by-step onboarding wizard after account activation,
**So that** I understand the service's capabilities and complete the minimum setup (API key + assistant connection) before reaching the dashboard.

## Acceptance Criteria

- [ ] Given a newly activated account, when the user first logs in, then the onboarding wizard launches automatically covering: capabilities overview, API key generation, and assistant connection
- [ ] Given the wizard is on step 2 (API key), when the user generates a key within the wizard, then the wizard advances to step 3 pre-populated with that key's connection snippet
- [ ] Given the user closes the wizard mid-flow, when they log in again, then the wizard resumes from the last completed step (not from the beginning)
- [ ] Given all wizard steps are completed, when the user clicks "Go to Dashboard", then the wizard is marked done and does not auto-launch on future logins

## Notes

Wizard steps: (1) Welcome + capability demo, (2) Generate API key, (3) Connect assistant (Claude Code / Cursor / Windsurf selector), (4) Run first mockup from within the wizard. Wizard must be accessible from the Help menu after first-run. Related to US-014, US-016, US-017.
