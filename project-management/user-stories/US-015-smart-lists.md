---
id: US-015
title: "Smart lists with auto-filtering rules"
personas: [maya-chen]
domain: personal
priority: medium
mvp_phase: "v0.2"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want to create smart lists that auto-filter items by rules so that I can build custom views like "blocked items this sprint," "all items tagged #design," or "overdue across all projects" without manual curation.

## Acceptance Criteria

- [ ] Users can define smart lists with filter rules combining: tags, status, due date ranges, project, assignee, item type, and custom fields
- [ ] Rules support AND/OR logic with nesting (e.g., "tag is #urgent AND (project is App OR project is API)")
- [ ] Smart lists update in real-time as items change — no manual refresh required
- [ ] Smart lists are saveable, nameable, and appear in the sidebar navigation alongside static lists
- [ ] A "create smart list from current filter" shortcut saves the active filter state as a new smart list

## Notes

Smart lists are the query layer over the scale-free item model. Because all items are structurally uniform, any attribute combination can define a list. This is where the scale-free architecture pays off most visibly. Consider providing starter smart list templates (e.g., "Overdue," "Untagged," "Completed This Week") to help new users understand the feature.
