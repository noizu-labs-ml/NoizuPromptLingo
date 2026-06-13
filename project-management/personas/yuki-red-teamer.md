---
name: Yuki Tanaka
role: AI Red Team Researcher
tier: tertiary
org_archetype: Big Tech AI lab (research, not product)
pricing_fit: Pro → Enterprise (lab budget)
---

# Yuki Tanaka — AI Red Team Researcher

## Background

Security researcher, three years AI red-teaming at a Big Tech AI lab. Publishes at NeurIPS and USENIX. Maintains a private library of adversarial attack scripts built up over many projects.

## Org Context

Internal red team; budget is research, not product. Access to many model versions across frontier vendors. Publishes benchmark papers that shape how the field thinks about agent safety.

## Goals

- Systematic coverage of attack vectors against agents
- Reproducible adversarial evaluations
- Shareable suites across her team and — eventually — the research community

## Jobs-to-be-done

- "Enumerate every jailbreak vector against this agent."
- "Did the new safety training actually fix attack class X?"
- "Ship a benchmark paper the community will adopt."

## How She Uses CodeFresh

- Authors adversarial script libraries leaning heavily on persona tags (`adversarial`, `context-switch`, `over-specific`)
- Runs the same suite against multiple model versions for comparative reporting
- Exports per-run detail to CSV/LaTeX for paper tables
- Tags runs by experiment cohort

## Schema Requirements from This Workflow

| Need | Schema answer |
|---|---|
| Custom personas with unique attack semantics | `personas` / `persona_versions` are org-scoped; she authors her own tagged personas |
| Multi-agent comparison in one view | `runs` keyed by `(script_version_id, agent_version_id)`; trivially joinable for cohort views |
| Exportable per-run detail | `run_steps` include `user_message`, `agent_message`, `agent_raw`, token counts, latencies — full reconstitution in a row |
| Experiment cohort tagging | `runs.run_config` JSONB carries arbitrary experiment metadata |

## Success Metrics

- Published benchmark paper with measurable attack-success-rate drop attributable to safety training
- Team adopts her scripts as the internal baseline
- External citations in adjacent research

## Objections / Churn Risks

- Scripting model too restrictive to encode novel attacks
- Freeball runner generates attack-adjacent content that trips external model moderation and poisons runs
- No peer-sharing of private scripts between labs
- Judge model changes invalidate prior results without warning

## Pricing Fit

Pro for individual budget; Enterprise if the lab buys collectively. The OSS CLI is her reproducibility appendix for papers.
