---
id: P-008
name: "Tomás Lindqvist"
slug: "evaluating-newcomer"
archetype: "The Evaluating Newcomer"
segment: "edge-case"
tags: [onboarding, low-familiarity, non-native-speaker, trust-building]
---

# Tomás Lindqvist — The Evaluating Newcomer

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 26 |
| **Role** | Junior Developer, first job at a two-person startup |
| **Technical Level** | Novice (with MCP/agent tooling specifically; competent generally) |
| **Industry** | Early-stage e-commerce |
| **Location** | Gothenburg, Sweden (non-native English speaker) |

## Bio

Tomás was just invited to an organization by a founder who wants the team using AI agents for real work, not toy demos. He's never configured an MCP server before, isn't fully sure what a "custom scope" is, and is quietly worried about giving an autonomous agent access to anything before he understands what it can actually do.

## Goals

1. Get from "just received an invite" to "agent successfully connected" without needing a synchronous call with a teammate.
2. Understand, in plain language, what tools an agent will have access to before approving anything.
3. Trust that an obviously wrong or confusing state (expired token, failed auth) will say so clearly rather than fail silently.

## Frustrations

1. Jargon-heavy setup instructions that assume familiarity with MCP, JWTs, and tool scopes.
2. Error messages that don't distinguish between "your token expired" and "something is broken."
3. No obvious way to double-check what an agent is allowed to do before letting it run.

## Behaviors

- Reads every screen slowly and re-reads before clicking anything that looks irreversible.
- Prefers to complete the invite/registration flow alone before asking a teammate for help.
- Screenshots error messages to translate or search before assuming they understand them.

## Job to Be Done

> "When I'm new to a platform that gives AI agents real access to my org's work, I want plain-language setup steps and honest error states, so I can trust what I'm approving before I approve it."

## Relationship to Product

Tomás's entire first impression is the invite-to-first-agent-connection path. A single confusing step — an expired invite token with no clear message, or a setup command that fails without explanation — is enough for him to ask a teammate to just do it for him, which quietly caps how far he ever explores the platform on his own. Clear, low-jargon onboarding is what turns him into a confident daily user instead of someone who only ever uses what was set up for him.

## Scenarios

1. **First login** — Tomás uses his invite token, completes OIDC login, and lands on a dashboard that makes clear what organization he's now part of and what to do next.
2. **First MCP key** — Tomás follows the mcp-keys setup flow, copies the generated command, and gets unambiguous success or failure feedback when connecting his first agent.
3. **Expired invite** — Tomás's invite token has expired by the time he gets to it; the registration flow tells him exactly that, in plain language, rather than a generic failure.
