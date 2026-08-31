---
id: P-007
name: "Jamie O'Connell"
slug: jamie-oconnell
archetype: "Occasional / novice Claude Code user"
segment: edge-case
tags: [novice, low-frequency, dashboard, onboarding, resume]
---

# P-007: Jamie O'Connell

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 24 |
| Occupation | Junior developer, first job out of bootcamp |
| Location | Denver, CO |
| Tech comfort | medium (comfortable with tools once shown, not a power user) |
| Claude Code usage | A few sessions a week; still learning the tool itself |
| Primary interface | Web UI Dashboard only — hasn't touched CLI, Edit, or Convert |

## Bio
Jamie is new to both their job and to using AI coding agents seriously. They use Claude Code when stuck, but sessions are infrequent enough that they genuinely forget what Claude Assist even does between visits. They need the tool to be self-explanatory every single time, with no assumed familiarity with FTS5, semantic search, or non-destructive editing concepts.

## Goals
- Find a specific past conversation without needing to remember search syntax or filter options
- Resume an old session quickly when a senior teammate says "didn't you already fix something like this?"
- Not accidentally break or lose anything while poking around — trust that they can't damage the original conversation

## Frustrations
- Two search modes (full-text vs. semantic) with no context on which to pick feels like an unexplained decision point
- Terminology like "candidate panel," "quality label," or "rehome" is opaque without prior exposure
- Worries that clicking "Edit" or "Convert" might irreversibly change something, so avoids those areas entirely

## Behaviors
- Sticks almost entirely to the Dashboard's recent-threads list and the plain search bar with default settings
- Uses browser back/forward instead of in-app navigation because the sidebar's contextual nav isn't yet second nature
- Never opens `/settings` — accepts default embedding/index configuration without knowing it exists
- When a senior teammate mentions "just convert that thread into a skill," has to ask what that means

## Job to Be Done
> "When my mentor asks if I already solved a similar bug last sprint, I want to just find that old conversation and pick up where I left off, without having to learn a new tool's full feature set first."

## Relationship to Product
Claude Assist is, for Jamie, essentially "the search box and the resume button" — an occasional recall aid rather than a curation or authoring platform. Their experience is a stress test of whether the Dashboard and basic search remain usable without any of the deeper feature knowledge other personas have.

## Scenarios
- **Scenario 1: Simple recall** — Opens the Dashboard, uses the plain search bar with a rough guess at the topic, and clicks the first result that looks close enough rather than adjusting filters.
- **Scenario 2: Resume on request** — Finds an old thread a mentor referenced, opens `/thread/:id`, and uses the resume command to jump back into that Claude Code session rather than starting fresh.
- **Scenario 3: Cautious avoidance** — Notices the Edit and Convert actions in the thread header's action bar but doesn't click them, unsure whether doing so is safe or reversible, and asks a teammate first.
