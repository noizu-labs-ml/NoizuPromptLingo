---
id: US-011
title: "Personal todo with due date, tags, and recurrence"
personas: [raj-patel]
domain: personal
priority: high
mvp_phase: "v0.1"
---

## User Story

As a **Raj Patel (Side-Project Builder)**, I want to create personal todos with due dates, tags, and optional recurrence so that I can track both one-off tasks and repeating obligations in the same system I use for my side projects.

## Acceptance Criteria

- [ ] Creating a new item supports setting a due date (date picker or natural language like "next Tuesday"), one or more tags, and a recurrence rule
- [ ] Recurrence options include: daily, weekdays, weekly, biweekly, monthly, and custom cron-like expressions
- [ ] When a recurring item is completed, the next occurrence is automatically generated with the updated due date
- [ ] Overdue items display a visual indicator (color shift or badge) and optionally promote to the top of the today view
- [ ] Tags are user-defined, free-form, and searchable across all items (personal and project)

## Notes

This is the foundational CRUD story for the scale-free item model. A "personal todo" is structurally the same entity as a "project task" or an "epic" — it just lives in a personal context with personal visibility. The recurrence engine must handle timezone-aware date math correctly, especially for users who travel.
