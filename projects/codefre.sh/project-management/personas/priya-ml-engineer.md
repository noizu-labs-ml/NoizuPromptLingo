---
name: Priya Raman
role: Senior ML Engineer
tier: primary
org_archetype: AI-native startup (Series A, 40 people)
pricing_fit: Team ($199–399/mo)
---

# Priya Raman — Senior ML Engineer

## Background

Five years in ML engineering. Now platform lead at a 40-person AI-native startup building an agentic workflow tool. Ships weekly. Her team's agents go to production without meaningful regression tests today, and she has the scars to prove it.

## Org Context

Series A startup, 6-person agent platform team. CI/CD on GitHub Actions. Observability stack: Datadog plus an internal LangSmith clone. Engineering culture values shipping speed but has started paying the interest on its behavioral-testing tech debt.

## Goals

- Confidence that prompt, model, and framework changes don't break existing behavior
- Catch personality drift before it reaches customers
- Ship faster without fear

## Jobs-to-be-done

- "I changed the system prompt — I need to know what broke before I deploy."
- "Is the new model worse than the old one on my edge cases?"
- "My on-call hates me when agents regress overnight."

## How She Uses CodeFresh

- Authors 10–20 scripts covering onboarding flows, tool-use sequences, known-bad edge cases
- Runs on every PR via the CLI in GitHub Actions
- Uses the diff-view dashboard to compare runs across releases
- Promotes recurring freeball deviations to permanent branches

## Schema Requirements from This Workflow

| Need | Schema answer |
|---|---|
| Diff-view across releases | `runs` pin `script_version_id` + `agent_version_id`; query by `(script_id, inserted_at)` |
| PR-blocking CI gates | `runs.trigger_source = :ci`; aggregate `verdict` on `scores` queryable at run level |
| Re-runnable historical runs | Copy-on-write versions + checksum dedup keep commit-sha-tagged runs comparable across framework changes |
| Freeball → permanent branch | `branch_promotions` produces a new `script_version` with the freeball chain folded in |

## Success Metrics

- >30% reduction in post-deploy behavioral bugs
- Standard suite finishes <10 minutes end-to-end
- CI gate becomes trusted rather than routinely overridden by force-merges

## Objections / Churn Risks

- False positives that flag changes which are actually improvements
- Per-run cost when running on every PR across multiple personas
- Flaky judge models producing non-deterministic scores (same input, different verdict across runs)

## Pricing Fit

Team tier ($199–399/mo). She values the full graph editor + dashboard + persistent run history. Her team adopts the CLI first as a PR-gate wedge, then expands to the hosted surface once results start flagging real bugs.
