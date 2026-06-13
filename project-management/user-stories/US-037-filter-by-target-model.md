---
id: US-037
title: "Filter by Target Model"
slug: "filter-by-target-model"
personas: [P-001, P-002, P-003, P-005, P-007]
epic: "Search & Discovery"
priority: "must-have"
complexity: "M"
tags: [filter, discovery, models, search]
---

# US-037: Filter by Target Model

## User Story

**As a** prompt engineer targeting a specific LLM (P-001),
**I want to** filter the prompt feed and search results by the target AI model (e.g., GPT-4, Claude, Llama),
**So that** I only see prompts that are relevant to the model I am currently working with.

## Acceptance Criteria

- [ ] Given I am on the feed or search results page, when I select one or more model filters from the sidebar or filter bar, then only prompts tagged with those models are displayed
- [ ] Given I apply a model filter, when the filtered results render, then the active filter is visually indicated and a "clear filter" option is available
- [ ] Given a new model is added to the platform's model registry by an admin, when the registry is updated, then the new model appears in the filter list within 5 minutes without a deploy
- [ ] Given I apply multiple model filters simultaneously, when results are fetched, then prompts tagged with any of the selected models are returned (OR logic)

## Notes

The model registry should be a configurable list maintained by admins, not hardcoded. Model filters should be combinable with tag filters and sort modes. Consider including model family groupings (e.g., "GPT family") as a convenience filter option.
