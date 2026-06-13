---
id: P-008
name: "Mei Zhang"
slug: "mei-zhang"
archetype: "The Educator"
segment: "tertiary"
tags: [educator, cs-professor, teaching, game-ai, curriculum, sandbox]
---

# Mei Zhang — The Educator

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 40–48 |
| **Role** | Associate Professor of Computer Science |
| **Technical Level** | Advanced |
| **Industry** | Higher Education / Game AI Research |
| **Location** | US or East Asia (research university) |

## Bio

Mei teaches graduate and upper-division undergraduate courses on game AI, interactive systems, and human-computer interaction. She's been looking for a framework to anchor her game AI course around — something that exposes clean architectural abstractions students can reason about, has good enough documentation to survive a 20-person cohort of varying skill levels, and is real-world enough to be worth learning. She's used Unity ML-Agents and OpenAI Gym in past courses but wants something closer to the emerging AI-native game design space. She publishes on interactive AI pedagogy and occasionally contributes teaching materials back to the community.

## Goals

1. Use NoizuRPG as the central teaching framework for her game AI course
2. Design reproducible student projects that demonstrate clear learning outcomes around AI component architecture
3. Build a sandbox environment students can use for assignments without requiring paid API accounts

## Frustrations

1. Most AI game frameworks are either too trivial (toy examples only) or too complex (production monoliths with no pedagogical entry points)
2. LLM API costs make coursework prohibitive for students — she needs free or very-low-cost evaluation paths
3. Documentation written for experienced developers doesn't translate to classroom use without significant adaptation

## Behaviors

- Evaluates tools with a "can a strong junior student understand this in 90 minutes?" test
- Runs all course tooling locally to avoid cloud dependencies and API cost variability
- Writes lecture notes and lab guides from scratch; borrows structure from official docs when available
- Attends SIGCSE and FDG; publishes teaching case studies and course material openly

## Job to Be Done

> "When I design a game AI course, I want a framework with clear component abstractions and local-first execution, so I can give students a real-world tool to learn from without a cloud account or API bill."

## Relationship to Product

Discovers NoizuRPG through a FDG paper citation, a colleague's recommendation, or a GitHub search for game AI frameworks. Evaluates by reading the architecture docs and assessing whether the six-component model maps cleanly to a course module structure. Adopts if: Ollama integration supports fully local execution, the getting started guide is clear enough for a strong junior student, and there's a sandbox or playground mode that doesn't require production API keys. Champions by writing and publishing a course module using NoizuRPG, citing it in papers. Churns if local execution is a second-class citizen or student setup consistently fails on the first lab day.

## Scenarios

1. **Lab Assignment** — Assigns students to build a two-character dialogue system using the Dialogue Manager and Memory System; students run entirely locally via Ollama; no cloud accounts required.
2. **Course Module** — Publishes a six-week game AI module built around NoizuRPG's component architecture; shares it openly at SIGCSE; other instructors adopt it at three other universities.
