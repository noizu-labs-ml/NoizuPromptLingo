---
id: US-071
title: "Planner agent drafts OKR check-in summaries with risk flags"
personas: [alex-russo]
domain: goals
priority: medium
mvp_phase: "v0.3"
---

## User Story

As an **Alex Russo (Productivity Enthusiast)**, I want the planner agent to draft OKR check-in summaries with progress data and risk flags so that my weekly reviews are pre-populated with actionable insights instead of blank forms.

## Acceptance Criteria

- [ ] Agent generates a structured check-in draft for each active OKR on a configurable schedule (default: weekly)
- [ ] Draft includes: current progress vs. target, velocity trend, blockers, and a confidence rating (on-track / at-risk / off-track)
- [ ] Risk flags are explained with specific evidence (e.g., "3 linked items blocked for >5 days")
- [ ] User can accept, edit, or discard the draft before it becomes the official check-in record
- [ ] Check-in history is viewable as a timeline showing trajectory over the OKR cycle

## Notes

Alex uses weekly reviews as a core ritual. The agent should feel like a thoughtful team member preparing a briefing, not a report generator. Tone should be concise and direct. The check-in draft should reference specific items by name so Alex can click through to address risks. Pairs with US-074 (personal alongside team OKRs) for unified review.
