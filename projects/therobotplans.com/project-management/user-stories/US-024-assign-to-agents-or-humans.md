---
id: US-024
title: "Assign items to agents or humans from same interface"
personas: [sarah-kim]
domain: projects
priority: high
mvp_phase: "v0.2"
---

## User Story

As a **Sarah Kim (Eng Lead)**, I want to assign work items to either human team members or AI agents using the same assignment interface so that agents are first-class team members rather than a separate workflow.

## Acceptance Criteria

- [ ] The assignee picker displays both human team members and available AI agents in a unified dropdown, with agents visually distinguished by an icon/badge
- [ ] Assigning an item to an agent triggers the agent's task intake protocol (the agent acknowledges the assignment and begins work or queues it based on its current load)
- [ ] Agent assignments show real-time status indicators (idle, working, blocked, completed) on the item card and board view
- [ ] Reassignment between human and agent (in either direction) preserves all item history, comments, and context
- [ ] Agent capabilities are surfaced in the picker — hovering over an agent shows what it can do (e.g., "Code Review Agent: reviews PRs, checks style, suggests improvements")

## Notes

This is a core differentiator for tobornalp. The assignment UX must make human-agent parity feel natural, not forced. Agents should have profiles just like humans (avatar, name, skills, availability). Consider edge cases: what happens when an agent is assigned work it can't handle? It should decline with an explanation rather than silently fail. Team capacity planning should account for both human and agent throughput.
