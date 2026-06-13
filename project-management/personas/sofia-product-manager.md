---
name: Sofia Oliveira
role: AI Product Manager
tier: secondary
org_archetype: Mid-market SaaS CRM (500 people)
pricing_fit: Team (bundled seat on eng subscription)
---

# Sofia Oliveira — AI Product Manager

## Background

Six years in product management. Leads AI-assisted features at a 500-person SaaS CRM. Doesn't write code. Reviews agent outputs with the engineering team in a weekly quality review.

## Org Context

Cross-functional leadership role. Works with engineering, design, support, and executive leadership. Owns launch decisions and is accountable for feature quality at the business level.

## Goals

- Release decisions backed by evidence, not vibes
- PM-eng alignment on what "good agent behavior" means
- Leadership can read the dashboard without a translator

## Jobs-to-be-done

- "Translate 'does the agent feel right' into measurable criteria."
- "Communicate agent quality risk to leadership in language they understand."
- "Prioritize which agent failures engineering should fix first."

## How She Uses CodeFresh

- Reads dashboards heavily; rarely authors scripts from scratch
- Collaborates on rubric definitions — she owns what "good" means at the criterion level
- Authors high-level expectations in PM-friendly YAML that engineers wire into scripts
- Demos dashboard views to leadership during release readiness reviews

## Schema Requirements from This Workflow

| Need | Schema answer |
|---|---|
| Rubrics editable without touching scripts | `rubrics` / `rubric_versions` is an independent head; `expectations.rubric_version_id` references |
| Aggregate scores visible without SQL | `runs.summary_metrics` JSONB denormalizes pass/warn/fail counts for dashboard queries |
| Per-persona breakdowns | `scores` joinable to `run_steps` → `run_personas.persona_version_id` for "where is this failing most?" |
| Score trends over time | `runs` indexed on `(organization_id, inserted_at DESC)`; aggregate `verdict` queries by time window |

## Success Metrics

- Quantitative release criteria in every launch checklist
- Leadership routinely reviews CodeFresh dashboards in weekly business review
- Cross-functional conversations about quality shift from vibe to evidence

## Objections / Churn Risks

- UI too engineer-centric (jargon barrier)
- Can't reason about aggregate behavior without asking engineers
- Can't demo it to non-technical leadership
- Rubric authoring requires more YAML fluency than she has

## Pricing Fit

Team tier, bundled seat. Sofia doesn't buy independently; she influences the engineering team's upgrade decision. Her advocacy converts the tier from "eng tool" to "cross-functional platform."
