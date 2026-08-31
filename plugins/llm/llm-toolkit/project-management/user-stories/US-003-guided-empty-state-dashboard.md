---
id: US-003
title: "Guided empty-state dashboard"
slug: guided-empty-state-dashboard
personas: [P-007]
epic: "Onboarding & Install"
priority: should-have
complexity: low
tags: [onboarding, dashboard, empty-state]
---

# US-003: Guided Empty-State Dashboard

## User Story

**As a** novice occasional user
**I want to** see a friendly explanation on the Dashboard before any conversations are indexed
**So that** I understand what the tool does and what to expect, instead of staring at a blank screen and wondering if something is broken

## Acceptance Criteria

- **Given** no conversations have been indexed yet
  **When** the user opens the Dashboard
  **Then** it shows explanatory copy describing what Claude Assist does (browse, search, resume past conversations) and what will populate the stat row and Browse view once indexing completes

- **Given** the empty-state Dashboard is showing
  **When** indexing is not yet running
  **Then** a clear call-to-action button starts or resumes the first-run indexing wizard rather than requiring the user to find a separate settings screen

- **Given** indexing begins while the empty-state Dashboard is visible
  **When** the first conversations are indexed
  **Then** the empty-state view transitions to the normal populated Dashboard without requiring a manual page refresh

## Notes
Directly serves Jamie's (P-007) core frustration: a blank UI reads as broken, not empty. This is should-have because the app is still functional without it — first-run wizard (US-002) covers the critical path — but it materially reduces novice confusion in the gap between install and first index completion.
