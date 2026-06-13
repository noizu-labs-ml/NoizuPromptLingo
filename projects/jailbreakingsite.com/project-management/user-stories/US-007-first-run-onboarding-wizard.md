---
id: US-007
title: "First-Run Onboarding Wizard"
slug: "first-run-onboarding-wizard"
personas: [P-001, P-002, P-003, P-005, P-006, P-007, P-008]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "M"
tags: [onboarding, personalization, role-selection, ux]
---

# US-007: First-Run Onboarding Wizard

## User Story

**As a** newly registered user (P-001 through P-008),
**I want to** complete a short onboarding wizard that identifies my role and interests,
**So that** the platform surfaces relevant techniques, labs, and alerts without requiring me to configure everything manually.

## Acceptance Criteria

- [ ] Given I complete registration, when I reach the onboarding wizard, then I am presented with 3 or fewer steps covering role, primary use case, and model families of interest
- [ ] Given I select my role (e.g., Red Teamer, AppSec, ML Engineer, Researcher, Student), when I advance, then my dashboard layout and default catalog filters are pre-configured to match that role
- [ ] Given I select model families of interest (GPT-4, Claude, Gemini, open-source, etc.), when onboarding completes, then my catalog homepage highlights techniques relevant to those families
- [ ] Given I click "Skip for now" on any step, when onboarding completes, then defaults are applied and I can update preferences later from my profile settings

## Notes

Wizard must be completable in under 90 seconds. Role selection directly influences what is shown on the post-login dashboard and in the catalog (US-011). Links to US-008 for profile completion as an optional follow-up.
