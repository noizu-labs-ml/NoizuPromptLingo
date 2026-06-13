---
id: US-002
title: "Guided Onboarding Wizard"
slug: "onboarding-wizard"
personas: [P-001, P-003]
epic: "Onboarding & Fleet Connection"
priority: "must-have"
complexity: "M"
tags: [onboarding, wizard, ux]
---

# US-002: Guided Onboarding Wizard

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** be guided through a step-by-step onboarding wizard after account creation,
**So that** I can configure my organization, connect my first data source, and understand the platform quickly.

## Acceptance Criteria

- [ ] Given I complete email verification, when I am redirected to the app, then a multi-step wizard begins with steps: Org Setup → Connect Source → Discover Devices → Create First Agent.
- [ ] Given I am on any wizard step, when I click "Save & Exit," then my progress is persisted and I can resume from the same step on next login.
- [ ] Given I complete all wizard steps, when I click "Finish," then I am taken to the main dashboard with a dismissible success banner summarizing what was configured.
- [ ] Given I have already completed the wizard, when I navigate to the onboarding URL, then I am redirected to the dashboard without re-triggering the wizard.

## Notes

Each wizard step corresponds to a deeper user story (US-003 for org setup, US-004 for source connection). Wizard may be skipped by advanced users (P-004) via an "Advanced Setup" link.
