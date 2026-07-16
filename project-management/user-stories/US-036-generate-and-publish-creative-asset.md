---
id: US-036
title: "Generate a Creative Asset and Publish Its Active Output"
slug: "generate-and-publish-creative-asset"
personas: [P-005]
epic: "Creative Assets & Campaigns"
priority: "must-have"
complexity: "M"
tags: [creative-assets, publish-workflow, generation, llm]
---

# US-036: Generate a Creative Asset and Publish Its Active Output

## User Story

**As the** Growth Operator (P-005),
**I want to** run the general creative-asset pipeline — prompt, generate or regenerate, accept or reject, publish,
**So that** I can turn any creative brief into a single published "active" output that other parts of the campaign can rely on.

## Acceptance Criteria

- [ ] Given a free-text creative-asset prompt, when I trigger generation, then a new asset version is created in "pending review" status and linked back to that prompt.
- [ ] Given a pending asset version I reject, when I trigger regeneration, then a new version is created while the rejected version is retained in the asset's history rather than deleted.
- [ ] Given an accepted asset version, when I select "publish", then that version becomes the asset's single "active" output, and any previously active version is superseded but retained, not deleted.

## Notes

Generalizes the same generate → accept/reject → publish shape used by ad copy (US-030, US-031) into a reusable pipeline for other creative-asset types.
