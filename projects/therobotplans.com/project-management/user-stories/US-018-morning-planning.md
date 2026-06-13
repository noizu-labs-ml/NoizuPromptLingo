---
id: US-018
title: "AI-assisted morning planning routine"
personas: [alex-russo, maya-chen]
domain: personal
priority: high
mvp_phase: "v0.2"
---

## User Story

As an **Alex Russo (Productivity Enthusiast)**, I want an AI-assisted morning planning routine that suggests today's priorities from my backlog so that I start each day with a curated plan instead of staring at an overwhelming list.

## Acceptance Criteria

- [ ] A "Plan My Day" action triggers an AI agent that analyzes backlog items, due dates, streaks, calendar events, and yesterday's incomplete items
- [ ] The agent presents a suggested daily plan as an ordered list of 5-8 items with rationale for each inclusion
- [ ] The user can accept the plan as-is, remove items, add items, or reorder before confirming
- [ ] Confirmed items populate the today view in the accepted order with an "AI-planned" indicator
- [ ] The planning agent adapts its suggestions over time based on which items the user consistently deprioritizes or never completes

## Notes

This is the morning ritual that makes tobornalp feel like having a personal chief of staff. The agent should not just pick the highest-priority items — it should consider balance (mix of quick wins and deep work), energy management (hard items early), and deadline urgency. The "rationale" for each suggestion builds trust in the AI and helps users calibrate their own planning instincts.
