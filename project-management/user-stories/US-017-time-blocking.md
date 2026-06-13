---
id: US-017
title: "Time blocking for focused work"
personas: [alex-russo]
domain: personal
priority: medium
mvp_phase: "v0.3"
---

## User Story

As an **Alex Russo (Productivity Enthusiast)**, I want to block time on my calendar for focused work, personal tasks, or deep work sessions so that I can protect my schedule and see how my day maps to actual time rather than just a task list.

## Acceptance Criteria

- [ ] A calendar/timeline view allows dragging items from the today view into time slots to create time blocks
- [ ] Time blocks display on a daily timeline alongside any synced external calendar events (Google Calendar, Outlook)
- [ ] Creating a time block does not modify the underlying item — it creates a scheduling layer that links to the item
- [ ] A "suggest time blocks" action uses AI to propose a day schedule based on item priorities, estimated durations, and energy patterns
- [ ] Time block conflicts (overlapping blocks or blocks during meetings) are highlighted with a warning

## Notes

Time blocking bridges the gap between "what do I need to do" (task list) and "when will I do it" (calendar). The AI suggestion feature should consider user-declared preferences like "deep work in the morning" or "meetings after 2pm." External calendar sync is read-only in this phase — bidirectional sync is a future story. Consider integrating with US-003 (drag reorder) so reordering items also reflows time blocks.
