---
id: P-006
name: "Aisha Patel"
slug: "aisha-patel"
archetype: "The Game Studio Lead"
segment: "primary"
tags: [studio-lead, production, commercial, llm-costs, team-adoption, make-vs-buy]
---

# Aisha Patel — The Game Studio Lead

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 38–45 |
| **Role** | Indie Studio Lead / Technical Director |
| **Technical Level** | Advanced |
| **Industry** | Commercial Indie Games |
| **Location** | UK, US, or Canada |

## Bio

Aisha leads a five-person studio that has shipped two commercial titles and is midway through a third — an AI-driven narrative RPG with a modest Kickstarter behind it. She's the most technical person on the team and makes the architecture decisions, but she's not heads-down in code all day; she manages people, budgets, and timelines. She's evaluated three AI game frameworks in the past six months and built a small internal prototype with one of them. Her primary concern is whether she can trust a framework to hold up in production, whether the community will maintain it when her team hits an edge case at 2am the week before launch, and whether the LLM costs will eat her margin.

## Goals

1. Ship a production-grade AI-driven RPG on time and within LLM budget
2. Evaluate NoizuRPG against building in-house with confidence in the decision
3. Ensure the framework has sufficient community and maintenance to reduce long-term risk

## Frustrations

1. Most open-source AI game frameworks are abandoned after the initial blog post hype cycle
2. LLM costs are unpredictable without intelligent context management and provider fallback
3. Framework APIs break between versions with no migration guides, costing her team time before launches

## Behaviors

- Evaluates frameworks via a structured spike: two days, one engineer, a defined test scenario
- Reads GitHub Issues, commit history, and Discord activity before committing to a dependency
- Tracks LLM API spend in a dashboard; sets hard per-session budget thresholds
- Attends GDC talks on AI in games; follows studio engineering blogs from mid-size indie studios

## Job to Be Done

> "When I'm choosing infrastructure for our AI RPG, I want a framework with production track record, active maintenance, and LLM cost controls, so I can ship on time without betting the company on an abandoned library."

## Relationship to Product

Discovers NoizuRPG through a GDC talk, an engineering blog post, or a recommendation from a trusted developer in her network. Evaluates systematically: reads the docs, checks GitHub pulse, looks for production case studies. Adopts if she can see evidence of real usage, a clear upgrade path, and commercial services (Managed Memory, Managed Models) that reduce operational burden. Champions via word of mouth at industry events. Churns if a minor version breaks a core API without warning, or if GitHub goes quiet for more than 60 days.

## Scenarios

1. **Framework Evaluation** — Assigns one engineer a two-day spike to implement the game's core NPC loop with NoizuRPG; compares output quality and dev velocity against the in-house prototype.
2. **Launch Week** — Hits an edge case in the Quest Engine three days before ship; files a GitHub issue and gets a response within 24 hours; confidence in the community holds.
