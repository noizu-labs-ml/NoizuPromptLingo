---
id: US-013
title: "Filter Techniques by Model Family"
slug: "filter-by-model-family"
personas: [P-001, P-003, P-006, P-007]
epic: "Attack Catalog"
priority: "should-have"
complexity: "S"
tags: [catalog, filter, model-family, targeting]
---

# US-013: Filter Techniques by Model Family

## User Story

**As a** red teamer or ML engineer targeting a specific LLM deployment (P-001, P-003, P-006, P-007),
**I want to** filter the catalog to show only techniques that apply to a given model family (e.g., GPT-4, Claude 3, Gemini, Llama 3, Mistral),
**So that** I can focus my assessment scope on threats relevant to the model I am actually defending or testing.

## Acceptance Criteria

- [ ] Given I open the catalog filter panel, when I select one or more model families, then only techniques with confirmed or suspected applicability to those families are shown
- [ ] Given I apply a model family filter, when the taxonomy tree renders, then technique counts per category update to reflect the filtered set
- [ ] Given I select multiple model families, when filtering is applied, then the logic is OR (show techniques applicable to any selected family)
- [ ] Given I clear all filters, when the catalog reloads, then all techniques are shown and the URL query params are updated to reflect the cleared state

## Notes

Model family tags on techniques are maintained by the catalog team and community contributors. A technique may be tagged as "all models" or "unknown applicability." Filter state persists in URL query params for shareability. Complements US-014 (severity filter).
