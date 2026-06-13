---
id: US-024
title: See freeball runner confidence per tentative node
issue_type: story
slug: see-freeball-confidence
status: in-progress
priority: P0
story_points: 2
estimated_scope: XS
category: freeball-protocol
components:
  - frontend
labels:
  - mvp
  - wave-1
  - freeball
  - results
assignee: null
reporter: null
epic: mvp-results
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas: []
related_stories:
  - US-022
  - US-023
dependencies:
  - US-022
blocks: []
duplicates: []
schema_refs:
  - freeball_expectations
  - freeball_nodes
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# See freeball runner confidence per tentative node

## Story

As an **AI Red Team Researcher**,
I want to **see the runner LLM's self-reported confidence for each freeball node and each of its expectations**
so that **I can discount results where the runner itself wasn't sure what "good" looks like**.

## Acceptance Criteria

- [ ] Freeball node card shows the overall `confidence` value (0.000–1.000)
- [ ] Each freeball expectation's `confidence` is shown next to its label
- [ ] Low-confidence freeball results are visually de-emphasized (ex. reduced opacity, warning icon)
- [ ] Confidence thresholds for "low / medium / high" visualization are configurable in org settings (default low <0.5, med 0.5–0.8, high >0.8)

## Notes

- Confidence thresholds default but org-configurable — large orgs with high-quality runner models may want stricter floors

## Out of Scope

- Surface confidence distribution histograms across runs (Wave 3)
- Auto-discard freeball results below a confidence floor (Wave 3)
