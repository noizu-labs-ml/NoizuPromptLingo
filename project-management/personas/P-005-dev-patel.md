---
id: P-005
name: "Dev Patel"
slug: "dev-patel"
archetype: "Indie Developer"
segment: "primary"
tags: [developer, production, indie-hacker, api-integration, tool-builder, pragmatic]
---

# Dev Patel — Indie Developer

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 25–35 |
| **Role** | Solo Indie Developer / Maker |
| **Technical Level** | Advanced |
| **Industry** | Software (self-employed) |
| **Location** | Remote (originally Ahmedabad; now nomadic) |

## Bio

Dev ships micro-SaaS products and automation tools, typically building three to five projects per year with the intent of hitting $500–2,000 MRR on each before moving on. His current stack is Next.js for frontends, a mix of serverless and containerized backends, and heavy LLM integration for every product he touches. He thinks of prompts as a form of product logic — they need to be reliable, version-controlled, and observable. He's had expensive on-call incidents caused by model behavior changes after silent prompt drift, so he's developed strong opinions about prompt engineering for production systems.

## Goals

1. Find production-tested prompt templates for common app building blocks (extraction, classification, summarization, agent orchestration) so he doesn't start from scratch every project.
2. Stay informed when model providers make breaking changes that affect prompt reliability.
3. Share his own production-grade prompts in exchange for community reputation and early feedback.

## Frustrations

1. Most shared prompts are written for interactive chat use, not for programmatic API calls — they don't account for JSON mode, token limits, temperature settings, or structured output requirements.
2. There's no community tracking of model behavior regressions — he has to discover these incidents himself, usually after they've already broken a paying customer's workflow.
3. Prompt marketplaces treat prompts as static products; Dev needs prompts that come with context about which model versions they've been tested on and what failure modes to watch for.

## Behaviors

- Uses LangSmith for prompt versioning and eval tracking internally.
- Reads Hacker News AI threads but finds them more opinion than practice.
- Maintains a private GitHub repo of production prompt templates he's battle-tested.
- Ships a new product every 6–8 weeks; prompt engineering is a blocking step in each launch.
- Posts on Indie Hackers about his build process; follows the same community on Meat Brains.

## Job to Be Done

> "When I'm building a new AI feature for a product, I want to find a community-validated, production-ready prompt I can adapt for my use case, so I can ship faster without reinventing the wheel or shipping something that breaks under real-world load."

## Relationship to Product

Dev finds Meat Brains through a Hacker News comment that links to a post about structured output prompts for GPT-4o. He recognizes the platform immediately as "what I've been looking for" — community-validated, model-tagged, and with actual discussion in the comments. He becomes a regular contributor in the "Production" and "API Integration" tags, posting detailed write-ups of prompts that survived real traffic. Features that matter most: model version tags, production/hobby distinction for posts, ability to attach eval benchmarks or failure mode notes, API access to the prompt database for personal tooling. He churns if the "production" category fills up with tutorial-grade content that hasn't been tested at scale.

## Scenarios

1. **Shipping an Extraction Feature** — Dev is building a receipt OCR product and needs a reliable extraction prompt for line items. He searches Meat Brains for "structured extraction JSON GPT-4o" and finds a top-voted post with three prompt variants, notes on which fails with multi-currency receipts, and comments from two other devs who've run it in production at 10k+ requests/day. He adapts the winning variant, ships it, and posts his own experience two weeks later.

2. **Catching a Model Regression** — Dev notices his classification prompt is suddenly returning malformed JSON at a higher rate after a model update. He posts a thread on Meat Brains asking if others have seen the same behavior. Within hours, five other devs confirm the regression and one has already found a workaround — a minor prompt modification that restores stable output. The community collectively saves hundreds of developer-hours of debugging.
