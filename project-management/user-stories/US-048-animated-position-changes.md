---
id: US-048
title: "Animated Leaderboard Position Changes"
slug: "animated-position-changes"
personas: [P-001, P-002, P-004]
epic: "Leaderboards"
priority: "could-have"
complexity: "M"
tags: [leaderboard, animation, position, ui, engagement, gamification]
---

# US-048: Animated Leaderboard Position Changes

## User Story

**As a** blogger tracking my leaderboard rank (P-001),
**I want to** see animated indicators when my position and other positions have changed since my last visit,
**So that** I can feel the excitement of climbing (or be motivated by dropping) and understand at a glance where movement has happened.

## Acceptance Criteria

- [ ] Given I visit the leaderboard and my blog's rank has improved since my last session, when the leaderboard renders, then an upward arrow icon and the number of positions gained (e.g., "+3") are shown next to my rank
- [ ] Given my blog's rank has declined, when the leaderboard renders, then a downward arrow icon and positions lost are displayed (e.g., "-2") in a muted warning color
- [ ] Given my rank is unchanged, when the leaderboard renders, then a dash or no indicator is shown (no arrow)
- [ ] Given the leaderboard has recently been refreshed with new scores, when I view it within the first 5 minutes of a refresh cycle, then rows that changed position animate into their new positions (smooth slide transition, 300ms)
- [ ] Given a user prefers reduced motion (OS accessibility setting), when they view the leaderboard, then position change indicators are shown statically without animation
- [ ] Given I hover over a position change indicator, when the tooltip appears, then it shows the previous rank and the date/time of the last scoring update

## Notes

Animations should be subtle and purposeful — not distracting. This is a "could-have" because it adds engagement without being core to the leaderboard's utility. The prefers-reduced-motion media query must be respected. Previous rank should be stored per-user session in localStorage or server-side. Related to US-045 (global leaderboard), US-046 (period filter). New blogger P-004 will find this motivating early in their journey.
