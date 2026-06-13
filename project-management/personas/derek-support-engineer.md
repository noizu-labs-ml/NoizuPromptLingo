---
name: Derek Chen
role: Support Automation Engineer
tier: secondary
org_archetype: Consumer app (1M+ MAUs)
pricing_fit: Pro → Team
---

# Derek Chen — Support Automation Engineer

## Background

Four years in support engineering. Building chat deflection for a consumer app with multilingual, mixed-competence users. Ships to 1M+ monthly active users across five languages.

## Org Context

Reports into support operations, not product engineering. Success metrics are support-deflection rate and CSAT. Every agent-caused complaint lands in his queue.

## Goals

- Agent never says something embarrassing to a frustrated non-native speaker
- Graceful handling of ambiguous, empty, or broken input
- Strict adherence to policy on escalations and refunds

## Jobs-to-be-done

- "The agent must not mirror hostility when a user is angry."
- "Handle broken-English and non-native speakers without correcting their grammar."
- "Never offer a refund the agent isn't authorized to issue."

## How He Uses CodeFresh

- Persona-heavy testing — `broken-english`, `hostile`, `confused-novice` are daily drivers
- Refund-policy expectations as structural assertions (regex + key-presence checks)
- Escalation-policy expectations as LLM-as-judge scoring
- Runs the full suite before every weekly prompt update

## Schema Requirements from This Workflow

| Need | Schema answer |
|---|---|
| Rich persona library with tone/language variants | `personas` / `persona_versions` versioned per-org; custom personas for his specific languages |
| Structural policy assertions | `expectations.scoring_method = :structural`, `:regex` — config in JSONB carries the assertion shape |
| Per-persona failure reporting | `run_steps.persona_version_id` pinned per step; scores aggregable per persona |
| Fast feedback on policy violations | `scores.verdict = :fail` + `direction = :negative` on expectations flags "must not" violations immediately |

## Success Metrics

- Support escalation rate trends down
- CSAT trends up in his product area
- Zero unauthorized-refund incidents in production over a full quarter

## Objections / Churn Risks

- Persona library doesn't match his edge cases (he needs languages the default library doesn't ship)
- Run cost on a large support suite with many personas
- Feedback loop too slow for his weekly release cadence
- Structural assertions are too brittle for natural-language policy violations

## Pricing Fit

Pro initially. Escalates to Team once the support-engineering org's usage + need for run history justifies it. Derek is a power user of the persona layer specifically.
