---
id: US-002
title: "Agent activity feed in today view"
personas: [maya-chen]
domain: today-view
priority: high
mvp_phase: "v0.2"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want to see a real-time agent activity feed in my today view showing what agents are currently doing so that I can trust my virtual team members are working and intervene when something looks wrong.

## Acceptance Criteria

- [ ] A collapsible agent activity panel displays currently running agents with status (active, idle, waiting, error)
- [ ] Each agent entry shows: agent name, current task summary, elapsed time, and a confidence/progress indicator
- [ ] Activity feed updates in real-time (WebSocket or SSE) without requiring page refresh
- [ ] Clicking an agent entry expands to show recent action log (last 10 actions) with timestamps
- [ ] Error states surface as alerts that promote to the top of the today view with a one-click "investigate" action

## Notes

Agents are first-class team members in tobornalp — they are not hidden background processes. The feed should feel like a Slack sidebar showing who on your team is online and what they are working on. Consider a compact mode (icon + one-liner) vs. expanded mode (full action log) toggle.
