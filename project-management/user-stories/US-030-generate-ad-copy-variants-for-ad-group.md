---
id: US-030
title: "Generate Ad Copy Variants for an Ad Group"
slug: "generate-ad-copy-variants-for-ad-group"
personas: [P-005]
epic: "Creative Assets & Campaigns"
priority: "must-have"
complexity: "M"
tags: [ad-copy, generation, llm, campaigns]
---

# US-030: Generate Ad Copy Variants for an Ad Group

## User Story

**As the** Growth Operator (P-005),
**I want to** generate several LLM-drafted ad copy variants for an ad group in one request,
**So that** I can compare distinct messaging angles and choose the strongest copy without writing first drafts by hand.

## Acceptance Criteria

- [ ] Given an ad group with a target-audience label and product description, when I trigger "generate ad copy" with a requested variant count (e.g., 3), then that many distinct ad copy drafts are created under the ad group, each in "pending review" status.
- [ ] Given a generation request is in flight, when the underlying LLM call fails or times out, then I see a clear error message and no partial or corrupted ad copy records are left behind in "pending review" status.
- [ ] Given an ad group already has one or more approved ad copy variants, when I generate additional variants, then the new drafts are added alongside the existing ones without overwriting or deleting previously approved copy.

## Notes

Generated variants feed directly into the approve/reject workflow in US-031. Depends on an ad group existing per US-029.
