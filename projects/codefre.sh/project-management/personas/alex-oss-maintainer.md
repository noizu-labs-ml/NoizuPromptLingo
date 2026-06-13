---
name: Alex Morgan
role: OSS Agent Framework Maintainer
tier: influencer
org_archetype: Independent OSS (foundation-sponsored)
pricing_fit: OSS CLI only (influence multiplier)
---

# Alex Morgan — OSS Agent Framework Maintainer

## Background

Eight years Python and infrastructure work. Maintains `agent-kit-oss` (3k+ GitHub stars), working ~20 hours/week on the project. Sponsored by a nonprofit foundation rather than an employer.

## Org Context

No traditional org. Community governance, contributor community, GitHub Sponsors. Users file "how do I test my agent?" issues constantly and he doesn't have a satisfying answer today.

## Goals

- Help framework users test the agents they build with `agent-kit`
- Drive framework adoption via reference test suites
- Measure regression across framework releases

## Jobs-to-be-done

- "My users ask how to test agents built on agent-kit — I need a blessed answer I can point them to."
- "Validate the framework's official examples still work across new versions."
- "Grow framework adoption via a better testing story."

## How He Uses CodeFresh

- Writes a reference script suite and publishes it in `agent-kit-oss/examples/`
- Uses the CLI in the framework's own CI to catch its own regressions
- Advocates for CodeFresh in framework docs and blog posts
- Does not use the hosted editor or dashboard

## Schema Requirements from This Workflow

| Need | Schema answer |
|---|---|
| OSS-friendly, cloud-free CLI workflow | Scripts as plain YAML; `script_versions.yaml_source` is the round-trip anchor; no editor-only fields |
| No hosted-service coupling for CI | CLI reads local YAML, emits JUnit — hosted schema is irrelevant to his users |
| Lineage of published example scripts | `script_versions.parent_version_id` tracks fork/inheritance without requiring the hosted product |

## Success Metrics

- Integration lands in `agent-kit` v2.0 release notes
- Framework users adopt the test suite and cite it in their own setups
- Community issues start referencing "did you run the codefresh suite?"

## Objections / Churn Risks

- The CLI isn't genuinely open source or doesn't run fully offline
- Licensing on shared scripts is unclear
- CodeFresh pivots to closed-core and breaks his recommendation
- Freeball engine requires a hosted runner (which he can't recommend to OSS users)

## Pricing Fit

OSS CLI only. Alex is not the customer — he's the influence channel. His users become Priya and Derek (who are the customers).
