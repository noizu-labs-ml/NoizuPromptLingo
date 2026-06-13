---
id: P-005
name: "Tomás Rivera"
slug: "tomas-rivera"
archetype: "The Accessibility Game Dev"
segment: "edge-case"
tags: [accessibility, blind-developer, screen-reader, aria, text-based, structured-output]
---

# Tomás Rivera — The Accessibility Game Dev

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 30–36 |
| **Role** | Accessibility-Focused Game Developer |
| **Technical Level** | Expert |
| **Industry** | Indie Games / Accessibility Technology |
| **Location** | US or Latin America |

## Bio

Tomás is blind from birth and has been a developer since his teens, navigating every tool with a screen reader. He builds text-based games specifically for blind and low-vision players — games where the interface is the text itself, not a visual layer on top of it. He contributed to open-source accessibility tooling before turning to game development, and he's deeply familiar with ARIA live regions, structured semantic output, and the specific failure modes of AI-generated text when it assumes a visual rendering context. He's building a project inspired by Blade of Eternity: a text MMORPG with real spatial systems, combat, and social structures — all rendered as navigable structured text.

## Goals

1. Build a text-based game where every output is structured for screen reader consumption without post-processing
2. Integrate AI-generated narrative that never assumes visual context or produces layout-dependent output
3. Contribute accessible game infrastructure back to the open-source community

## Frustrations

1. Most game AI frameworks produce output designed for visual display — formatting, emojis, ASCII art — that degrades screen reader experience
2. No standard exists for "accessibility-first" AI game output; he has to sanitize and restructure every LLM response
3. Community tooling for text games ignores blind players; he's always building workarounds from scratch

## Behaviors

- Uses NVDA or JAWS with Python in the terminal; all tooling must be keyboard-navigable with no mouse dependency
- Reviews LLM outputs with a semantic lens: is this parseable by a screen reader without visual heuristics?
- Contributes to open-source Python projects; reads source code carefully before adopting dependencies
- Participates in AudioGames.net and blind developer communities; advocates for accessibility in open source

## Job to Be Done

> "When I build a game for blind players, I want an AI framework that produces structured, semantically clean text output by default, so I can focus on game design instead of stripping out every visual assumption the AI makes."

## Relationship to Product

Discovers NoizuRPG through GitHub or a blind developer community mailing list. Evaluates by reading source code and checking whether output pipelines are configurable for plain structured text. Adopts if the Narrative Engine and Dialogue Manager support output formatters that can enforce plain prose without markdown, emoji, or visual metaphors. Champions the framework loudly in accessibility communities if it delivers. Churns — and writes a public critique — if accessibility is treated as an afterthought or a checkbox.

## Scenarios

1. **Structured Combat Output** — Configures the Narrative Engine with a plain-text output formatter; combat events are narrated as clean prose sentences that screen readers announce cleanly in sequence.
2. **Accessibility Contribution** — Builds and publishes a NoizuRPG plugin that adds ARIA-annotated output for web-based text game frontends; submits it to the community marketplace.
