---
id: US-079
title: "View and manage agent task assignment queue"
personas: [sarah-kim]
domain: agents
priority: medium
mvp_phase: "v0.2"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want to view and manage the agent task assignment queue with priority ordering so that I can ensure agents are working on the most important tasks and rebalance when priorities shift.

## Acceptance Criteria

- [ ] Task queue displays all pending, in-progress, and recently completed agent tasks with priority ordering
- [ ] Manual reordering: drag-and-drop or explicit priority assignment to override default ordering
- [ ] Queue shows estimated time-to-completion for each task based on historical agent performance
- [ ] Bulk actions: pause, cancel, or reprioritize multiple queued tasks at once
- [ ] Queue respects agent role boundaries: tasks are only assignable to agents with appropriate permissions

## Notes

Sarah manages a team where agents handle code review, triage, and reporting. She needs the same queue visibility she would expect from a human team's sprint board. The queue should surface contention (two agents blocked on the same resource) and starvation (low-priority tasks that never execute). Consider integrating queue status into the agent team dashboard (US-076).
