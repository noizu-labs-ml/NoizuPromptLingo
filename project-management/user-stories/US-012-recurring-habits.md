---
id: US-012
title: "Recurring habits with configurable frequency"
personas: [alex-russo]
domain: personal
priority: medium
mvp_phase: "v0.1"
---

## User Story

As an **Alex Russo (Productivity Enthusiast)**, I want to create recurring habits with configurable frequency so that I can build consistent routines tracked alongside my other work.

## Acceptance Criteria

- [ ] A habit item type supports frequency options: daily, specific weekdays (e.g., Mon/Wed/Fri), weekly, and custom schedules
- [ ] Habits appear on the today view only on their scheduled days, with a simple check-off interaction
- [ ] Completing a habit for the day marks it done without creating a new item — the habit entity itself tracks completion history
- [ ] Habits are visually distinct from regular todos (icon or color) to support quick scanning
- [ ] A habit overview screen shows all active habits with their current week's completion status at a glance

## Notes

Habits differ from recurring todos in an important way: a recurring todo generates discrete instances, while a habit is a single persistent entity with a completion log. This distinction matters for the scale-free model — habits are items with a "habit" behavior attached, not a separate entity type. The completion log feeds into streak tracking (US-014) and weekly review (US-019).
