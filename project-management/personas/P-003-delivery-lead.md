---
id: P-003
name: "Priya Anand"
slug: "delivery-lead"
archetype: "The Delivery Lead"
segment: "primary"
tags: [engineering-manager, tickets, boards, sprints]
---

# Priya Anand — The Delivery Lead

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 37 |
| **Role** | Engineering Manager, 8-person team (5 humans, 3 agent-heavy contributors) |
| **Technical Level** | Advanced |
| **Industry** | Fintech |
| **Location** | Austin, TX |

## Bio

Priya runs planning for a team that treats coding agents as first-class contributors alongside humans. She lives in the ticket board and cares about one thing above all: an honest, current picture of what's actually in flight, regardless of whether a human or an agent is driving it.

## Goals

1. Keep a single board where human- and agent-authored tickets are indistinguishable in structure, so triage doesn't require separate processes.
2. Track user stories and PRDs as first-class, linkable work items, not documents that live outside the tracker.
3. See sprint/iteration burndown without exporting data to another tool.

## Frustrations

1. Tools that treat "AI-generated work" as a separate, second-class ticket category.
2. Custom fields that were defined once and never revisited as the team's process matured.
3. Losing the thread between a PRD, the user stories it spawned, and the tickets implementing them.

## Behaviors

- Reviews the board every morning, filtering by iteration and stage.
- Defines and periodically prunes custom ticket fields and types for her org.
- Links tickets to the PRD or user-story ticket that justified them, rather than relying on tribal memory.

## Job to Be Done

> "When I'm planning a sprint that mixes human and agent contributors, I want one board with consistent ticket types and fields, so I can triage and report on all work the same way."

## Relationship to Product

Adopted NPL when her team's agent usage outgrew a spreadsheet-based tracker. Sticks with it because ticket types are configurable per org rather than fixed, and `user_story`/`prd` tickets link cleanly to implementation tickets. Would churn if board performance degraded at scale or if agent-authored tickets started requiring manual reformatting to fit human workflows.

## Scenarios

1. **Sprint planning** — Priya opens the board, moves tickets into the new iteration, and reassigns a few from an agent that's over capacity to one that's under.
2. **PRD to stories** — Priya creates a `prd` ticket, links five `user_story` tickets to it, and tracks story-level completion as a rollup.
3. **Custom field cleanup** — Priya retires a `custom_fields` entry that hasn't been used in two quarters and confirms it doesn't break historical tickets that still carry the old value.
