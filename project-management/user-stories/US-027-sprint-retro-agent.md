---
id: US-027
title: "Agent-generated sprint retrospective analysis"
personas: [sarah-kim]
domain: projects
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Sarah Kim (Eng Lead)**, I want an AI agent to generate a sprint retrospective analysis covering velocity trends, blocker patterns, and team dynamics so that retro meetings start with data-driven insights instead of blank whiteboards.

## Acceptance Criteria

- [ ] At sprint close, the retro agent automatically generates a report covering: velocity trend (last 3-5 sprints), completed vs. committed ratio, items that spilled over, blocker frequency and duration, and cycle time distribution
- [ ] Agent identifies patterns across sprints: recurring blockers, estimation accuracy trends, and workload distribution imbalances across team members (human and agent)
- [ ] Report includes specific, actionable suggestions (e.g., "Consider breaking down items assigned to backend — average cycle time is 2x frontend items" or "3 of last 4 sprints had blocked items waiting on external API team")
- [ ] The retro report is editable — Sarah can annotate it, add team discussion notes, and mark action items that carry into the next sprint
- [ ] Historical retro reports are searchable and action items are tracked to completion across sprints

## Notes

The agent should surface insights the team might miss by looking at patterns over time. Tone should be constructive and neutral — never blame-oriented. The report is a conversation starter, not a verdict. Consider integrating sentiment from commit messages or comments as an optional signal. Action items from retros should be first-class items in the scale-free model.
