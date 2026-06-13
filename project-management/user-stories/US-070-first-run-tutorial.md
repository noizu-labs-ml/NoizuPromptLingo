---
id: US-070
title: "First-Run Tutorial Showing How to Browse"
slug: "first-run-tutorial"
personas: [P-004, P-001, P-002]
epic: "Onboarding & Authentication"
priority: "should-have"
complexity: "M"
tags: [onboarding, tutorial, first-run, ux, new-users]
---

# US-070: First-Run Tutorial Showing How to Browse

## User Story

**As a** casual link-follower (P-004),
**I want to** be guided through the core features of gotta.cc when I first sign up,
**So that** I understand how to browse categories, read scores, and start a collection without having to figure it out on my own.

## Acceptance Criteria

- [ ] Given I have just created an account, when I am redirected post-signup, then a 3–5 step onboarding flow begins before I reach the main dashboard
- [ ] Given the tutorial is active, when I reach the "Scores" step, then a visual callout explains the five scoring dimensions with a real example listing visible behind the overlay
- [ ] Given the tutorial is active, when I reach the "Collections" step, then I am prompted to add my first site to a collection as a hands-on action (not just reading)
- [ ] Given I want to skip the tutorial, when I click "Skip" at any step, then I am taken directly to the homepage and the tutorial is marked complete
- [ ] Given I have completed or skipped the tutorial, when I revisit the onboarding help, then a "Take the tour again" option is available in account settings

## Notes

The tutorial should feel like guided discovery, not a mandatory blocker. The interactive "add your first site" step in the collections phase is the most important retention-driving moment — making users do something (not just read) significantly improves activation. Related: US-068 (email signup), US-071 (profile setup), US-060 (create collection).
