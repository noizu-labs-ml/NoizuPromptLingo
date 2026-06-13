---
name: Dr. Nia Okonkwo
role: AI Research Engineer / Academic
tier: tertiary
org_archetype: Academic lab (top-20 CS department)
pricing_fit: OSS + grant-funded Pro
---

# Dr. Nia Okonkwo — AI Research Engineer / Academic

## Background

PhD, assistant professor at a top-20 CS department. Two PhD students. Publishes on agent safety and evaluation methodology. Runs reproducible benchmarks as the anchor of her papers.

## Org Context

Grant-funded lab. Open-source ethos. Publishes code and data alongside papers. Reviewers demand reproducibility; if a paper's benchmarks don't rerun, it doesn't get cited.

## Goals

- Reproducible evaluation infrastructure her lab can stand behind publicly
- Cross-framework comparisons in a single view
- Paper-grade benchmarks the community adopts

## Jobs-to-be-done

- "Run the same script suite against 10 agent frameworks and report comparably."
- "Share scripts with peer reviewers and let them reproduce the run."
- "Match my lab's open-source publishing standards."

## How She Uses CodeFresh

- Authors benchmark suites as part of paper submissions
- Publishes scripts alongside papers in reproducibility repositories
- Uses the OSS CLI in reproducibility CI
- Her students use the hosted editor for methodology instruction

## Schema Requirements from This Workflow

| Need | Schema answer |
|---|---|
| Plain-text, git-pinnable artifacts | `script_versions.yaml_source`, `checksum` for identity across forks |
| Reproducibility despite judge-model drift | `scores.judge_prompt_version_id`, `scores.judge_model`, `rubric_version_id` all pinned per score row |
| Cross-framework comparisons | Same `script_version_id` × many `agent_version_id` — run cohort queryable in one view |
| No vendor lock-in on scoring | `expectations.scoring_method` includes `:regex` / `:structural` / `:semantic` paths that don't require the hosted judge |

## Success Metrics

- 5+ papers cite CodeFresh benchmarks within 18 months
- Methodology adoption in related work
- Students graduate fluent in the tool

## Objections / Churn Risks

- Proprietary scoring she can't fully document in a paper
- Irreproducible results due to silent judge-model updates
- Academic licensing unclear
- Any product move that would disrupt published-paper reproducibility

## Pricing Fit

OSS CLI for reproducibility. Grant-funded Pro seat for her own authoring workflow. Nia won't pay Enterprise; she may negotiate an academic-program discount.
