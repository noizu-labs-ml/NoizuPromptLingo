---
id: US-023
title: "AI-assisted sprint planning"
personas: [sarah-kim]
domain: projects
priority: high
mvp_phase: "v0.2"
---

## User Story

As a **Sarah Kim (Eng Lead)**, I want AI to suggest which backlog items to pull into the next sprint based on team velocity, priorities, and dependencies so that sprint planning meetings are shorter and better informed.

## Acceptance Criteria

- [ ] AI agent analyzes historical velocity (completed story points per sprint) and suggests a set of items that fit within the team's average capacity
- [ ] Suggestions respect item priority ordering, dependency constraints (blocked items are excluded), and team member availability/workload
- [ ] The suggestion is presented as a draft sprint plan that Sarah can accept, modify (add/remove items), or regenerate with adjusted parameters (e.g., "assume 80% capacity this sprint")
- [ ] Agent provides a brief rationale for each suggested item explaining why it was included (priority, dependency chain, risk of delay)
- [ ] Sprint plan can be finalized with one action, which moves selected items into the sprint and notifies assigned team members

## Notes

This is not autopilot — the agent is a planning advisor. Sarah should always feel in control. The AI should flag risks like "this sprint has 3 items from the same assignee" or "item X has an unresolved dependency on project Y." First sprint with no velocity data should fall back to priority-only ordering with a configurable default capacity estimate.
