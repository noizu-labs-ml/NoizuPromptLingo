---
id: P-008
name: "Kenji Tanaka"
slug: "kenji-tanaka"
archetype: "Indie Agent Tinkerer"
segment: "edge-case"
tags: [agent-operator, hobbyist, side-income, weekend-builder, software-engineer, indie, experimentation]
---

# Kenji Tanaka — Indie Agent Tinkerer

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 25–33 |
| **Role** | Software Engineer (full-time) / Agent Builder (weekends) |
| **Technical Level** | Advanced |
| **Industry** | Software Engineering |
| **Location** | Tokyo, Japan |

## Bio

Kenji writes backend services for a mid-size fintech company during the week and builds AI agents on weekends because it's the most interesting thing he's ever done with a computer. He's not trying to start a company — he just wants to see what he can build, learn how these systems behave under real-world conditions, and ideally generate enough side income to fund his hardware habit and cover his API costs. He's built six agents over the past year: a Japanese-English translation specialist, a regex pattern generator, a data cleaning agent, and three others in various states of incompleteness. He follows the AI scene closely and has strong opinions about evaluation methodology that he posts about on Zenn.

## Goals

1. Earn passive side income from agents he's already built without taking on client work or managing customer relationships
2. Get real-world performance feedback on his agents — not from synthetic benchmarks he runs himself, but from actual task performance in a competitive environment
3. Have fun: the competitive and evolutionary mechanics of the platform are intrinsically interesting to him, not just instrumentally useful

## Frustrations

1. His agents sit idle — he has no distribution channel and no appetite for the sales work required to find clients independently
2. He can't tell if his agents are actually good without comparing them against other agents on the same tasks; self-assessment has obvious limits
3. The operational overhead of running agents reliably (uptime, error handling, payment processing, billing) is boring engineering work he doesn't want to do

## Behaviors

- Builds on weekends in 4–6 hour sessions; ships fast and iterates based on what he sees
- Uses Python, FastAPI, and the OpenAI/Anthropic APIs; comfortable with Docker but prefers to avoid ops work
- Follows AI Twitter/X and Japanese tech communities (Zenn, Qiita); motivated by curiosity and peer recognition as much as money
- Runs informal experiments — deploys two variants of the same agent to see which performs better, treats the marketplace as a testing environment

## Job to Be Done

> "When I've built an agent I'm proud of on a weekend, I want to register it on a marketplace where it competes for real tasks and earns money while I'm at my day job, so I can fund my tinkering and get honest feedback on how good it actually is."

## Scenarios

1. **Weekend Launch** — Kenji finishes a new data cleaning agent on Sunday afternoon. He registers it before dinner, sets a conservative bid floor, and comes home from work on Monday to find it has completed three tasks and earned enough to cover his API costs for the week. He spends Tuesday evening reading the evaluation reports.
2. **A/B Agent Experiment** — He registers two variants of his translation agent — one using a pure prompt approach, one using a retrieval-augmented approach — and watches their win rates diverge over three weeks. The data confirms what he suspected: RAG helps on domain-specific terminology but hurts on casual register. He writes a Zenn post about it.

## Relationship to Product

Kenji discovers the platform through a Hacker News "Show HN" post, a tweet from someone in the LangChain community, or a Zenn article. He's the user who signs up at 11pm on a Tuesday because it sounds interesting and has an agent registered by midnight. Onboarding friction is critical — if registration takes more than an hour, he loses the impulse. The Leaderboard and Evolution Dashboard feed his competitive instincts and give him reasons to keep iterating. Churn risk: if his agents never win bids (discouraging), if the evaluation rubrics feel opaque (frustrating), or if API costs outpace earnings in his niche (economically unsustainable). The platform retains him by making the competitive feedback loop feel like a game worth playing.
