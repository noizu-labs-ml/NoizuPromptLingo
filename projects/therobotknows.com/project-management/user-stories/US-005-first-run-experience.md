---
id: US-005
title: "First-Run Experience and Empty State"
slug: "first-run-experience"
personas: [P-005, P-002]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "M"
tags: [onboarding, first-run, empty-state, ux]
---

# US-005: First-Run Experience and Empty State

## User Story

**As a** veteran game master (P-002),
**I want to** see a guided empty state when I first arrive at my Dashboard,
**So that** I know exactly what to do next without reading documentation.

## Acceptance Criteria

- [ ] Given I have completed profile setup and have zero universes, when I land on the Dashboard, then I see a prominent call-to-action to create my first universe alongside a 3-step summary of the core workflow (Create → Write → Explore).
- [ ] Given I am on the empty Dashboard, when I click "Create Your First Universe," then I am taken directly to the Universe Creation Wizard (US-011).
- [ ] Given I have at least one universe, when I return to the Dashboard, then the empty state is replaced by my universe list and the onboarding tour trigger.
- [ ] Given the empty state is displayed, when I dismiss the CTA panel, then a minimal version persists in the sidebar until my first universe is created.

## Notes

Depends on US-004 (profile setup) and US-011 (universe creation wizard). Related: US-007 (onboarding tour). The empty state must never appear again once one universe exists.
