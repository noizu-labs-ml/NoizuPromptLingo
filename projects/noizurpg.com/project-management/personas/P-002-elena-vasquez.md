---
id: P-002
name: "Elena Vasquez"
slug: "elena-vasquez"
archetype: "The Interactive Fiction Author"
segment: "secondary"
tags: [interactive-fiction, narrative-design, twine, ink, light-scripting]
---

# Elena Vasquez — The Interactive Fiction Author

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 35–42 |
| **Role** | Published IF Author / Narrative Designer |
| **Technical Level** | Intermediate |
| **Industry** | Interactive Fiction / Digital Publishing |
| **Location** | UK or Western Europe |

## Bio

Elena has published three well-reviewed interactive fiction works on itch.io and has been shortlisted for XYZZY awards. She writes her stories in Ink and Twine, with enough scripting fluency to handle variables, branches, and simple logic. She's deeply invested in characters that feel alive and responsive, and she's been experimenting with LLM-driven dialogue as a way to let players ask open-ended questions. But every tutorial she finds assumes either a full engineering background or no coding at all — she falls in the awkward middle.

## Goals

1. Create AI-responsive characters that stay consistent with her authored world and voice
2. Add dynamic dialogue to existing stories without rebuilding them as software projects
3. Ship games that feel more alive without spending months learning distributed systems

## Frustrations

1. Raw LLM integrations break character voice — the model ignores authored lore and invents contradictions
2. Existing IF tools (Twine, Ink) have no native AI integration; bridging requires expertise she lacks
3. Framework tutorials assume Python fluency she doesn't fully have; she gets stuck on environment setup

## Behaviors

- Writes in Ink or Twine; treats code as a last resort
- Reads IFDB reviews and Interactive Fiction Community Forum posts for inspiration
- Prototypes dialogue with ChatGPT directly, then despairs that she can't replicate it in a game
- Collaborates with a technical friend occasionally when she's truly stuck

## Job to Be Done

> "When I'm building a story with complex characters, I want an AI layer that respects my authored world state and voice, so I can give players open-ended dialogue without losing narrative control."

## Relationship to Product

Discovers NoizuRPG through an IF community forum post or a YouTube tutorial targeted at authors. Adopts if there's a clear "author-first" getting started guide that doesn't require understanding async Python. High-value features: character voice constraints, world state injection, and output that stays within authored tone. Churns if setup requires Docker, virtual environments, or database configuration without clear guidance.

## Scenarios

1. **Dynamic NPC** — Uses the Dialogue Manager to give a key NPC the ability to answer player questions about the game world, constrained by a YAML character sheet she authored.
2. **Memory Continuity** — Configures the Memory System so NPCs remember choices the player made two sessions ago, without Elena writing explicit conditional branches for every possibility.
