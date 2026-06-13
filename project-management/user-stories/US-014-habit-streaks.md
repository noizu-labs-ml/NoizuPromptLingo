---
id: US-014
title: "Habit streak tracking with visual indicators"
personas: [alex-russo]
domain: personal
priority: medium
mvp_phase: "v0.2"
---

## User Story

As an **Alex Russo (Productivity Enthusiast)**, I want to track habit streaks with visual indicators and streak-break notifications so that I stay motivated to maintain consistency and catch slip-ups early.

## Acceptance Criteria

- [ ] Each habit displays its current streak count (consecutive completions) and longest-ever streak
- [ ] A GitHub-contribution-style heatmap visualization shows completion density over time for each habit
- [ ] Streak-break notifications are sent (in-app and optionally push/email) when a habit is missed on its scheduled day
- [ ] A "grace period" setting allows configuring how many missed days before a streak is considered broken (default: 0)
- [ ] The today view shows a streak summary badge next to habit items (e.g., flame icon with count)

## Notes

Streak psychology is powerful but fragile — a single break can demotivate. The grace period feature and the "longest streak" persistence help mitigate the "all or nothing" trap. The heatmap visualization should be compact enough to inline on the habit overview screen. Consider a "freeze" feature for vacations or sick days that preserves the streak without requiring completion.
