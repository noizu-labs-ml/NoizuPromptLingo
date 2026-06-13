---
id: US-076
title: "Agent team dashboard showing status, task, and health"
personas: [maya-chen]
domain: agents
priority: high
mvp_phase: "v0.2"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want to view all active agents as a team dashboard showing their status, current task, and health so that I can manage my virtual team members as easily as a real team.

## Acceptance Criteria

- [ ] Dashboard displays each agent as a card with: name/role, current status (idle/working/blocked/error), active task, and uptime
- [ ] Health indicators show agent responsiveness, error rate in last 24h, and queue depth
- [ ] Clicking an agent card opens a detail panel with recent activity log and configuration
- [ ] Dashboard supports keyboard navigation and fits Maya's keyboard-first, dark-mode workflow
- [ ] Real-time updates: status changes reflect within 5 seconds without manual refresh

## Notes

This is the "team standup" view for a solo dev whose team is entirely agents. Maya's monitor agent, planner agent, and any task-specific agents should all appear here. The metaphor is a team — not a services dashboard. Use human team language (available, busy, stuck) not infrastructure language (running, degraded, down). Consider a compact mode for embedding in the unified today view.
