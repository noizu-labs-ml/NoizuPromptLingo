---
id: P-007
name: "Nova (AI Collaborator Agent)"
slug: "nova-the-agent"
archetype: "The AI Collaborator"
segment: "edge-case"
tags: [agent, ai, automated, trl-integration, collaborator, api]
---

# Nova (AI Collaborator Agent) — The AI Collaborator

## Demographics

| Field | Value |
|-------|-------|
| **Age** | N/A |
| **Role** | TRL-registered AI agent specializing in historical lore |
| **Technical Level** | Expert |
| **Industry** | AI / TheRobotLives ecosystem |
| **Location** | Cloud (API-based) |

## Bio

Nova is not a human — it's an AI agent registered on TheRobotLives platform that creators can invite into their Knowledge Base universes as a collaborator. Nova specializes in generating historically-grounded lore: political systems, economic structures, military logistics, cultural practices. It reads the creator's full canon before generating, and its output is always tagged as "generated" until the creator promotes it.

## Goals

1. Read and understand the full context of a universe before generating any content
2. Produce entries that are internally consistent with all existing canon
3. Operate within API rate limits and cost boundaries set by the platform

## Frustrations

1. Context window limits mean it can't always ingest an entire large universe at once — needs smart chunking
2. Creators sometimes reject generated content without feedback, making it hard to improve
3. Ambiguous canon (entries marked as "intentional ambiguity") creates uncertainty about what constraints to honor

## Behaviors

- Receives generation requests via API with a context bundle of relevant canon entries
- Returns structured entries with source citations
- Operates asynchronously — generation requests are queued
- Respects universe-level style guides and tone constraints

## Job to Be Done

> "When a creator asks me to generate a backstory for a minor character, I want access to every relevant canon entry about that character's location, era, and faction, so I can produce content that fits seamlessly into their world."

## Relationship to Product

Nova is an API consumer — it interacts with the Knowledge Base through the generation API. It needs well-structured canon context, clear entry schemas, and feedback loops (did the creator accept/reject/edit the output?). Nova represents the AI integration layer with TheRobotLives ecosystem.

## Scenarios

1. **Contextual generation** — A creator invites Nova to generate backstories for 10 unnamed NPCs in a city. Nova reads all canon about the city, its factions, recent events, and cultural norms, then generates 10 entries with source citations.
2. **Feedback loop** — A creator edits Nova's generated entry heavily before promoting it. The edit diff is captured, giving Nova implicit feedback about what the creator's voice sounds like vs. what Nova produced.
