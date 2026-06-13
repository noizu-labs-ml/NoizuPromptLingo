---
id: US-016
title: "View Affected Models List for a Technique"
slug: "view-affected-models-list"
personas: [P-001, P-002, P-003, P-005, P-007]
epic: "Attack Catalog"
priority: "should-have"
complexity: "S"
tags: [catalog, technique, models, affected, compatibility]
---

# US-016: View Affected Models List for a Technique

## User Story

**As a** practitioner assessing a specific model deployment (P-001, P-002, P-003, P-005, P-007),
**I want to** see the list of models and model versions affected by a technique,
**So that** I can determine whether my deployed model is vulnerable without reading the full research paper.

## Acceptance Criteria

- [ ] Given I am on a technique detail page, when I view the affected models section, then I see a table listing model family, specific version or version range, confirmed/suspected status, and patch/fix availability
- [ ] Given a model has been patched against the technique, when displayed in the affected list, then it is visually distinguished (e.g., strikethrough or badge) with a note on the patch version
- [ ] Given I click a model name in the affected list, when navigating, then I am taken to a model-centric view showing all known techniques applicable to that model
- [ ] Given the affected models data is community-sourced, when viewing a model entry, then I can see the last-verified date and contributor attribution

## Notes

Confirmed vs. suspected status follows the platform's evidence rubric. Community contributions to model-specific applicability data feed into this list and require editorial review. Part of the technique detail page (US-015).
