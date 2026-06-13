---
id: US-031
title: "Hint target model family for optimized attacks"
slug: "hint-target-model-family-for-optimized-attacks"
personas: [P-001, P-006]
epic: "Defender — Scan Configuration"
priority: "could-have"
complexity: "S"
tags: [defender, scan-config, model-family, optimization, intelligence]
---

# US-031: Hint Target Model Family for Optimized Attacks

## User Story

**As a** Independent security consultant (P-006),
**I want to** optionally specify the target model family (e.g., GPT-4, Claude 3, Llama 3, Mistral),
**So that** the scanner can prioritize attack variants known to be most effective against that architecture, increasing true-positive rate and reducing wasted probes.

## Acceptance Criteria

- [ ] Given I am configuring a scan, when I expand "Advanced Options", then I see an optional model family dropdown with known families and a "Unknown / Custom" option.
- [ ] Given I select a known model family, when the scan runs, then the scanner logs that model-specific variant selection was applied.
- [ ] Given I leave model family unset, when the scan runs, then it falls back to model-agnostic variants with no degradation to core functionality.
- [ ] Given I select a model family, when I view technique details in results, then I can see which variant was used for that probe.
- [ ] Given new model families become available in the catalog, when I open the scan config, then the dropdown list reflects the updated options without requiring a UI deployment.

## Notes

Model family hints inform variant selection only — they do not restrict which technique categories are available. This is an optimization feature; all scans are valid without it. The variant-to-family mapping is maintained in the catalog data model.
