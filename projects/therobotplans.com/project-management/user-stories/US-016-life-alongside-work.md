---
id: US-016
title: "Personal lists alongside work without mixing contexts"
personas: [raj-patel, alex-russo]
domain: personal
priority: high
mvp_phase: "v0.1"
---

## User Story

As a **Raj Patel (Side-Project Builder)**, I want to maintain grocery lists, errand lists, and personal lists alongside work items without mixing contexts so that I can use one system for everything without my client seeing my grocery list in a shared project view.

## Acceptance Criteria

- [ ] Items can be assigned to a "personal" context that is invisible in any team or project view by default
- [ ] The today view merges personal and work items but marks them with distinct visual context indicators
- [ ] Personal items never appear in team dashboards, project boards, or shared reports regardless of filter settings
- [ ] Context switching between "personal only," "work only," and "all" is a single-click toggle in the today view and sidebar
- [ ] Personal lists (grocery, errands, etc.) support a simple checklist mode without requiring full item metadata

## Notes

This is a core differentiator versus tools like Jira or Linear that are work-only, and versus tools like Todoist that feel awkward for team work. The privacy boundary between personal and work contexts is not just a filter — it is a hard visibility wall enforced at the data access layer. The simple checklist mode acknowledges that "buy milk" does not need priority, tags, or an AI agent.
