---
id: P-001
name: "Marcus Chen"
slug: "marcus-chen"
archetype: "The AI Game Dev"
segment: "primary"
tags: [indie-dev, python, ai-rpg, prototyping, state-management]
---

# Marcus Chen — The AI Game Dev

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 28–34 |
| **Role** | Indie Game Developer / Solo Founder |
| **Technical Level** | Expert |
| **Industry** | Indie Games / AI Applications |
| **Location** | Remote (US West Coast or Southeast Asia) |

## Bio

Marcus has been building games since college — first Unity prototypes, then text-based experiments when LLMs became capable enough to drive narrative. He works alone or in micro-teams, shipping fast, killing projects that don't gain traction. He's deeply comfortable with Python and has integrated OpenAI and Anthropic APIs into three separate game prototypes, each time rewriting the same state management boilerplate from scratch. He follows AI news obsessively, ships to itch.io, and measures success by player session length.

## Goals

1. Build and ship an AI-driven RPG without rebuilding infrastructure from scratch each time
2. Compose reusable components (dialogue, memory, quests) so design iteration is fast
3. Reduce LLM API costs through smarter context management and provider flexibility

## Frustrations

1. Every new prototype means rewriting character state, conversation history, and world persistence
2. Raw API calls produce inconsistent narrative output with no guardrails or structured state
3. Switching LLM providers (OpenAI → Ollama for local testing) breaks his entire integration layer

## Behaviors

- Browses Hacker News, r/MachineLearning, and indie dev Discord servers daily
- Reaches for FastAPI + raw Anthropic SDK as default stack; assembles his own "framework" per project
- Demos games on itch.io and gathers qualitative feedback from a small Discord community
- Benchmarks LLM response latency and cost per token for budget planning

## Job to Be Done

> "When I start a new AI RPG prototype, I want composable, pre-built game state components, so I can focus on game design and narrative instead of rebuilding memory and dialogue infrastructure."

## Relationship to Product

Discovers NoizuRPG through a Hacker News post or GitHub trending. Evaluates by cloning the repo and running the quickstart in under 30 minutes — if he can't, he abandons it. Adopts if the Character and Memory components map to his mental model of game state. Champions it publicly if it ships his game faster. Churns if documentation is stale or component APIs break across minor versions.

## Scenarios

1. **First Prototype** — Replaces 400 lines of custom state code with NoizuRPG's Character System and Memory modules; ships a playable demo in a weekend.
2. **Provider Swap** — Switches from OpenAI to a local Ollama instance for offline testing by changing a single config flag, with no code changes to game logic.
