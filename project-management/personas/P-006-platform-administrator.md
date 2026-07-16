---
id: P-006
name: "Ilya Petrov"
slug: "platform-administrator"
archetype: "The Platform Administrator"
segment: "tertiary"
tags: [global-admin, security, llm-ops, pbac]
---

# Ilya Petrov — The Platform Administrator

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 45 |
| **Role** | Platform/Infrastructure Administrator (global `admin` role) |
| **Technical Level** | Expert |
| **Industry** | Internal platform team, multi-org deployment |
| **Location** | Berlin, Germany |

## Bio

Ilya runs the instance itself, not any one organization's work. He's the one who onboards new LLM providers, curates the MCP custom-scope presets other orgs pick from, and is the last line of defense if a user account or GitHub grant needs to be pulled immediately.

## Goals

1. Verify a new LLM provider's connectivity before any org can select it, without shipping a broken integration.
2. Curate a small set of sane MCP custom-scope presets so org owners aren't building tool scopes from scratch.
3. Investigate and act on a compromised account or over-broad GitHub grant within minutes, not hours.

## Frustrations

1. Provider credentials that "look" configured but fail silently on first real call.
2. PBAC policy documents complex enough that even he needs the simulator to predict an outcome.
3. Global admin actions (like a role change) that don't make it obvious whether they'll lock out the person performing them.

## Behaviors

- Runs live connectivity tests against every new LLM provider (OpenAI, Anthropic, Groq, Cerebras, DeepSeek, Ollama) before enabling it org-wide.
- Uses the policy simulator (`/policies/check`, `/policies/explain`) before rolling out a PBAC change broadly.
- Keeps MCP API key and GitHub token admin views open during any incident response.

## Job to Be Done

> "When I'm responsible for the whole instance rather than one org, I want global visibility and control over providers, scopes, and credentials, so I can react to problems before they cascade across every tenant."

## Relationship to Product

Ilya is a heavy but narrow user — almost exclusively the `/app/admin/*` surface. He stays because the admin panel gives him instance-wide levers (provider catalog, custom-scope presets, GitHub grants, user suspension) without needing direct database access. He'd escalate hard if a self-lockout guard on role changes were missing, or if a provider test claimed success without an actual live call.

## Scenarios

1. **Provider onboarding** — Ilya adds a new LLM model catalog entry, runs a live connectivity test with a masked key, and only then makes it selectable by orgs.
2. **Incident response** — Ilya suspends a compromised user account and revokes its MCP API keys and GitHub grants from the same admin session.
3. **Scope curation** — Ilya publishes a new global `core_variant` custom-scope preset after seeing three orgs independently build nearly the same custom scope.
