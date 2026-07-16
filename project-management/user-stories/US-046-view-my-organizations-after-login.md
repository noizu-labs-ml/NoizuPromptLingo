---
id: US-046
title: "View My Organizations After Login"
slug: "view-my-organizations-after-login"
personas: [P-008]
epic: "Onboarding & Auth"
priority: "should-have"
complexity: "S"
tags: [organizations, onboarding, newcomer]
---

# US-046: View My Organizations After Login

## User Story

**As an** Evaluating Newcomer (P-008) who may belong to more than one organization,
**I want to** see a clear "my organizations" list right after logging in,
**So that** I can confirm which organization I just joined and pick the right one if I belong to several.

## Acceptance Criteria

- [ ] Given I have successfully logged in and belong to at least one organization, when the post-login screen loads, then I see a list of my organizations showing each one's name and my role within it.
- [ ] Given I belong to exactly one organization, when I log in, then I am taken directly into that organization's context without an unnecessary extra selection step.
- [ ] Given I belong to multiple organizations, when I view "my organizations", then I can select one to enter, and that selection is remembered for my next login.

## Notes

Natural landing point after accepting an invite (US-039) or registering a new org (US-037).
