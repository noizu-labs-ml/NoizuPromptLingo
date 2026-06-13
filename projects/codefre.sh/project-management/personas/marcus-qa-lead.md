---
name: Marcus Delgado
role: QA Lead
tier: secondary
org_archetype: Mid-size enterprise SaaS (2,000 people)
pricing_fit: Team → Enterprise
---

# Marcus Delgado — QA Lead

## Background

Ten years in QA leadership. Now heading agent quality at a mid-size enterprise SaaS (2,000 employees) shipping an AI feature to 50k+ B2B customers. Reports to the VP of Engineering.

## Org Context

SOC2-compliant. Release gates are heavyweight. Agents go through a formal release-readiness review where he signs off. When something ships and breaks, it shows up in exec review.

## Goals

- Defensible, auditable, repeatable quality bar for agent releases
- Metrics executives will read without needing translation
- Evidence SOC2 auditors accept without follow-up questions

## Jobs-to-be-done

- "Prove this agent meets our quality bar before release."
- "Explain to the VP why we blocked a release — and defend it."
- "Build a regression library from every production agent bug we've shipped."

## How He Uses CodeFresh

- Curates the regression suite with engineering; does not author scripts himself
- Reviews what engineers author; blocks releases when the suite regresses
- Tracks trend metrics quarter-over-quarter
- Integrates CodeFresh into the formal release gate

## Schema Requirements from This Workflow

| Need | Schema answer |
|---|---|
| Audit trail of who published what and when | `prompt_versions.published_by_user_id`, `script_versions.published_by_user_id`, immutable version rows with `inserted_at` |
| Immutable run records | `runs` become immutable at terminal `status`; `run_steps` append-only; `scores` immutable per rubric version |
| Quarter-over-quarter trends | `runs` indexed on `(organization_id, inserted_at DESC)`; aggregate queries on `scores.verdict` by time |
| SOC2-friendly exports | Deterministic YAML round-trip; checksum columns prove content integrity |

## Success Metrics

- Zero agent-related rollbacks for two consecutive quarters
- Quarterly QA report cites CodeFresh metrics directly
- SOC2 audit passes without auditors asking for additional behavioral-quality evidence

## Objections / Churn Risks

- Can't justify ROI to finance
- Audit trail gaps (any silent mutation to version tables)
- Missing enterprise SSO
- No fine-grained access control (he needs read-only roles for auditors)

## Pricing Fit

Team tier initially, escalates to Enterprise as SOC2/SSO/audit-log requirements bite. Marcus is the buyer who justifies the Enterprise upsell.
