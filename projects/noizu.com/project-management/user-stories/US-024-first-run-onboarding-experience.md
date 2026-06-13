---
id: US-024
title: "First-Run Onboarding Experience"
slug: "first-run-onboarding-experience"
personas: [P-007]
epic: "Authentication & Onboarding"
priority: "should-have"
complexity: "L"
tags: [onboarding, first-run, profile-setup, dashboard, ux]
---

# US-024: First-Run Onboarding Experience

## User Story

**As a** newly verified client accessing the dashboard for the first time (P-007),
**I want to** complete a short onboarding flow that captures my company context and engagement preferences,
**So that** Keith can personalize communications and I understand what the client portal offers.

## Acceptance Criteria

- [ ] Given a user's email is verified and terms are accepted, when they access the dashboard for the first time, then an onboarding wizard is shown rather than the empty dashboard.
- [ ] Given the onboarding wizard, when rendered, then steps include: Profile Setup (Company name, role, phone optional), Engagement Context (primary service type, current challenge in 2–3 sentences), and Notification Preferences.
- [ ] Given a user completes all onboarding steps, when they finish, then they land on the dashboard with a welcome message and a brief tour of key sections.
- [ ] Given a user partially completes onboarding and navigates away, when they next log in, then they are prompted to resume from where they left off (not restarted).
- [ ] Given a user dismisses onboarding, when they dismiss, then they can access the dashboard immediately and resume onboarding from a "Complete your profile" banner.
- [ ] Given the onboarding is complete, when Keith views the admin side, then the new client's profile data collected during onboarding is visible.

## Notes

Step count should be ≤ 3 to minimize abandonment. Progress indicator (1 of 3) required. All steps except Profile Setup are optional/skippable. Related: US-018 (registration), US-019 (email verification), US-023 (terms), future client dashboard stories.
