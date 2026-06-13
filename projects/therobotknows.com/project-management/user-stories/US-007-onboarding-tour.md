---
id: US-007
title: "Interactive Onboarding Tour"
slug: "onboarding-tour"
personas: [P-005, P-008]
epic: "Onboarding & Authentication"
priority: "should-have"
complexity: "M"
tags: [onboarding, tour, ux, new-user]
---

# US-007: Interactive Onboarding Tour

## User Story

**As a** hobbyist worldbuilder (P-005),
**I want to** take an optional guided tour of the key features after creating my first universe,
**So that** I can discover the Canon Editor, Knowledge Graph, and Generation Studio without stumbling through them alone.

## Acceptance Criteria

- [ ] Given I have just created my first universe, when I land on the Universe Overview, then a dismissible tour banner offers to start a 5-step guided walkthrough.
- [ ] Given the tour is active, when I advance each step, then the UI highlights the relevant element (Canon Editor, Graph view, Generation Studio, Consistency Checker, Settings) with a tooltip and a brief description.
- [ ] Given the tour is active, when I click "Skip tour," then the tour ends immediately and a "Restart tour" option appears in the Help menu.
- [ ] Given I have completed or skipped the tour, when I return to the app in a new session, then the tour does not auto-launch again.

## Notes

Depends on US-005 (first-run experience) and US-011 (universe creation wizard). Tour state is persisted per user account, not per browser. Related: US-009 (create universe).
