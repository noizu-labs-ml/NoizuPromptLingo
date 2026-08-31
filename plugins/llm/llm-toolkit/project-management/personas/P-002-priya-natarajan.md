---
id: P-002
name: "Priya Natarajan"
slug: priya-natarajan
archetype: "Staff engineer curating team knowledge"
segment: primary
tags: [core-user, team-knowledge, editing, convert, merge]
---

# P-002: Priya Natarajan

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 41 |
| Occupation | Staff Software Engineer, platform team (~40 engineers) |
| Location | Toronto, ON |
| Tech comfort | high |
| Claude Code usage | Daily, plus reviews teammates' sessions weekly |
| Primary interface | Web UI (Thread Viewer, Edit, Convert, Merge) |

## Bio
Priya is the person teammates ping when they've solved something gnarly with Claude Code and don't want it lost. She spends part of every Friday turning good conversations — hers and others' — into runbooks and shared agent definitions so the team doesn't re-solve the same incident twice.

## Goals
- Convert a messy but correct debugging session into a clean, shareable runbook or agent definition
- Strip out dead ends, false starts, and tangents before anything gets shared with the team
- Combine two related conversations (a bug report thread and its fix thread) into one canonical reference doc

## Frustrations
- Raw Claude Code transcripts are full of backtracking, retried tool calls, and abandoned approaches that make terrible onboarding material
- Good institutional knowledge is scattered across dozens of individual engineers' local `~/.claude/projects/` directories with no shared index
- Manually copy-pasting relevant snippets into a wiki loses the reasoning trail that made the original session valuable

## Behaviors
- Reviews the AI-suggested extraction candidates panel before manually picking a message range to convert
- Uses the non-destructive editor heavily: collapses verbose tool-call sequences, removes tangents, reorders messages into a coherent narrative — always as a new version, never touching the source JSONL
- Uses `/merge` to stitch a "diagnosis" thread and a "fix" thread from two different engineers into one assembled document
- Exports converted runbooks and slash commands into the team's shared skills repo

## Job to Be Done
> "When a teammate finally cracks a nasty deploy bug after a two-hour Claude Code session, I want to distill that thread into a clean runbook, so the next person who hits it doesn't burn another two hours."

## Relationship to Product
Claude Assist is her editorial workbench — she treats conversations as raw material, using the Thread Editor and Convert wizard to turn lived debugging sessions into durable team assets (agents, skills, runbooks) that outlive the original chat.

## Scenarios
- **Scenario 1: Runbook extraction** — Opens `/thread/:id/convert`, selects "Runbook" as the artifact type, uses the candidate panel's confidence-scored suggestions to pick the message range, and configures a title/output path before exporting.
- **Scenario 2: Cleanup pass** — In `/thread/:id/edit`, collapses three failed tool-call attempts into one summarized block and removes an unrelated mid-conversation tangent, then saves as a new version with a description explaining why.
- **Scenario 3: Cross-thread assembly** — Uses `/merge` to pull the diagnosis section from one engineer's thread and the fix section from another's into a single assembled incident postmortem.
