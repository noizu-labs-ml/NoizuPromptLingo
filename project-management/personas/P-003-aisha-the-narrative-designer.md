---
id: P-003
name: "Aisha Okonkwo"
slug: "aisha-the-narrative-designer"
archetype: "The Narrative Designer"
segment: "secondary"
tags: [game-dev, narrative-design, multiplayer, collaboration, export, lore-bible]
---

# Aisha Okonkwo — The Narrative Designer

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 30-38 |
| **Role** | Lead Narrative Designer at an indie game studio |
| **Technical Level** | Advanced |
| **Industry** | Video game development (indie/AA) |
| **Location** | London, UK |

## Bio

Aisha leads a team of three writers building the lore for an open-world RPG. They have 400+ lore entries across a shared Confluence wiki, and contradictions between writers are a recurring source of bugs and rework. She needs structured content that can be exported to the game engine for codex entries, dialogue trees, and item descriptions.

## Goals

1. Maintain a single source of truth for a multi-writer lore database
2. Export structured content to game engine formats (JSON schemas, dialogue CSVs)
3. Catch contradictions between writers before they become shipped bugs

## Frustrations

1. Three writers independently created backstories for the same NPC with incompatible details — discovered after the dialogue was already recorded
2. Confluence has no concept of entry types, relationships, or consistency checking — it's just pages
3. Exporting lore to the game engine requires manual copy-paste into JSON templates

## Behaviors

- Works in sprints with the rest of the dev team, lore work aligns with milestone deadlines
- Reviews all writer output in weekly lore sync meetings
- Uses Confluence for docs, Jira for tasks, custom spreadsheets for tracking relationships
- Has attempted to build an internal "lore database" tool twice — both abandoned

## Job to Be Done

> "When we have 6 writers and 400 lore entries, I want a system that flags contradictions as they're written and exports clean structured data to our engine, so we ship a world that tells one story."

## Relationship to Product

Aisha would discover Knowledge Base through game dev conferences (GDC narrative track) or indie dev communities. The multiplayer/collaborator features and structured export are her decision drivers. She'd need Team tier for multi-writer support. She'd churn if export formats don't match her engine's schema or if the tool can't handle the velocity of multiple concurrent writers.

## Scenarios

1. **Cross-writer consistency review** — During a weekly sync, Aisha runs the consistency checker across all entries modified that sprint. It flags three contradictions: two are genuine conflicts, one is an intentional narrative ambiguity she marks as deliberate.
2. **Engine export pipeline** — Before a milestone build, Aisha exports all codex entries as JSON matching the game engine's schema. She filters by region and faction, exports 120 entries, and hands the file to the integration engineer.
