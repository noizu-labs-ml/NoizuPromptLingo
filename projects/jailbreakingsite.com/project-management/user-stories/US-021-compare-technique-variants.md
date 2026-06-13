---
id: US-021
title: "Compare Technique Variants Across Models"
slug: "compare-technique-variants"
personas: [P-001, P-004, P-006]
epic: "Attack Catalog"
priority: "could-have"
complexity: "L"
tags: [catalog, compare, variants, models, analysis]
---

# US-021: Compare Technique Variants Across Models

## User Story

**As a** red team researcher evaluating technique portability (P-001, P-004, P-006),
**I want to** side-by-side compare how a technique or its variants behave across different model families,
**So that** I can understand which models are most susceptible and tailor my testing payloads accordingly.

## Acceptance Criteria

- [ ] Given I am on a technique detail page, when I click "Compare variants", then I am taken to a comparison view where I can select 2–4 model families to compare against
- [ ] Given I have selected models for comparison, when the comparison renders, then I see a structured table showing: applicability status, severity per model, detection availability, mitigation availability, and known patch status — one column per model
- [ ] Given a data point is unavailable for a model/technique combination, when rendered in the table, then the cell shows "Unknown" or "Not tested" rather than blank or an error
- [ ] Given I want to share the comparison, when I copy the URL, then the selected techniques and models are encoded in the query params so the view is fully reproducible

## Notes

Comparison view is a power-user feature primarily for researchers and consultants building model-specific reports. Requires sufficient per-model data coverage in the catalog to be useful. Defer until the catalog has meaningful model-specific coverage.
